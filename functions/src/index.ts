

import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";
// explicitly import each trigger
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

interface NotifyFamilyData {
  petId: string;
  message: string;
  idToken?: string; // Fallback for when Authorization header is not sent
}

/**
 * Cloud Function to notify all family members about a pet update.
 * Called via httpsCallable from the Flutter app.
 */
export const notifyFamily = onCall(
  {
    enforceAppCheck: false,
    cors: true,
    invoker: "public", // Allow unauthenticated invocations (auth is checked in code)
  },
  async (request) => {
    console.log("notifyFamily called");
    console.log("request.auth:", JSON.stringify(request.auth));
    const authHeader = request.rawRequest?.headers?.authorization;
    console.log("Authorization header present:", !!authHeader);

    const data = request.data as NotifyFamilyData;
    let uid: string;

    // Try to get uid from request.auth first
    if (request.auth) {
      uid = request.auth.uid;
      console.log("Using request.auth uid:", uid);
    } else if (authHeader && authHeader.startsWith("Bearer ")) {
      // Fallback 1: manually verify the token from header
      const token = authHeader.substring(7);
      try {
        const decodedToken = await admin.auth().verifyIdToken(token);
        uid = decodedToken.uid;
        console.log("Verified token from header, uid:", uid);
      } catch (tokenError) {
        console.error("Header token verification failed:", tokenError);
        throw new HttpsError(
          "unauthenticated",
          "Invalid authentication token."
        );
      }
    } else if (data.idToken) {
      // Fallback 2: verify token from request body
      try {
        const decodedToken = await admin.auth().verifyIdToken(data.idToken);
        uid = decodedToken.uid;
        console.log("Verified token from body, uid:", uid);
      } catch (tokenError) {
        console.error("Body token verification failed:", tokenError);
        throw new HttpsError(
          "unauthenticated",
          "Invalid authentication token."
        );
      }
    } else {
      console.log("No auth found - request.auth, header, or body token");
      throw new HttpsError(
        "unauthenticated",
        "User must be authenticated to send notifications."
      );
    }

    // Validate input
    if (!data.petId || !data.message) {
      throw new HttpsError(
        "invalid-argument",
        "petId and message are required."
      );
    }

    try {
      // Get the user's family code
      const userDoc = await db.collection("users").doc(uid).get();
      if (!userDoc.exists) {
        throw new HttpsError("not-found", "User document not found.");
      }

      const userData = userDoc.data();
      const familyCode = userData?.familyCode;

      if (!familyCode) {
        throw new HttpsError(
          "failed-precondition",
          "User is not part of a family."
        );
      }

      // Verify the pet belongs to this family
      const petDoc = await db.collection("pets").doc(data.petId).get();
      if (!petDoc.exists) {
        throw new HttpsError("not-found", "Pet not found.");
      }

      const petData = petDoc.data();
      if (petData?.familyCode !== familyCode) {
        throw new HttpsError(
          "permission-denied",
          "Pet does not belong to your family."
        );
      }

      const petName = petData?.name || "Pet";

      // Get all users in the same family
      const usersSnapshot = await db
        .collection("users")
        .where("familyCode", "==", familyCode)
        .get();

      // Collect all FCM tokens (excluding the sender)
      const tokens: string[] = [];
      usersSnapshot.forEach((doc) => {
        if (doc.id !== uid) {
          const fcmTokens = doc.data().fcmTokens as string[] | undefined;
          if (fcmTokens && fcmTokens.length > 0) {
            tokens.push(...fcmTokens);
          }
        }
      });

      if (tokens.length === 0) {
        return { success: true, message: "No recipients found." };
      }

      // Send FCM notifications
      const notification = {
        title: `🐾 ${petName}`,
        body: data.message,
      };

      const payload: admin.messaging.MulticastMessage = {
        tokens: tokens,
        notification: notification,
        data: {
          petId: data.petId,
          type: "family_notification",
        },
        android: {
          notification: {
            channelId: "pet_updates",
            priority: "high" as const,
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      const response = await messaging.sendEachForMulticast(payload);

      // Remove invalid tokens
      const tokensToRemove: string[] = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          const error = resp.error;
          if (
            error?.code === "messaging/invalid-registration-token" ||
            error?.code === "messaging/registration-token-not-registered"
          ) {
            tokensToRemove.push(tokens[idx]);
          }
        }
      });

      // Clean up invalid tokens from users
      if (tokensToRemove.length > 0) {
        const batch = db.batch();
        usersSnapshot.forEach((doc) => {
          const fcmTokens = doc.data().fcmTokens as string[] | undefined;
          if (fcmTokens) {
            const validTokens = fcmTokens.filter(
              (t) => !tokensToRemove.includes(t)
            );
            if (validTokens.length !== fcmTokens.length) {
              batch.update(doc.ref, { fcmTokens: validTokens });
            }
          }
        });
        await batch.commit();
      }

      return {
        success: true,
        successCount: response.successCount,
        failureCount: response.failureCount,
      };
    } catch (error) {
      console.error("Error sending notification:", error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal", "Failed to send notification.");
    }
  }
);
