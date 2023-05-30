import 'package:skribbl/models/room.dart';

abstract class PlayerService {
  Future<void> getUser();

  Future<void> updateUser();

  Future<List<Room>> getPublicRooms(String token);

  /// TODO: Add more methods
}
