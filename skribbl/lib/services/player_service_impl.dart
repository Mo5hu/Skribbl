import 'dart:convert';

import 'package:skribbl/models/player.dart';
import 'package:skribbl/models/room.dart';
import 'package:skribbl/services/player_service.dart';
import 'package:http/http.dart' as http;
import 'package:skribbl/uri/server_address.dart';

class PlayerServiceImpl implements PlayerService {
  Player? player;

  @override
  Future<List<Room>> getPublicRooms(String token) async {
    print(token);
    final result = await http.get(
      Uri.http(authority, "rooms"),
      headers: {"Authorization": "Bearer $token"},
    );
    print(result.body);
    Map mapOfRooms = jsonDecode(result.body);
    var rooms = mapOfRooms.containsKey('rooms')
        ? (mapOfRooms['rooms'] as List)
            .map(
              (e) => Room.fromMap(Map<String, dynamic>.from(e)),
            )
            .toList()
        : <Room>[];
    return rooms;
  }

  @override
  Future<void> getUser() {
    // TODO: implement getUser
    throw UnimplementedError();
  }

  @override
  Future<void> updateUser() {
    // TODO: implement updateUser
    throw UnimplementedError();
  }
}
