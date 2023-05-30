import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class Player extends Equatable {
  final bool guessingState;

  final String uid;
  final String? displayName;
  final String? photoURL;

  final int points;
  final int totalGames;
  final int totalWins;
  final int prevRoundScore;

  const Player({
    required this.guessingState,
    required this.uid,
    required this.displayName,
    required this.photoURL,
    required this.points,
    required this.totalGames,
    required this.totalWins,
    required this.prevRoundScore,
  });

  factory Player.fromMap(Map<String, dynamic> data) {
    return Player(
      guessingState: data['guessingState'],
      uid: data['uid'],
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      points: data['points'],
      prevRoundScore: data['prevRoundScore'],
      totalGames: data['totalGames'],
      totalWins: data['totalWins'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'uid': uid,
      'points': points,
      'totalGames': totalGames,
      'totalWins': totalWins,
    };

    if (displayName != null) map['displayName'] = displayName;
    if (photoURL != null) map['photoURL'] = photoURL;

    return map;
  }

  @override
  List<Object?> get props => [
        uid,
        displayName,
        photoURL,
        points,
        totalGames,
        totalWins,
      ];
}
