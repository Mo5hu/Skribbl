const { customAlphabet } = require("nanoid");
const {
  JOINED_ROOM,
  LEFT_ROOM,
  START_NEXT_TURN,
  ROUND_END,
  WORDS_LIST,
  GAME_END,
  GAME_NOT_IN_PROGRESS,
} = require("../constants/emitters");
const {
  JOIN_ROOM,
  CREATE_ROOM,
  DRAWING,
  ERASE,
  LEAVE_ROOM,
  DISCONNECT,
} = require("../constants/listeners");
const {
  stringToObjectId,
  getRandomPlayerIndex,
  transformDoc,
} = require("../utils");
const { getThreeWordList } = require("../services/getWord");
const { getUser } = require("../services/firebase-admin");

const Room = require("../models/room");
const Player = require("../models/player");
const gameHandler = require("../handlers/gameHandlers");
const NON_EXISTENT_ROOM = "Room does not exist!";
const MIDDLEWARE_IGNORED_EVENTS = [CREATE_ROOM];

const ALPHANUMERIC = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ";

module.exports = (_io, socket) => {
  const {
    request: {
      user: { uid },
    },
    id: socketId,
  } = socket;

  const createRoom = async (payload, callback) => {
    try {
      let player = await Player.findOne({ uid });
      if (!player) player = new Player({ uid });
      player.socketId = socketId;
      await player.save();

      const nanoid = customAlphabet(ALPHANUMERIC, 6);
      const newRoom = await new Room({
        ...payload,
        roomCode: nanoid(),
        players: [player],
        partyLeader: player,
      }).save();
      let i = 0;
      for await (const item of newRoom.players) {
        let response = {};
        const user = await getUser(item.uid);
        Object.assign(response, item);
        Object.assign(response._doc, user);
        newRoom.players[i] = response._doc;
        i++;
      }
      socket.join(newRoom._id.toString());
      callback({
        ...transformDoc(newRoom),
        status: "Room Created!",
      });
    } catch (error) {
      throw new Error(error.message);
    }
  };

  const clientJoinedRoom = async ({ roomId, roomCode }, callback) => {
    try {
      let player = await Player.findOne({ uid });
      if (!player) player = new Player({ uid, socketId });
      player.socketId = socketId;
      await player.save();

      let status = "Room is full!";
      let updatedRoom;
      let room = await Room.findOne({
        $or: [{ _id: stringToObjectId(roomId) }, { roomCode }],
      });

      if (!room) status = NON_EXISTENT_ROOM;

      if (!roomId) roomId = room._id.toString();

      if (!room.isFull) {
        status = "Room joined!";
        updatedRoom = await Room.findOneAndUpdate(
          {
            $or: [{ _id: stringToObjectId(roomId) }, { roomCode }],
            "players.uid": { $ne: uid },
          },
          { $addToSet: { players: player } },
          {
            new: true,
            useFindAndModify: false,
          }
        );
        if (updatedRoom) {
          const isRoomFull =
            updatedRoom.players.length === room.numberOfPlayers;
          if (isRoomFull) {
            room.isFull = true;
            updatedRoom.isFull = true;
          }

          room = await room.save();
          let i = 0;
          for await (const item of updatedRoom.players) {
            let response = {};
            const user = await getUser(item.uid);
            Object.assign(response, item);
            Object.assign(response._doc, user);
            updatedRoom.players[i] = response._doc;
            i++;
          }
          const user = await getUser(uid);

          socket.to(roomId).emit(JOINED_ROOM, {
            ...transformDoc(updatedRoom),
            user,
            status: `${user.displayName} just joined!`,
          });
        }
      }

      socket.join(roomId);

      if (room.players.some(({ uid: playerId }) => playerId === uid))
        status = "Room already joined!";

      callback({
        ...transformDoc(updatedRoom || room),
        status,
      });
    } catch (error) {
      throw new Error(error.message);
    }
  };

  const clientLeftRoom = async ({ roomId }) => {
    try {
      const room = await Room.findOne({
        $or: [
          { _id: stringToObjectId(roomId) },
          { "players.uid": { $eq: uid } },
        ],
      });

      if (!room) return;

      if (!roomId) roomId = room._id.toString();

      const data = {};
      let playerToPull = uid;
      const isPartyLeader = room.partyLeader.uid === uid;

      if (isPartyLeader && room.players.length >= 1) {
        room.players = room.players.filter(
          ({ uid: leaderId }) => leaderId !== uid
        );
        const newLeader =
          room.players[getRandomPlayerIndex(room.players.length)];
        data.partyLeader = newLeader;
      }
      console.log("room.players.length: ", room.players.length);

      console.log("left room: ", data.partyLeader);
      if (!data.partyLeader && !room.players.length) {
        data.isActive = false;
        await Room.deleteOne({ _id: stringToObjectId(roomId) });
        _io.socketsLeave(roomId);
        return;
      }

      data.$pull = {
        players: { uid: playerToPull },
      };

      let updatedRoom = await Room.findOneAndUpdate({ _id: roomId }, data, {
        new: true,
        useFindAndModify: false,
      });
      if (
        updatedRoom.players.length === 1 &&
        updatedRoom.gameInProgress === true
      ) {
        const players = updatedRoom.players;
        const winner = updatedRoom.players.sort(
          (a, b) => b.points - a.points
        )[0];
        for (const { uid } of players) {
          const playerModel = await Player.findOne({ uid });
          if (winner.uid === uid) playerModel.totalWins++;
          playerModel.totalGames++;
          await playerModel.save();
        }
        updatedRoom.gameInProgress = false;
        updatedRoom = await updatedRoom.save();
        const user = await getUser(uid);
        let i = 0;
        for await (const item of updatedRoom.players) {
          let response = {};
          const user2 = await getUser(item.uid);
          Object.assign(response, item);
          Object.assign(response._doc, user2);
          updatedRoom.players[i] = response._doc;
          i++;
        }
        _io.in(roomId).emit(LEFT_ROOM, {
          status: `${user.displayName} just left!`,
          user,
          ...transformDoc(updatedRoom),
        });
        _io.in(roomId).emit(GAME_END, {
          ...transformDoc(updatedRoom),
          winner,
        });
        socket.leave(roomId);
      } else {
        const left = await getUser(uid);
        let i = 0;
        for await (const item of updatedRoom.players) {
          let response = {};
          const user = await getUser(item.uid);
          Object.assign(response, item);
          Object.assign(response._doc, user);
          updatedRoom.players[i] = response._doc;
          i++;
        }
        _io.in(roomId).emit(LEFT_ROOM, {
          status: `${left.displayName} just left!`,
          left,
          ...transformDoc(updatedRoom),
        });
        socket.leave(roomId);
        //condition if current turn player leaves
        if (updatedRoom.gameInProgress) {
          if (updatedRoom.turn.uid == uid) {
            nextRound(updatedRoom._id);
          }
        }
      }
    } catch (error) {
      throw new Error(error.message);
    }
  };
  function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
  const nextRound = async (roomId) => {
    try {
      let room = await Room.findOne({ _id: stringToObjectId(roomId) });

      if (room.gameInProgress) {
        room.currentEvent = "game:nextRound";
        const rounds = room.rounds;
        const incrementedTurnIndex = room.turnIndex + 1;
        let roundNumber = room.currentRound;
        room.turnIndex = incrementedTurnIndex % room.players.length;
        const nextPlayer = room.players[room.turnIndex];
        if (incrementedTurnIndex === room.players.length) {
          // _io.in(roomId).emit(ROUND_END, { room, stats: room.players });
          roundNumber = room.currentRound += 1;
        }

        if (roundNumber > rounds || !nextPlayer) {
          // delete room when game ends
          // leave room once game ends
          // room.isActive = false;
          const players = room.players;
          const winner = room.players.sort((a, b) => (a.points = b.points))[0];
          for (const { uid } of players) {
            const playerModel = await Player.findOne({ uid });
            if (winner.uid === uid) playerModel.totalWins++;
            playerModel.totalGames++;
            await playerModel.save();
          }
          console.log(winner);
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
          console.log(winner);
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
        _io.in(roomId).emit(GAME_NOT_IN_PROGRESS, "Game not in progress.");
      }
    } catch (error) {
      throw new Error(error.message);
    }
  };

  const disconnect = async () => {
    try {
      const room = await Room.findOne({
        "players.uid": { $eq: uid },
      });

      if (!room) return;

      let roomId = room._id.toString();

      const data = {};
      let playerToPull = uid;
      const isPartyLeader = room.partyLeader.uid === uid;

      if (isPartyLeader && room.players.length >= 1) {
        room.players = room.players.filter(
          ({ uid: leaderId }) => leaderId !== uid
        );
        const newLeader =
          room.players[getRandomPlayerIndex(room.players.length)];
        data.partyLeader = newLeader;
      }

      if (!data.partyLeader && !room.players.length) {
        data.isActive = false;
        await Room.deleteOne({ _id: stringToObjectId(roomId) });
        _io.socketsLeave(roomId);
        return;
      }

      data.$pull = {
        players: { uid: playerToPull },
      };

      let updatedRoom = await Room.findOneAndUpdate({ _id: roomId }, data, {
        new: true,
        useFindAndModify: false,
      });
      if (
        updatedRoom.players.length === 1 &&
        updatedRoom.gameInProgress === true
      ) {
        const players = updatedRoom.players;
        const winner = updatedRoom.players.sort(
          (a, b) => b.points - a.points
        )[0];
        for (const { uid } of players) {
          const playerModel = await Player.findOne({ uid });
          if (winner.uid === uid) playerModel.totalWins++;
          playerModel.totalGames++;
          await playerModel.save();
        }
        updatedRoom.gameInProgress = false;
        updatedRoom = await updatedRoom.save();
        const user = await getUser(uid);
        let i = 0;
        for await (const item of updatedRoom.players) {
          let response = {};
          const user2 = await getUser(item.uid);
          Object.assign(response, item);
          Object.assign(response._doc, user2);
          updatedRoom.players[i] = response._doc;
          i++;
        }
        _io.in(roomId).emit(LEFT_ROOM, {
          status: `${user.displayName} just left!`,
          user,
          ...transformDoc(updatedRoom),
        });
        _io.in(roomId).emit(GAME_END, {
          ...transformDoc(updatedRoom),
          winner,
        });
        socket.leave(roomId);
      } else {
        const left = await getUser(uid);
        let i = 0;
        for await (const item of updatedRoom.players) {
          let response = {};
          const user = await getUser(item.uid);
          Object.assign(response, item);
          Object.assign(response._doc, user);
          updatedRoom.players[i] = response._doc;
          i++;
        }
        _io.in(roomId).emit(LEFT_ROOM, {
          status: `${left.displayName} just left!`,
          left,
          ...transformDoc(updatedRoom),
        });
        socket.leave(roomId);
        //condition if current turn player leaves
        if (updatedRoom.gameInProgress) {
          if (updatedRoom.turn.uid == uid) {
            nextRound(updatedRoom._id);
          }
        }
      }
    } catch (error) {
      throw new Error(error.message);
    }
  };
  // middleware that is executed for every incoming packet
  socket.use(async ([key, { roomId, roomCode }], next) => {
    try {
      if (![DRAWING, ERASE].includes(key)) {
        const room = await Room.findOne({
          $or: [{ _id: stringToObjectId(roomId) }, { roomCode }],
          isActive: true,
        }).exec();
        if (!MIDDLEWARE_IGNORED_EVENTS.includes(key) && !room) {
          return next(new Error(NON_EXISTENT_ROOM));
        }
      }
      next();
    } catch (error) {
      throw new Error(error.message);
    }
  });

  socket.on(CREATE_ROOM, createRoom);
  socket.on(JOIN_ROOM, clientJoinedRoom);
  socket.on(LEAVE_ROOM, clientLeftRoom);
  socket.on(DISCONNECT, disconnect);
};
