import 'package:flutter/foundation.dart';
import 'package:skribbl/models/player.dart';

/// Model used by client to request a private room from server
@immutable
class WordList {
  final words;
  final Player player;

  const WordList({
    required this.words,
    required this.player,
  });

  factory WordList.fromMap(Map<String, dynamic> data) {
    return WordList(
      words: data['words'],
      player: Player.fromMap(data['player']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'words': words,
      'player': player,
    };
  }

  List<Object?> get props => [
        words,
        player,
      ];
}
