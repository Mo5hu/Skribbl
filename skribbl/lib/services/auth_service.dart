import 'package:skribbl/models/auth_user.dart';

abstract class AuthService {
  Future<void> signInAnonymously();

  Future<void> signInWithGoogle();

  Future<void> signInWithApple();

  Future<void> signOut();

  Stream<AuthUser?> authStateChanges();

  Stream<AuthUser?> userChanges();

  /// Return the current auth user synchronously
  AuthUser? get currentUser;
}
