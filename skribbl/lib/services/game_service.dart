// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:skribbl/models/message.dart';
import 'package:skribbl/models/room.dart';
import 'package:skribbl/models/room_request.dart';
import 'package:skribbl/models/touch_points.dart';
import 'package:skribbl/models/word_list.dart';
import 'package:skribbl/models/word_select.dart';

abstract class GameService {
  void connect(String token);

  void disconnect();

  void createRoom(BuildContext context, RoomRequest roomData);

  void joinRoom(BuildContext context, Room roomOfInterest);

  String joinRoomWithCode(BuildContext context, String roomCode);

  void leaveRoom(Room roomOfInterest);

  void sendMessage(String msg, Room room, int timeElapsed);

  void startNextRound(Room room);

  void drawing(Map<String, dynamic> data);

  void eraseDrawing(bool data);

  void guessing();

  void requestHint(String roomId, WordSelect word);

  void voting();

  void chooseWords(String roomId, String wordSelect);

  void startGame(String rooomId);

  void rematch(String roomId);

  Stream<List<Message>> getMessageStream();

  void disposeMessages();

  Stream<Room> getRoomStream();

  Stream<bool> getJoinRoomStateStream();

  Stream<List<TouchPoints>> getDrawingStream();

  Stream<bool> getDrawingEraseStream();

  Stream<WordList> getWordListStream();

  Stream<WordSelect> getWordSelectStream();

  Stream<int> getRoomStateStream();

  Room? getRoom();

  WordList? getWordList();

  WordSelect? getWordSelected();

  void setElapsedTime(int time);

  int getElapsedTime();

  String getJoinRoomError();

  void setSocketRequest(bool flag);

  bool getSocketRequest();

  Stream<bool> getSocketConnectionState();

  bool socketConnectedStatus();

  void setScreenSize(Size size);
}

/// Listeners Events

const WELCOME = "welcome"; //
const JOINED_ROOM = "room:joined"; //
const LEFT_ROOM = "room:left"; //
const ERROR_ROOM = "room:error"; //
const MESSAGE_RECEIVED = "message:received"; //
const TURN_CHANGE = "room:turnChange";
const WORDS_LIST = "game:wordsList"; //
const GAME_END = "game:end"; //
const GAME_STARTED = "game:started"; //
const ROUND_END = "game:roundEnd";
const SEND_HINT = "game:sendHint";
const POST_WORD_SELECT = "game:postWordSelect"; //
const DRAWING_DATA = "game:drawingData"; //
const WORD_SELECTED = "game:wordSelected"; //
const START_NEXT_TURN = "game:startNextTurn"; //
const GAME_PROGRESS = "game:gameProgress";
const ERASE_DATA = "game:eraseData";

/// Emitters

const CREATE_ROOM = "room:create";
const JOIN_ROOM = "room:join";
const LEAVE_ROOM = "room:leave";
const MESSAGE_SENT = "message:sent";
const DRAWING = "game:drawing";
const GUESSING = "game:guessing";
const HINTS = "game:hints";
const VOTING = "game:voting";
const CHOSE_WORD = "game:choseWord";
const DISCONNECT = "disconnect";
const START_GAME = "game:start";
const NEXT_ROUND = "game:nextRound";
const REMATCH = "game:rematch";
const ERASE = "game:erase";
