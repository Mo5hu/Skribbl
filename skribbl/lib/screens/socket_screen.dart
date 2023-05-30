// ignore_for_file: avoid_print
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class SocketScreen extends StatefulWidget {
  const SocketScreen({Key? key}) : super(key: key);

  @override
  _SocketScreenState createState() => _SocketScreenState();
}

class _SocketScreenState extends State<SocketScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: streamSocket.getResponse,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasError) return Text(snapshot.error.toString());

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator.adaptive();
          }

          return Column(
            children: [
              Text(snapshot.data ?? 'no'),
              ElevatedButton(
                onPressed: () {},
                child: const Text('SEND'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// STEP1:  Stream setup
class StreamSocket {
  final _socketResponse = StreamController<String>();

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}

StreamSocket streamSocket = StreamSocket();

//STEP2: Add this function in main function in main.dart file and add incoming data to the stream
socket_io.Socket connectAndListen(String token) {
  socket_io.Socket socket = socket_io.io(
    'http://localhost:3000',
    socket_io.OptionBuilder()
        // .setTransports(['websocket'])
        .disableAutoConnect()
        .setExtraHeaders({'Authorization': 'Bearer $token'}).build(),
  );

  socket.connect();

  socket.onConnect((_) {
    print('connect');
    socket.emit('msg', 'test');
  });

  //When an event recieved from server, data is added to the stream
  socket.on('event', (data) => streamSocket.addResponse);
  socket.on('welcome', (data) {
    print(data);
    return streamSocket.addResponse;
  });
  socket.on('word-guessed', (data) => streamSocket.addResponse);
  socket.on('event', (data) => streamSocket.addResponse);

  socket.onDisconnect((_) => print('disconnect'));

  return socket;
}
