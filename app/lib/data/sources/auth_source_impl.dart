import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import 'auth_source.dart';

class AuthSourceImpl implements AuthSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) {
    return _firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
    }
  }

  @override
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<void> saveUserData(UserModel user) {
    return _firestore.collection('users').doc(user.uid).set(user.toFirestore());
  }

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) {
    return _firestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  @override
  Future<void> addFcmToken(String uid, String token) {
    return _firestore.collection('users').doc(uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }
}
