import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Contract for Google Sign-In data source
abstract class GoogleAuthRemoteDataSource {
  /// Sign in with Google and return credentials
  Future<AuthCredential?> signIn();

  /// Sign out from Google
  Future<void> signOut();
}

class GoogleAuthRemoteDataSourceImpl implements GoogleAuthRemoteDataSource {
  final GoogleSignIn _googleSignIn;

  GoogleAuthRemoteDataSourceImpl({required GoogleSignIn googleSignIn})
    : _googleSignIn = googleSignIn;

  @override
  Future<AuthCredential?> signIn() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    return GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  @override
  Future<void> signOut() {
    return _googleSignIn.signOut();
  }
}
