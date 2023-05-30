import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:skribbl/models/player.dart';

@immutable
class Room extends Equatable {
  final String roomCode;
  final String id;
  final int v;

  final int rounds;
  final String? currentEvent;
  final String? word;
  final String? hint;
  final int drawTime;

  final bool isActive;
  final bool isPublic;
  final bool isFull;
  final bool? gameInProgress;

  final int numberOfPlayers;
  final int currentRound;
  final int turnIndex;

  final Player? turn;
  final Player? partyLeader;
  final List<Player> players;

  const Room(
      {required this.roomCode,
      required this.rounds,
      required this.v,
      required this.drawTime,
      required this.isActive,
      required this.isPublic,
      required this.id,
      required this.currentRound,
      required this.isFull,
      required this.turn,
      required this.turnIndex,
      required this.partyLeader,
      required this.players,
      required this.hint,
      required this.numberOfPlayers,
      required this.gameInProgress,
      required this.currentEvent,
      required this.word});

  factory Room.fromMap(Map<String, dynamic> data) {
    // final turn = data.containsKey('turn') ? Player.fromMap(data['turn']) : null;
    final partyLeader = data.containsKey('partyLeader')
        ? Player.fromMap(data['partyLeader'])
        : null;

    final turn = data.containsKey('turn') ? Player.fromMap(data['turn']) : null;

    final players = data.containsKey('players')
        ? (data['players'] as List)
            .map(
              (e) => Player.fromMap(Map<String, dynamic>.from(e)),
            )
            .toList()
        : <Player>[];

    return Room(
        roomCode: data['roomCode'],
        rounds: data['rounds'],
        id: data['_id'],
        drawTime: data['drawTime'],
        isActive: data['isActive'],
        isPublic: data['isPublic'],
        v: data['__v'],
        currentRound: data['currentRound'],
        turnIndex: data['turnIndex'],
        turn: turn,
        gameInProgress: data['gameInProgress'],
        partyLeader: partyLeader,
        players: players,
        hint: data['hint'],
        numberOfPlayers: data['numberOfPlayers'],
        word: data['word'],
        currentEvent: data['currentEvent'],
        isFull: data['isFull']);
  }

  Map<String, dynamic> roomIdToMap() {
    return {
      'roomId': id,
    };
  }

  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }

  @override
  List<Object?> get props => [
        roomCode,
        rounds,
        id,
        drawTime,
        isActive,
        isPublic,
        isFull,
        currentRound,
        turnIndex,
        partyLeader,
        players,
        v,
        turn
      ];
}
