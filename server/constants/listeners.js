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

module.exports = {
  CREATE_ROOM,
  LEAVE_ROOM,
  MESSAGE_SENT,
  JOIN_ROOM,
  NEXT_ROUND,
  CHOSE_WORD,
  DRAWING,
  GUESSING,
  HINTS,
  START_GAME,
  VOTING,
  DISCONNECT,
  ERASE,
  REMATCH,
};
