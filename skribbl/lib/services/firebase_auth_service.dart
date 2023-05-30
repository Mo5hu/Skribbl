import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skribbl/models/auth_exception.dart';
import 'package:skribbl/models/firebase_auth_user.dart';
import 'package:skribbl/services/auth_service.dart';

class FirebaseAuthService implements AuthService {
  final _auth = FirebaseAuth.instance;

  @override
  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } on FirebaseException catch (e) {
      throw FirebaseExceptionImpl(e);
    }
  }

  @override
  Future<void> signInWithApple() {
    // TODO: implement signInWithApple
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithGoogle() async =>
      kIsWeb ? await _signInWithGoogleWeb() : await _signInWithGoogleNative();

  Future<void> _signInWithGoogleWeb() async {
    final googleProvider = GoogleAuthProvider();

    try {
      await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } on FirebaseException catch (e) {
      throw FirebaseExceptionImpl(e);
    }
  }

  Future<void> _signInWithGoogleNative() async {
    // Trigger the authentication flow
    final googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseException catch (e) {
      throw FirebaseExceptionImpl(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseException catch (e) {
      throw FirebaseExceptionImpl(e);
    }
  }

  @override
  Stream<FirebaseAuthUser?> authStateChanges() {
    final changes = _auth.authStateChanges().map<FirebaseAuthUser?>(
          (user) => user == null ? null : FirebaseAuthUser(user),
        );
    return changes;
  }

  @override
  Stream<FirebaseAuthUser?> userChanges() {
    final changes = _auth.userChanges().map<FirebaseAuthUser?>(
          (user) => user == null ? null : FirebaseAuthUser(user),
        );
    return changes;
  }

  @override
  FirebaseAuthUser? get currentUser =>
      _auth.currentUser == null ? null : FirebaseAuthUser(_auth.currentUser!);
}
