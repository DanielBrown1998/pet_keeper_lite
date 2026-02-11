import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notification_source.dart';

class NotificationSourceImpl implements NotificationSource {
  final FirebaseMessaging _messaging;
  final FirebaseFunctions _functions;

  NotificationSourceImpl({
    required FirebaseMessaging messaging,
    required FirebaseFunctions functions,
  }) : _messaging = messaging,
       _functions = functions;

  @override
  Future<String?> getToken() {
    return _messaging.getToken();
  }

  @override
  Future<void> requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  @override
  Future<void> notifyFamily({
    required String petId,
    required String message,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    debugPrint('🔔 notifyFamily - currentUser: ${user?.uid}');
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Force refresh the ID token to ensure it's valid
    final idToken = await user.getIdToken(true);
    debugPrint('🔔 notifyFamily - idToken length: ${idToken?.length}');
    debugPrint(
      '🔔 notifyFamily - idToken prefix: ${idToken?.substring(0, 50)}...',
    );

    try {
      final callable = _functions.httpsCallable('notifyFamily');
      final result = await callable.call({
        'petId': petId,
        'message': message,
        'idToken': idToken, // Pass token explicitly as fallback
      });
      debugPrint('🔔 notifyFamily - result: ${result.data}');
    } catch (e) {
      debugPrint('🔔 notifyFamily - error: $e');
      rethrow;
    }
  }
}
