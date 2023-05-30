import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Model used by client to request a private room from server
@immutable
class RoomRequest extends Equatable {
  final int rounds;
  final int drawTime;
  final int numberOfPlayers;

  const RoomRequest({
    required this.rounds,
    required this.drawTime,
    required this.numberOfPlayers,
  });

  factory RoomRequest.fromMap(Map<String, dynamic> data) {
    return RoomRequest(
      rounds: data['rounds'],
      drawTime: data['drawTime'],
      numberOfPlayers: data['numberOfPlayers'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rounds': rounds,
      'drawTime': drawTime,
      'numberOfPlayers': numberOfPlayers,
    };
  }

  @override
  List<Object?> get props => [
        rounds,
        drawTime,
        numberOfPlayers,
      ];
}

/// ROUNDS, DRAW TIME, CAPACITY
/// TODO: maybe should be in remote config
const roundsPresets = [3, 5, 8];

const drawTimePresets = [45, 90, 125];

const capacityPresets = [4, 8, 12];
