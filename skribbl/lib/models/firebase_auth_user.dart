import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:skribbl/models/auth_user.dart';

@immutable
class FirebaseAuthUser implements AuthUser {
  final User _user;

  const FirebaseAuthUser(User user) : _user = user;

  @override
  String? get email => _user.email;
  @override
  String? get displayName => _user.displayName;
  @override
  String get uid => _user.uid;
  @override
  String? get photoURL => _user.photoURL;
  @override
  DateTime? get creationTime => _user.metadata.creationTime;
  @override
  DateTime? get lastSignInTime => _user.metadata.lastSignInTime;
  @override
  bool get isAnonymous => _user.isAnonymous;

  @override
  Future<String> getIdToken() async {
    return await _user.getIdToken();
  }

  @override
  Future<void> updateName(String name) async {
    return await _user.updateDisplayName(name);
  }

  @override
  Future<void> updatePhotoURL(String url) async {
    return await _user.updatePhotoURL(url);
  }
}
