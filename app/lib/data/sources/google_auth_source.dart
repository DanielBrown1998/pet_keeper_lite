import 'package:firebase_auth/firebase_auth.dart';

/// Contract for Google Sign-In data source
abstract class GoogleAuthSource {
  /// Sign in with Google and return credentials
  Future<AuthCredential?> signIn();

  /// Sign out from Google
  Future<void> signOut();
}
