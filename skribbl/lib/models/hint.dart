import 'package:flutter/foundation.dart';

/// Model used by client to request a private room from server
@immutable
class Hint {
  final String hint;

  const Hint({
    required this.hint,
  });

  factory Hint.fromMap(String data) {
    return Hint(
      hint: data,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'hint': hint,
    };
  }

  List<Object?> get props => [
        hint,
      ];
}
