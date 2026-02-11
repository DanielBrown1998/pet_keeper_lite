import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

/// Contract for authentication data source (Firebase Auth + Firestore)
abstract class AuthSource {
  /// Stream of auth state changes
  Stream<User?> get authStateChanges;

  /// Current Firebase user
  User? get currentUser;

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign in with Google credential
  Future<UserCredential> signInWithCredential(AuthCredential credential);

  /// Sign out from Firebase Auth
  Future<void> signOut();

  /// Update user display name
  Future<void> updateDisplayName(String displayName);

  /// Get user data from Firestore
  Future<UserModel?> getUserData(String uid);

  /// Save user data to Firestore
  Future<void> saveUserData(UserModel user);

  /// Update user profile fields in Firestore
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data);

  /// Add FCM token to user's tokens list
  Future<void> addFcmToken(String uid, String token);
}
