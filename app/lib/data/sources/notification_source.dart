/// Contract for notification data source (FCM + Cloud Functions)
abstract class NotificationSource {
  /// Get FCM token
  Future<String?> getToken();

  /// Request notification permission
  Future<void> requestPermission();

  /// Call notifyFamily cloud function
  Future<void> notifyFamily({required String petId, required String message});
}
