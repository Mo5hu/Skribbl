const {
  MESSAGE_RECEIVED,
  WORDS_LIST,
  GAME_STARTED,
  POST_WORD_SELECT,
  SEND_HINT,
  WORD_SELECTED,
  START_NEXT_TURN,
  ROUND_END,
  DRAWING_DATA,
  GAME_END,
  GAME_PROGRESS,
  ERASE_DATA,
} = require("../constants/emitters");
const {
  HINTS,
  DRAWING,
  MESSAGE_SENT,
  NEXT_ROUND,
  START_GAME,
  CHOSE_WORD,
  REMATCH,
  ERASE,
} = require("../constants/listeners");
const {
  stringToObjectId,
  transformDoc,
  updateHint,
  replaceAlphaNumericWithUnderscores,
} = require("../utils");

const Room = require("../models/room");
const Player = require("../models/player");

const { getThreeWordList } = require("../services/getWord");
const { getUser } = require("../services/firebase-admin");

module.exports = (_io, socket) => {
  const {
    request: {
      user: { uid },
    },
  } = socket;

  const startGame = async (payload) => {
    try {
      const { roomId } = payload;
      let room = await Room.findOne({ _id: stringToObjectId(roomId) });

      room.currentEvent = `${START_GAME}`;
      room.turn = room.players[room.turnIndex];
      room.gameInProgress = true;
      room = await room.save();
      let i = 0;
      for await (const item of room.players) {
        let response = {};
        const user = await getUser(item.uid);
        Object.assign(response, item);
        Object.assign(response._doc, user);
        room.players[i] = response._doc;
        i++;
      }
      _io.to(roomId).emit(GAME_STARTED, {
        ...transformDoc(room),
      });
      const words = getThreeWordList();
      _io.to(room.turn.socketId).emit(WORDS_LIST, { player: room.turn, words });
    } catch (error) {
      throw new Error(error.message);
    }
  };

  const clientChoseWord = async ({ roomId, word }) => {
    try {
      let room = await Room.findOne({ _id: stringToObjectId(roomId) });
      room.word = word;
      room.currentEvent = `${CHOSE_WORD}`;
      room = await room.save();
      const hint = replaceAlphaNumericWithUnderscores(word);
      let i = 0;
      for await (const item of room.players) {
        let response = {};
        const user = await getUser(item.uid);
        Object.assign(response, item);
        Object.assign(response._doc, user);
        room.players[i] = response._doc;
        i++;
      }
      socket.to(roomId).emit(WORD_SELECTED, {
        hint,
        ...transformDoc(room),
      });
      _io.to(room.turn.socketId).emit(POST_WORD_SELECT, { word, hint });
    } catch (error) {
      throw new Error(error.message);
    }
  };

  const drawing = ({ roomId, ...payload }) => {
    try {
      _io.in(roomId).emit(DRAWING_DATA, {
        ...payload,
      });
    } catch (error) {
      throw new Error(error.message);
    }
  };

  const erase = ({ roomId, ...payload }) => {
    try {
      _io.in(roomId).emit(ERASE_DATA, {
        ...payload,
      });
    } catch (error) {
      throw new Error(error.message);
    }
  };

  const clientSentMessage = async (payload) => {
    const { message, roomId, elapsedTime } = payload;
    try {
      const room = await Room.findOne({ _id: stringToObjectId(roomId) });
      room.currentEvent = `${MESSAGE_SENT}`;
      // cater correctguess logic without sending word to guessing players
      const player = room.players.find(({ uid: playerId }) => playerId === uid);

      player.prevRoundScore = player.points;

      if (
        message === room.word &&
        player.guessingState === false &&
        room.turn.uid != player.uid
      ) {
        if (elapsedTime !== 0) {
          player.points += Math.round((200 / elapsedTime) * 10);
        }
        player.guessingState = true;
      }
      await room.save();
      const user = await getUser(uid);

      let response = {};

      Object.assign(response, player);
      Object.assign(response._doc, user);
      response = {
        message,
        ...response._doc,
      };
      _io.in(roomId).emit(MESSAGE_RECEIVED, {
        ...response,
      });
    } catch (error) {
      throw new Error(error.message);
    }
  };

  const clientRequestedHints = async ({ roomId, hint: previousHint, word }) => {
    try {
      let room = await Room.findOne({ _id: stringToObjectId(roomId) });
      room.currentEvent = `${HINTS}`;
      await room.save();
      _io.in(roomId).emit(SEND_HINT, {
        hint: updateHint(word, previousHint),
      });
    } catch (error) {
      throw new Error(error.message);
    }
  };
  function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
  const nextRound = async (payload) => {
    try {
      const { roomId } = payload;
      let room = await Room.findOne({ _id: stringToObjectId(roomId) });
      // room.players.forEach((item, index) => {
      //   const user = getUser(item.uid);
      //   item = Object.assign(item, user);
      // });
      room.currentEvent = `${NEXT_ROUND}`;
      if (room.gameInProgress) {
        const rounds = room.rounds;
        const incrementedTurnIndex = room.turnIndex + 1;
        let roundNumber = room.currentRound;
        room.turnIndex = incrementedTurnIndex % room.players.length;
        const nextPlayer = room.players[room.turnIndex];
        if (incrementedTurnIndex === room.players.length) {
          roundNumber = room.currentRound += 1;
        }

        if (roundNumber > rounds || !nextPlayer) {
          // delete room when game ends
          // leave room once game ends
          // room.isActive = false;
          const players = room.players;
          const winner = room.players.sort((a, b) => b.points - a.points)[0];
          for (const { uid } of players) {
            const playerModel = await Player.findOne({ uid });
            if (winner.uid === uid) playerModel.totalWins++;
            playerModel.totalGames++;
            await playerModel.save();
          }
          room.gameInProgress = false;
          room = await room.save();
          let i = 0;
          for await (const item of room.players) {
            let response = {};
            const user = await getUser(item.uid);
            Object.assign(response, item);
            Object.assign(response._doc, user);
            room.players[i] = response._doc;
            i++;
          }
          _io.in(roomId).emit(GAME_END, {
            ...transformDoc(room),
            winner,
          });

          return;
        }
        // handle turn change if drawer disconnects
        // during game player leaves
        // set iscorrectGuess field as false before every round

        room.turn = nextPlayer;
        room.players.forEach((item, index) => {
          item.guessingState = false;
        });

        room = await room.save();
        let i = 0;
        for await (const item of room.players) {
          let response = {};
          const user = await getUser(item.uid);
          Object.assign(response, item);
          Object.assign(response._doc, user);
          room.players[i] = response._doc;
          i++;
        }
        _io.in(roomId).emit(START_NEXT_TURN, {
          ...room,
        });

        const words = getThreeWordList();
        await sleep(2000);
        _io
          .to(room.turn.socketId)
          .emit(WORDS_LIST, { player: room.turn, words });
      } else {
        _io.in(roomId).emit(GAME_PROGRESS, "Game not in progress.");
      }
    } catch (error) {
      throw new Error(error.message);
    }
  };
  const rematch = async (payload) => {
    try {
      const { roomId } = payload;

      let room = await Room.findOne({ _id: stringToObjectId(roomId) });
      room.currentEvent = `${REMATCH}`;

      if (room.isActive) {
        room.turnIndex = 0;
        room.gameInProgress = true;
        room.currentRound = 1;
        room.turn = room.players[room.turnIndex];
        room = await room.save();
        let i = 0;
        for await (const item of room.players) {
          let response = {};
          const user = await getUser(item.uid);
          Object.assign(response, item);
          Object.assign(response._doc, user);
          room.players[i] = response._doc;
          i++;
        }
        _io.to(roomId).emit(GAME_STARTED, {
          ...transformDoc(room),
        });
        const words = getThreeWordList();
        _io
          .to(room.turn.socketId)
          .emit(WORDS_LIST, { player: room.turn, words });
      } else {
        _io.in(roomId).emit(GAME_PROGRESS, "Game in progress.");
      }
    } catch (error) {
      throw new Error(error.message);
    }
  };

  socket.on(MESSAGE_SENT, clientSentMessage);
  socket.on(START_GAME, startGame);
  socket.on(NEXT_ROUND, nextRound);
  socket.on(CHOSE_WORD, clientChoseWord);
  socket.on(DRAWING, drawing);
  socket.on(ERASE, erase);
  socket.on(HINTS, clientRequestedHints);
  socket.on(REMATCH, rematch);
};
