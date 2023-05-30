// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:skribbl/models/hint.dart';
import 'package:skribbl/models/message.dart';
import 'package:skribbl/models/new_offset.dart';
import 'package:skribbl/models/room.dart';
import 'package:skribbl/models/room_request.dart';
import 'package:skribbl/models/touch_points.dart';
import 'package:skribbl/models/word_list.dart';
import 'package:skribbl/models/word_select.dart';
import 'package:skribbl/screens/painting_screen.dart';
import 'package:skribbl/services/auth_service.dart';
import 'package:skribbl/services/game_service.dart';
import 'package:skribbl/uri/server_address.dart';
import 'package:skribbl/widgets/loading_widget.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class GameServiceImpl implements GameService {
  var authService = GetIt.instance<AuthService>();

  late Size screenSize;
  List<TouchPoints> points = [];
  List<Message> messages = [];
  bool socketConnected = false;
  bool socketConnectionRequested = false;
  Room? room;
  WordList? wordList;
  WordSelect? wordSeleted;
  int elapsedTime = 0;
  bool erase = false;
  String joinRoomError = '';
  final _socketConnectionStreamController = StreamController<bool>.broadcast();
  final _messageStreamController = StreamController<List<Message>>.broadcast();
  final _roomStreamController = StreamController<Room>.broadcast();
  final _drawingEraseController = StreamController<bool>.broadcast();
  final _drawingStreamController =
      StreamController<List<TouchPoints>>.broadcast();
  final _wordListStreamController = StreamController<WordList>.broadcast();
  final _wordSelectStreamController = StreamController<WordSelect>.broadcast();
  final _roomStateStreamController = StreamController<int>.broadcast();
  final _joinRoomStateStreamController = StreamController<bool>.broadcast();

  //State List: 4th digit 1 for drawer
  // 101- start game (Game Started) ((Turn Not null) Player) Drawing ... and Drawer: (Game: Word List) (choose Word)
  // 102- Word Seleted All player: Word Selected, start timer (Hint and Word recieved) guessing and requesting hints
  // 103- round end stats for this round updated, player score updated and then next event will be pushed
  // 101- Next turn Word List will be pushed on to the turn user.
  // 104- Game End
  // 105- waiting for game to start

  /// Store a socket connection here
  late socket_io.Socket _socket;

  @override
  void connect(String token) {
    var options = socket_io.OptionBuilder().setExtraHeaders(
      {'Authorization': 'Bearer $token'},
    ).disableAutoConnect();

    if (!kIsWeb) {
      options = options.setTransports(['websocket']);
    }

    _socket = socket_io.io(uri, options.build());

    _socket.connect();
    print('connect socket');
    _setListeners();
  }

  /// set listeners

  void _setListeners() {
    _socket.onConnect(
      (data) {},
    );

    _socket.on("connect", (data) {
      print('socket on connect' + data.toString());
      socketConnected = true;
      // socketConnectionRequested = false;
      _socketConnectionStreamController.add(true);
    });

    _socket.on("disconnect", (data) {
      print('socket on disconnect' + data.toString());
      socketConnected = false;
      _socketConnectionStreamController.add(false);
    });

    _socket.onError((data) {
      print('onError: ' + data.toString());
    });

    _socket.on(ERROR_ROOM, (data) {
      print('Room Join Error: $data');
      joinRoomError = data['message'].toString();
      _joinRoomStateStreamController.add(false);
    });

    _socket.on(WELCOME, (data) {
      print('welcome: ' + data.toString());
    });

    _socket.on("connect_error", (data) => print('Socket Connect Error: $data'));

    _socket.on(JOINED_ROOM, (data) {
      print('roomJoined: ' + data.toString());
      room = Room.fromMap(data);
      _roomStreamController.add(Room.fromMap(data));

      // if (room?.partyLeader?.uid == authService.currentUser?.uid &&
      //     !room!.gameInProgress!) {
      //   startGame(room!.id);
      // }
      // print(
      //     'partyleader UID: ${room?.partyLeader?.uid} Current User UID: ${authService.currentUser?.uid} Game in Progress: ${room!.gameInProgress!}');
    });

    _socket.on(LEFT_ROOM, (data) {
      print('roomLeft: ' + data.toString());
      room = Room.fromMap(data);
      _roomStreamController.add(Room.fromMap(data));
    });

    // _socket.on(TURN_CHANGE, (data) {
    //   print('Turn Change: ' + data.toString());
    //   _roomStreamController.add(Room.fromMap(data));
    // });

    _socket.on(WORDS_LIST, (data) {
      print('Words List: ' + data.toString());
      wordList = WordList.fromMap(data);
      // _wordListStreamController.add(WordList.fromMap(data));
      _roomStateStreamController.add(1011);
      elapsedTime = 0;
    });

    _socket.on(GAME_STARTED, (data) {
      print('Game Started: ' + data.toString());
      room = Room.fromMap(data);
      _roomStreamController.add(Room.fromMap(data));
      Timer(Duration(seconds: 1), () {
        if (authService.currentUser?.uid != room?.turn?.uid) {
          _roomStateStreamController.add(101);
        }
      });
      elapsedTime = 0;
    });

    _socket.on(SEND_HINT, (data) {
      print('Send Hint: ' + data.toString());
      wordSeleted =
          WordSelect(word: wordSeleted!.word, hint: Hint.fromMap(data['hint']));
    });

    _socket.on(
      WORD_SELECTED,
      (data) {
        print('Word Seleted: ' + data.toString());
        room = Room.fromMap(data);
        _roomStreamController.add(Room.fromMap(data));
        wordSeleted =
            WordSelect(word: room!.word!, hint: Hint(hint: room!.hint!));
        _roomStateStreamController.add(102);
        elapsedTime = 0;
      },
    );

    _socket.on(POST_WORD_SELECT, (data) {
      print('Post Word Select: ' + data.toString());
      wordSeleted = WordSelect.fromMap(data);
      _roomStateStreamController.add(1021);
      elapsedTime = 0;
    });

    _socket.on(START_NEXT_TURN, (data) {
      print('Start Next Turn: ' + data.toString());
      room = Room.fromMap(data['_doc']);
      // TODO: player score updation check
      _roomStreamController.add(Room.fromMap(data['_doc']));
      var usrUid = authService.currentUser?.uid;
      if (room!.turn!.uid == usrUid) {
        _roomStateStreamController.add(1031);
      } else {
        _roomStateStreamController.add(103);
        // TODO: check this again
        Timer(const Duration(seconds: 2), () {
          _roomStateStreamController.add(101);
        });
      }
    });

    _socket.on(GAME_END, (data) {
      print('Game End: ' + data.toString());
      room = Room.fromMap(data);
      _roomStateStreamController.add(104);
    });

    _socket.on(ROUND_END, (data) {
      print('Round End: ' + data.toString());
      _roomStreamController.add(data);
    });

    _socket.on(MESSAGE_RECEIVED, (data) {
      print(data.toString());
      messages.add(Message.fromMap(data));
      _messageStreamController.add(messages);
    });

    _socket.on(DRAWING_DATA, (data) {
      print("Drawing data recieved: " + data.toString());
      if (data['point'] != null) {
        TouchPoints point = TouchPoints.fromMap(data['point']);
        if (point.points != null && point.points?.dx != 0) {
          print('point before: ' + point.points.toString());
          double screenWidth = data['screenWidth'].toDouble();
          double screenHeight = data['screenHeigth'].toDouble();
          var widthScaleRatio = (screenSize.width - 432) / (screenWidth - 432);
          var heigthScaleRatio = (screenSize.height) / (screenHeight);
          print(
              'widthScaleRatio = ${(screenSize.width - 432) / (screenWidth - 432)}');
          print('heightScaleRatio = ${screenSize.height / screenHeight}');
          point = TouchPoints(
              paint: point.paint,
              points: Offset(point.points!.dx * widthScaleRatio,
                  point.points!.dy * heigthScaleRatio));
          print('point After: ' + point.points.toString());
        }
        points.add(point);
        _drawingStreamController.add(points);
      }
    });

    _socket.on(ERASE_DATA, (data) {
      print('Erase Drawing Reciving Data: ' + data.toString());
      points = [];
      _drawingStreamController.add(points);
    });
  }

  @override
  void createRoom(BuildContext context, RoomRequest roomData) {
    final data = roomData.toMap();
    print('Room Data: ' + data.toString());
    _socket.emitWithAck(CREATE_ROOM, data, ack: (res) {
      room = Room.fromMap(res);
      print('Room Created' + res.toString());
      _roomStreamController.add(room!);
      Navigator.of(context).pop();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaintingScreen(room: room!),
          ));
    });
  }

  @override
  void joinRoom(BuildContext context, Room roomOfInterest) {
    final data = roomOfInterest.roomIdToMap();
    _socket.emitWithAck(
      JOIN_ROOM,
      data,
      ack: (res) {
        print('Room Joined: ' + res.toString());
        room = Room.fromMap(res);
        _roomStreamController.add(room!);
        // TODO: check this
        // LoadingWidget();
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaintingScreen(room: room!),
            ));
      },
    );
  }

  @override
  String joinRoomWithCode(BuildContext context, String roomCode) {
    final data = {'roomCode': roomCode};
    _socket.emitWithAck(
      JOIN_ROOM,
      data,
      ack: (res) {
        if (res != null) {
          room = Room.fromMap(res);
          print('Room Joined with Code: ' + res.toString());
          _roomStreamController.add(room!);
          // TODO: check this
          // LoadingWidget();
          Navigator.of(context).pop();
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaintingScreen(room: room!),
              ));
        } else {
          print('Join room with code failed due to wrong code');
          return 'Wrong Code';
        }
      },
    );
    return 'Loading...';
  }

  @override
  void leaveRoom(Room roomOfInterest) {
    final data = roomOfInterest.roomIdToMap();
    _socket.emitWithAck(LEAVE_ROOM, data, ack: (res) {
      print(res.toString());
      _roomStreamController.add(Room.fromMap(res));
      messages = [];
    });
  }

  @override
  void sendMessage(String msg, Room room, int timeElapsed) {
    elapsedTime = timeElapsed;
    final data = <String, dynamic>{
      'message': msg,
      'roomId': room.id,
      'elapsedTime': elapsedTime
    };
    _socket.emit(MESSAGE_SENT, data);
  }

  @override
  void rematch(String roomId) {
    final data = <String, dynamic>{'roomId': roomId};
    _socket.emit(REMATCH, data);
  }

  @override
  void chooseWords(String roomId, String wordSelect) {
    final data = <String, dynamic>{'roomId': roomId, 'word': wordSelect};
    _socket.emitWithAck(CHOSE_WORD, data, ack: (res) {
      print('ChooseWords Response: ' + res.toString());
    });
  }

  @override
  void drawing(Map<String, dynamic> data) {
    print('Drawing object: $data');
    _socket.emit(DRAWING, data);
  }

  @override
  void eraseDrawing(bool data) {
    final dataJson = <String, dynamic>{'roomId': room?.id, 'bool': data};
    print('Erase Drawing Sending Data : $dataJson');
    _socket.emit(ERASE, dataJson);
  }

  @override
  void guessing() {
    // TODO: implement guessing
  }

  @override
  void requestHint(String roomId, WordSelect word) {
    final data = <String, dynamic>{
      'roomId': roomId,
      'hint': word.hint.hint,
      'word': word.word
    };
    _socket.emit(HINTS, data);
  }

  @override
  void startGame(String roomId) {
    final data = <String, dynamic>{'roomId': roomId};
    _socket.emit(START_GAME, data);
  }

  @override
  void startNextRound(Room room) {
    final data = <String, dynamic>{'roomId': room.id};
    _socket.emit(NEXT_ROUND, data);
  }

  @override
  void voting() {
    // TODO: implement voting
  }

  @override
  void disconnect() {
    _socket.dispose();
  }

  @override
  Stream<List<Message>> getMessageStream() => _messageStreamController.stream;

  @override
  void disposeMessages() {
    messages = [];
  }

  @override
  Stream<Room> getRoomStream() => _roomStreamController.stream;

  @override
  Stream<List<TouchPoints>> getDrawingStream() =>
      _drawingStreamController.stream;

  @override
  Stream<bool> getDrawingEraseStream() => _drawingEraseController.stream;

  @override
  Stream<WordList> getWordListStream() => _wordListStreamController.stream;

  @override
  Stream<WordSelect> getWordSelectStream() =>
      _wordSelectStreamController.stream;

  @override
  Stream<int> getRoomStateStream() => _roomStateStreamController.stream;

  @override
  Stream<bool> getJoinRoomStateStream() =>
      _joinRoomStateStreamController.stream;

  @override
  Room? getRoom() => room;

  @override
  WordList? getWordList() => wordList;

  @override
  WordSelect? getWordSelected() => wordSeleted;

  @override
  Stream<bool> getSocketConnectionState() =>
      _socketConnectionStreamController.stream;

  @override
  bool socketConnectedStatus() => socketConnected;

  @override
  int getElapsedTime() {
    return elapsedTime;
  }

  @override
  void setElapsedTime(int time) {
    elapsedTime = time;
  }

  @override
  String getJoinRoomError() {
    return joinRoomError;
  }

  @override
  bool getSocketRequest() {
    return socketConnectionRequested;
  }

  @override
  void setSocketRequest(bool flag) {
    socketConnectionRequested = flag;
  }

  @override
  void setScreenSize(Size size) {
    screenSize = size;
  }
}
