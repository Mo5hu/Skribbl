import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:skribbl/models/message.dart';

import 'package:skribbl/models/player.dart';
import 'package:skribbl/models/room.dart';
import 'package:skribbl/models/touch_points.dart';
import 'package:skribbl/services/auth_service.dart';
import 'package:skribbl/services/game_service.dart';
import 'package:skribbl/services/player_service.dart';
import 'package:skribbl/widgets/background_image_container.dart';
import 'package:skribbl/widgets/custom_painter.dart';
import 'package:skribbl/widgets/size_picker.dart';
import 'package:skribbl/widgets/color_picker.dart';

class PaintingScreen extends StatefulWidget {
  const PaintingScreen({Key? key, required this.room}) : super(key: key);
  final Room room;

  @override
  State<PaintingScreen> createState() => _PaintingScreenState();
}

class _PaintingScreenState extends State<PaintingScreen> {
  final gameServiceProvider = GetIt.instance<GameService>();

  final playerServiceProvider = GetIt.instance<PlayerService>();

  final authService = GetIt.instance<AuthService>();
  final _controller = PageController();
  Stream<Room>? roomsStream;

  Future<void> _animateTo(int index) async {
    await _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Screen Height: ${MediaQuery.of(context).size.height}\nScreen Width: ${MediaQuery.of(context).size.width}');
    roomsStream = gameServiceProvider.getRoomStream();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BackgroundImageContainer(
        child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _controller,
            scrollDirection: Axis.vertical,
            children: [
              StreamBuilder<Room>(
                  stream: roomsStream,
                  initialData: widget.room,
                  builder: (context, snapshot) {
                    Room? newRoom = widget.room;
                    List<Player> players = newRoom.players;
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.data != null) {
                        newRoom = snapshot.data;
                        players = newRoom!.players;
                        if (newRoom.gameInProgress!) {
                          _animateTo(1);
                        }
                      }
                    }
                    return Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(40, 0, 0, 0),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: 4,
                            color: const Color.fromARGB(240, 202, 206, 212),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: newRoom?.roomCode));
                                    const snackBar = SnackBar(
                                      content: Text('Copied to Clipboard'),
                                      duration: Duration(seconds: 1),
                                    );

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  },
                                  child: Text(
                                    'Code: ${newRoom.roomCode}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.person),
                                    Text(
                                      " ${players.length} / ${newRoom.numberOfPlayers}",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Expanded(
                              child: PlayerLobbyViewWidget(players: players),
                            ),
                            newRoom.partyLeader?.uid ==
                                    authService.currentUser?.uid
                                ? TextButton(
                                    onPressed: () {
                                      _animateTo(1);
                                      gameServiceProvider
                                          .startGame(widget.room.id);
                                    },
                                    child: const Text(
                                      "Start Game",
                                      style: TextStyle(color: Colors.white),
                                    ))
                                : Container()
                          ],
                        ));
                  }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: PlayerWidget(),
                    ),
                    Expanded(child: PaintingWidget(room: widget.room)),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: MessagingWidget(
                        room: widget.room,
                      ),
                    ),
                    // ----------------------------- Third Column Ended ! ------------------------
                  ],
                ),
              ),
            ]),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    gameServiceProvider.disconnect();
    super.dispose();
  }
}

class MessagingWidget extends StatefulWidget {
  const MessagingWidget({Key? key, required this.room}) : super(key: key);
  final Room room;

  @override
  _MessagingWidgetState createState() => _MessagingWidgetState();
}

class _MessagingWidgetState extends State<MessagingWidget> {
  final gameServiceProvider = GetIt.instance<GameService>();
  final playerServiceProvider = GetIt.instance<PlayerService>();
  final authService = GetIt.instance<AuthService>();

  Stream<List<Message>>? msgStream;

  TextEditingController messageFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    msgStream = gameServiceProvider.getMessageStream();
    return Column(
      mainAxisSize: MainAxisSize.min,
      // ----------------------------- Third Column Started ! ------------------------
      children: [
        Container(
          padding: const EdgeInsets.all(2.0),
          height: MediaQuery.of(context).size.height * 0.8,
          // width: MediaQuery.of(context).size.width * 0.25,
          width: 200,
          decoration: BoxDecoration(
            color: const Color.fromARGB(40, 0, 0, 0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              width: 4,
              color: const Color.fromARGB(240, 202, 206, 212),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8 - 62,
                // width: MediaQuery.of(context).size.width * 0.25 - 8,
                width: 200 - 8,
                child: StreamBuilder<List<Message>>(
                  stream: msgStream,
                  builder: (context, snapshot) {
                    var msgs = snapshot.data;
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }
                    if (snapshot.connectionState == ConnectionState.active &&
                        msgs != null) {
                      return ListView.builder(
                          itemCount: msgs.length,
                          itemBuilder: (context, _index) {
                            var message = msgs[_index];
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Container(
                                padding: const EdgeInsets.all(2.0),
                                decoration: _index % 2 == 0
                                    ? BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        color: const Color.fromARGB(
                                            140, 18, 96, 110),
                                      )
                                    : const BoxDecoration(),
                                child: Text(
                                  message.guessingState
                                      ? message.displayName! +
                                          ': Guessed the Word!'
                                      : message.displayName! +
                                          ': ' +
                                          message.message,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color.fromARGB(240, 149, 137, 94)),
                                ),
                              ),
                            );
                          });
                    }

                    return const CircularProgressIndicator();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  height: 40,
                  width: 200 - 8,
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color.fromARGB(255, 42, 76, 126),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        height: 20,
                        width: 200 - 70,
                        child: TextField(
                          textInputAction: TextInputAction.done,
                          onSubmitted: (userMessage) {
                            if (userMessage.isNotEmpty) {
                              gameServiceProvider.sendMessage(
                                  userMessage,
                                  widget.room,
                                  gameServiceProvider.getElapsedTime());
                            }
                            messageFieldController.clear();
                          },
                          controller: messageFieldController,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 149, 137, 94),
                          ),
                          maxLines: 1,
                          minLines: 1,
                          textAlignVertical: TextAlignVertical.bottom,
                          cursorColor: const Color.fromARGB(255, 149, 137, 94),
                          decoration: const InputDecoration(
                            hintText: 'Type there guess here...',
                            hintStyle: TextStyle(
                              fontSize: 10,
                              color: Color.fromARGB(255, 149, 137, 94),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Transform.rotate(
                        angle: 180 / 3.142 * 16,
                        child: IconButton(
                            onPressed: () {
                              var userMessage = messageFieldController.text;
                              if (userMessage.isNotEmpty) {
                                print('User Message: $userMessage');
                                gameServiceProvider.sendMessage(
                                    userMessage,
                                    widget.room,
                                    gameServiceProvider.getElapsedTime());
                              }
                              messageFieldController.clear();
                            },
                            padding: const EdgeInsets.all(0),
                            iconSize: 16,
                            icon: const Icon(Icons.send),
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // msgStream; TODO: Disporst MsgStream
    gameServiceProvider.disposeMessages();
    messageFieldController.dispose();
    super.dispose();
  }
}

class PaintingWidget extends StatefulWidget {
  const PaintingWidget({Key? key, required this.room}) : super(key: key);
  final Room room;

  @override
  _PaintingWidgetState createState() => _PaintingWidgetState();
}

class _PaintingWidgetState extends State<PaintingWidget> {
  final gameServiceProvider = GetIt.instance<GameService>();
  final playerServiceProvider = GetIt.instance<PlayerService>();
  final authService = GetIt.instance<AuthService>();

  StreamController<bool> erasePainting = StreamController<bool>.broadcast();
  int state = 105;
  int timeRemaining = 0;
  int? totalTime;
  Timer? _timer;
  bool turnStarted = false;

  bool eraseable = false;
  late final Stream<int> _gameState$;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _gameState$ = gameServiceProvider.getRoomStateStream();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Build Painting Widget');
    totalTime = gameServiceProvider.getRoom()!.drawTime;
    var currentTurnPlayerUID = gameServiceProvider.getRoom()?.turn?.uid;
    var authUserUID = authService.currentUser?.uid;
    return Stack(
      // ----------------------------- Second Column Started ! ------------------------
      children: [
        PainterWidget(),
        TimerWidget(),
        StreamBuilder<int>(
            stream: _gameState$,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  var state = snapshot.data;
                  if (state == 101) {
                    //  ------------------State 101-----------------
                    var room = gameServiceProvider.getRoom();
                    if (room != null) {
                      gameServiceProvider.eraseDrawing(true);
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color.fromARGB(220, 0, 0, 0),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              room.turn !=
                                      null // TODO: define or re-route room ki source
                                  ?
                                  // '${room.turn!.displayName} is ' +
                                  'Choosing a word'
                                  : 'Aynonmous is Choosing a word',
                              style: const TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 18),
                            ),
                          ),
                        ),
                      );
                    }
                  }

                  if (state == 1011) {
                    var wordList = gameServiceProvider.getWordList();
                    gameServiceProvider.eraseDrawing(true);
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color.fromARGB(220, 0, 0, 0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Choose a word',
                                style: TextStyle(
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                    fontSize: 18),
                              ),
                            ),
                          ),
                          Wrap(
                            direction: Axis.horizontal,
                            alignment: WrapAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: const Color.fromARGB(
                                        255, 250, 250, 250),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      gameServiceProvider.chooseWords(
                                          widget.room.id, wordList!.words[0]);
                                      setState(() {});
                                    },
                                    child: Text(
                                      wordList!.words[0],
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: const Color.fromARGB(
                                        255, 250, 250, 250),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      gameServiceProvider.chooseWords(
                                          widget.room.id, wordList.words[1]);
                                      setState(() {});
                                    },
                                    child: Text(
                                      wordList.words[1],
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: const Color.fromARGB(
                                        255, 250, 250, 250),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      gameServiceProvider.chooseWords(
                                          widget.room.id, wordList.words[2]);
                                      setState(() {});
                                    },
                                    child: Text(
                                      wordList.words[2],
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  if (state == 1031 || state == 103) {
                    var room = gameServiceProvider.getRoom();
                    var players = room!.players;
                    gameServiceProvider.eraseDrawing(true);
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color.fromARGB(220, 0, 0, 0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: Text(
                              'The word was : ${room.word}',
                              style: const TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: 280,
                            child: ListView.builder(
                                itemCount: players.length,
                                itemBuilder: ((context, index) {
                                  var player = players[index];
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            player.displayName ??
                                                'Guest-' +
                                                    player.uid.substring(
                                                        player.uid.length - 4),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                          player.prevRoundScore > 0
                                              ? Text(
                                                  '+ ' +
                                                      player.prevRoundScore
                                                          .toString(),
                                                  style: const TextStyle(
                                                      color: Colors.yellow,
                                                      fontSize: 14),
                                                )
                                              : const Text(
                                                  '0',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 14),
                                                )
                                        ]),
                                  );
                                })),
                          )
                        ],
                      ),
                    );
                  }
                  if (state == 104) {
                    var room = gameServiceProvider.getRoom();
                    var players = room!.players;

                    // TODO: Rematch
                    // Timer(const Duration(seconds: 5), () {
                    //   gameServiceProvider.rematch(room.id);
                    // });

                    final children = <Widget>[];
                    for (var index = 0; index < players.length; index++) {
                      children.add(
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircleAvatar(
                                        radius: 15,
                                        backgroundImage: NetworkImage(
                                          players[index].photoURL ??
                                              'https://avatars.dicebear.com/api/micah/${players[index].uid}.png',
                                        ),
                                      ),
                                    ),
                                    Text(
                                      players[index].displayName ??
                                          'Guest-' +
                                              players[index].uid.substring(
                                                  players[index].uid.length -
                                                      4),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),
                                index == 0
                                    ? Text(
                                        '#' + (index + 1).toString(),
                                        style: const TextStyle(
                                            color: Colors.yellow, fontSize: 20),
                                      )
                                    : index == 1
                                        ? Text(
                                            '#' + (index + 1).toString(),
                                            style: const TextStyle(
                                                color: Colors.blue,
                                                fontSize: 20),
                                          )
                                        : Text(
                                            '#' + (index + 1).toString(),
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 20),
                                          )
                              ]),
                        ),
                      );
                    }

                    return Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color.fromARGB(220, 0, 0, 0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Result',
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 18),
                            ),
                          ),
                          Wrap(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.spaceEvenly,
                              children: children),
                        ],
                      ),
                    );
                  }
                }
              }
              return Container();
            }),
      ],
      // ----------------------------- Second Column Ended ! ------------------------
    );
  }
}

class TimerWidget extends StatefulWidget {
  TimerWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  final gameServiceProvider = GetIt.instance<GameService>();
  final playerServiceProvider = GetIt.instance<PlayerService>();
  final authService = GetIt.instance<AuthService>();

  Timer? _timer;
  late final Stream<int> _gameState$;
  bool turnStarted = false;
  String? hint;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _gameState$ = gameServiceProvider.getRoomStateStream();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  late int timeRemaining;

  late int? totalTime;

  @override
  Widget build(BuildContext context) {
    totalTime = gameServiceProvider.getRoom()!.drawTime;
    return Stack(
      children: [
        HintWidget(
            hint: hint ?? '~ ~ ~ ~', gameServiceProvider: gameServiceProvider),
        StreamBuilder<int>(
            stream: _gameState$,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                var state = snapshot.data;
                if (state == 102 || state == 1021) {
                  var room = gameServiceProvider.getRoom();
                  if (!turnStarted) {
                    gameServiceProvider.eraseDrawing(false);
                    turnStarted = true;
                    timeRemaining = room!.drawTime;
                    Timer(Duration(seconds: room.drawTime), () {
                      // TODO: implement this somewhere else
                      turnStarted = false;
                      _timer?.cancel();
                      if (state == 1021) {
                        gameServiceProvider.startNextRound(room);
                      }
                    });
                  }
                  if (state == 1021) {
                    hint = gameServiceProvider.getWordSelected()?.word;
                    if (timeRemaining / totalTime! <= 0.76 &&
                        timeRemaining / totalTime! >= 0.74) {
                      gameServiceProvider.requestHint(
                          room!.id, gameServiceProvider.getWordSelected()!);
                    } else if (timeRemaining / totalTime! <= 0.51 &&
                        timeRemaining / totalTime! >= 0.49) {
                      gameServiceProvider.requestHint(
                          room!.id, gameServiceProvider.getWordSelected()!);
                    }
                  } else {
                    hint = gameServiceProvider.getWordSelected()?.hint.hint;
                  }
                  hint = convertWordToHint(hint!);
                  if (_timer != null && _timer!.isActive) {
                    _timer!.cancel();
                  }
                  _timer = Timer.periodic(const Duration(seconds: 1), ((timer) {
                    timeRemaining = timeRemaining - 1;
                    // if (!eraseable) {
                    //   points = [TouchPoints()];
                    // }
                    gameServiceProvider
                        .setElapsedTime(totalTime! - timeRemaining);
                    if (timeRemaining >= 0) {
                      setState(() {});
                    }
                  }));

                  return Positioned(
                    bottom: 8,
                    left: 8,
                    child: timeRemaining == 0
                        ? Container()
                        : CircularProgressIndicator(
                            value: timeRemaining / totalTime!,
                            strokeWidth: 4,
                            backgroundColor: Colors.black,
                            color: Colors.blueGrey,
                          ),
                  );
                }
              }
              return Container();
            }),
      ],
    );
  }

  String convertWordToHint(String handyHint) {
    List<String> word = [];
    for (int i = 0; i < handyHint.length; i++) {
      var hinty = handyHint;
      word.add(hinty.substring(i, i + 1));
    }
    handyHint = word.join(' ');
    return handyHint;
  }
}

class PainterWidget extends StatefulWidget {
  PainterWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<PainterWidget> createState() => _PainterWidgetState();
}

class _PainterWidgetState extends State<PainterWidget> {
  var authService = GetIt.instance<AuthService>();
  var gameServiceProvider = GetIt.instance<GameService>();

  late Stream<bool> eraseStream;

  Timer? _timer;
  Room? room;

  List<TouchPoints> drawPoints = [];
  TouchPoints? lastPoint;
  List<TouchPoints?>? points = [];

  late final Stream<dynamic> gameUpdates$;

  double selectedSize = 2;

  Color selectedColor = Color(0xFF000000);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Timer(Duration(milliseconds: 17), (() {}));
    eraseStream = gameServiceProvider.getDrawingEraseStream();
    gameUpdates$ = gameServiceProvider.getDrawingStream();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Build Painter Widget---------------------------------------------------------------');
    var room = gameServiceProvider.getRoom();
    var currentTurnPlayerUID = room?.turn?.uid;
    var authUserUID = authService.currentUser?.uid;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color.fromARGB(255, 230, 229, 226)),
      child: Stack(
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              if (gameServiceProvider.getRoom()?.turn?.uid ==
                  authService.currentUser?.uid) {
                var tp = TouchPoints(
                    paint: Paint()
                      ..color = selectedColor
                      ..strokeWidth = selectedSize
                      ..strokeCap = StrokeCap.round,
                    points: details.localPosition);
                gameServiceProvider.drawing({
                  'roomId': gameServiceProvider.getRoom()!.id,
                  'point': tp.toJson(),
                  'screenHeigth': MediaQuery.of(context).size.height,
                  'screenWidth': MediaQuery.of(context).size.width
                });
                setState(() {
                  drawPoints.add(tp);
                });
              }
            },
            onPanStart: (details) {
              if (gameServiceProvider.getRoom()?.turn?.uid ==
                  authService.currentUser?.uid) {
                var tp = TouchPoints(
                    paint: Paint()
                      ..color = selectedColor
                      ..strokeWidth = selectedSize
                      ..strokeCap = StrokeCap.round,
                    points: details.localPosition);
                gameServiceProvider.drawing({
                  'roomId': gameServiceProvider.getRoom()!.id,
                  'point': tp.toJson(),
                  'screenHeigth': MediaQuery.of(context).size.height,
                  'screenWidth': MediaQuery.of(context).size.width
                });
                setState(() {
                  drawPoints.add(tp);
                });
              }
            },
            onPanEnd: (details) {
              if (gameServiceProvider.getRoom()?.turn?.uid ==
                  authService.currentUser?.uid) {
                var tp = TouchPoints(
                    paint: Paint()
                      ..color = selectedColor
                      ..strokeWidth = selectedSize
                      ..strokeCap = StrokeCap.round,
                    points: null);
                gameServiceProvider.drawing({
                  'roomId': gameServiceProvider.getRoom()!.id,
                  'point': tp.toJson(),
                  'screenHeigth': MediaQuery.of(context).size.height,
                  'screenWidth': MediaQuery.of(context).size.width
                });
                setState(() {
                  drawPoints.add(tp);
                });
              }
            },
            child: SizedBox.expand(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: StreamBuilder<int>(
                    stream: gameServiceProvider.getRoomStateStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        var state = snapshot.data;
                        if (state == 101 ||
                            state == 1011 ||
                            state == 103 ||
                            state == 1031) {
                          drawPoints = [];
                        }
                        if (state == 1021) {
                          return CustomPaint(
                            size: Size.infinite,
                            painter: MyCustomPainter(
                              touchpoints: drawPoints,
                            ),
                          );
                        }
                        return StreamBuilder<dynamic>(
                          stream: gameUpdates$,
                          builder: (context, snapshot) {
                            points = snapshot.data;
                            return CustomPaint(
                              size: Size.infinite,
                              painter: MyCustomPainter(
                                touchpoints: points,
                              ),
                            );
                          },
                        );
                      }
                      return Container();
                    }),
              ),
            ),
          ),
          StreamBuilder<int>(
              stream: gameServiceProvider.getRoomStateStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.data == 1021) {
                    return Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: Colors.white,
                          ),
                          color: const Color.fromARGB(240, 18, 95, 109),
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(6),
                              bottomRight: Radius.circular(16),
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6)),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              child: const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Image(
                                  image: AssetImage(
                                    "assets/images/eraser.png",
                                  ),
                                  height: 28,
                                ),
                              ),
                              onTapUp: (details) {
                                gameServiceProvider.eraseDrawing(false);
                                setState(() {
                                  drawPoints = [];
                                });
                              },
                              onTapDown: (details) {
                                gameServiceProvider.eraseDrawing(true);
                              },
                            ),
                            IconButton(
                              onPressed: () {
                                colorSwitcher(context);
                              },
                              icon: const Image(
                                image: AssetImage(
                                  "assets/images/pencil.png",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }
                return Container();
              }),
        ],
      ),
    );
  }

  void colorSwitcher(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Size & Color'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Pencil sizes: '),
                  )),
              SizePicker(
                pickerSize: selectedSize,
                onSizeChanged: (size) {
                  setState(() {
                    selectedSize = size;
                  });
                },
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Colors: '),
                ),
              ),
              BlockPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  setState(() {
                    selectedColor = color;
                  });
                  // _socket.emit('color-change', map);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'))
        ],
      ),
    );
  }
}

class HintWidget extends StatelessWidget {
  const HintWidget(
      {Key? key, required this.gameServiceProvider, required this.hint})
      : super(key: key);

  final String hint;
  final GameService gameServiceProvider;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 4,
      left: 4,
      right: 4,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(4),
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Text(
          hint,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class PlayerWidget extends StatelessWidget {
  PlayerWidget({Key? key}) : super(key: key);
  var gameServiceProvider = GetIt.instance<GameService>();
  var playerServiceProvider = GetIt.instance<PlayerService>();
  var authService = GetIt.instance<AuthService>();
  Stream<Room>? roomsStream;
  @override
  Widget build(BuildContext context) {
    var room = gameServiceProvider.getRoom();
    List<Player> players = room!.players;
    roomsStream = gameServiceProvider.getRoomStream();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      // ----------------------------- First Column Started ! ------------------------
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                gameServiceProvider.leaveRoom(room);
                Navigator.pop(context);
              },
              icon: const Image(
                image: AssetImage(
                  "assets/images/enter.png",
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: room.roomCode));
                const snackBar = SnackBar(
                  content: Text('Copied to Clipboard'),
                  duration: Duration(seconds: 1),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Text(
                'Code: ${room.roomCode}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 60,
              width: 200,
              // width: MediaQuery.of(context).size.width * 0.25,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      "assets/images/player.png",
                    ),
                    fit: BoxFit.contain),
              ),
            ),
            Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: 200,
                // width: MediaQuery.of(context).size.width * 0.25,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(40, 0, 0, 0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    width: 4,
                    color: const Color.fromARGB(240, 202, 206, 212),
                  ),
                ),
                child: StreamBuilder<Room>(
                    stream: roomsStream,
                    initialData: room,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.data != null) {
                          var newRoom = snapshot.data;
                          players = newRoom!.players;
                        }
                      }
                      return PlayerListViewWidget(players: players);
                    })),
            // Material(
            //   color: Colors.transparent,
            //   child: Ink.image(
            //     image: const AssetImage(
            //       "assets/images/result.png",
            //     ),
            //     height: 60,
            //     width: 180,
            //     fit: BoxFit.contain,
            //     child: InkWell(
            //       onTap: () {
            //         gameServiceProvider.startGame(room.id);
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
      ],
      // ----------------------------- First Column Ended ! ------------------------
    );
  }
}

class PlayerListViewWidget extends StatelessWidget {
  const PlayerListViewWidget({
    Key? key,
    required this.players,
  }) : super(key: key);

  final List<Player> players;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: players.length,
        itemBuilder: (context, _index) {
          var player = players[_index];
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color.fromARGB(140, 18, 96, 110),
                ),
                child: ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (_index + 1).toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                      ),
                      CircleAvatar(
                          radius: 15,
                          backgroundImage: NetworkImage(player.photoURL ??
                              'https://avatars.dicebear.com/api/micah/${player.uid}.png'))
                    ],
                  ),
                  title: Text(
                    player.displayName ?? 'Anonymous',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  subtitle: Text(
                    "Points: ${player.points}",
                    style: const TextStyle(
                        color: Color.fromARGB(240, 149, 137, 94)),
                  ),
                )),
          );
        });
  }
}

class PlayerLobbyViewWidget extends StatelessWidget {
  const PlayerLobbyViewWidget({
    Key? key,
    required this.players,
  }) : super(key: key);

  final List<Player> players;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: players.length,
        itemBuilder: (context, _index) {
          var player = players[_index];
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color.fromARGB(140, 18, 96, 110),
                ),
                child: ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (_index + 1).toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                      ),
                      CircleAvatar(
                          radius: 15,
                          backgroundImage: NetworkImage(player.photoURL ??
                              'https://avatars.dicebear.com/api/micah/${player.uid}.png'))
                    ],
                  ),
                  title: Text(
                    player.displayName ?? 'Anonymous',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Games: ${player.totalGames}",
                        style: const TextStyle(
                            color: Color.fromARGB(240, 149, 137, 94)),
                      ),
                      Text(
                        "Win Percentage: ${player.totalWins == 0 ? 0 : (player.totalWins / player.totalGames * 100).toStringAsFixed(2)}",
                        style: const TextStyle(
                            color: Color.fromARGB(240, 149, 137, 94)),
                      ),
                    ],
                  ),
                )),
          );
        });
  }
}
