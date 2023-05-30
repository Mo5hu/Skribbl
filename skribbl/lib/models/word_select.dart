import 'package:flutter/foundation.dart';
import 'package:skribbl/models/hint.dart';

/// Model used by client to request a private room from server
@immutable
class WordSelect {
  final String word;
  final Hint hint;

  const WordSelect({
    required this.word,
    required this.hint,
  });

  factory WordSelect.fromMap(Map<String, dynamic> data) {
    return WordSelect(
      word: data['word'],
      hint: Hint.fromMap(data['hint']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'word': word,
      'hint': hint,
    };
  }

  List<Object?> get props => [
        word,
        hint,
      ];
}
