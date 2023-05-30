import 'package:flutter/material.dart';

class RoomInfoListTile extends StatelessWidget {
  const RoomInfoListTile({
    Key? key,
    required this.roomName,
    required this.roomDetails,
  }) : super(key: key);

  final String roomName;
  final String roomDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: const Color(0xFF0D7280).withOpacity(0.71),
      child: ListTile(
        textColor: Colors.white,
        // leading: Icon(Icons.login),
        leading: Image.asset('assets/images/enter_room.png'),
        title: Text(roomName),
        trailing: Text(roomDetails),
      ),
    );
  }
}
