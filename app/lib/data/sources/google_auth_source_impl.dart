import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'google_auth_source.dart';

class GoogleAuthSourceImpl implements GoogleAuthSource {
  final GoogleSignIn _googleSignIn;

  GoogleAuthSourceImpl({required GoogleSignIn googleSignIn})
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
