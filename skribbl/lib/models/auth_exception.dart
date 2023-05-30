import 'package:firebase_core/firebase_core.dart';

abstract class AuthException implements Exception {
  final String code;
  final String? message;

  const AuthException({
    required this.code,
    this.message,
  });
}

class FirebaseExceptionImpl implements AuthException {
  final FirebaseException _exception;
  FirebaseExceptionImpl(FirebaseException exception) : _exception = exception;

  @override
  String get code => _exception.code.replaceAll('-', ' ');

  @override
  String? get message => _exception.message;
}
