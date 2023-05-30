import 'package:flutter/foundation.dart';

@immutable
abstract class AuthUser {
  String? get email;
  String? get displayName;
  String get uid;
  String? get photoURL;
  DateTime? get creationTime;
  DateTime? get lastSignInTime;
  bool get isAnonymous;

  Future<String> getIdToken();

  Future<void> updateName(String name);

  Future<void> updatePhotoURL(String url);
}
