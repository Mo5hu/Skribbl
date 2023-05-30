const mongoose = require("mongoose");
const Player = require("./player");
const { Schema } = mongoose;

const roomSchema = new Schema({
  rounds: {
    required: true,
    type: Number,
  },
  word: String,
  drawTime: {
    required: true,
    type: Number,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  gameInProgress: {
    type: Boolean,
    default: false,
  },
  isPublic: {
    type: Boolean,
    default: true,
  },
  roomCode: String,
  numberOfPlayers: Number,
  currentRound: {
    required: true,
    type: Number,
    default: 1,
  },
  turn: Player.schema,
  turnIndex: {
    type: Number,
    default: 0,
  },
  partyLeader: Player.schema,
  players: [Player.schema],
  isFull: {
    type: Boolean,
    default: false,
  },
  currentEvent: {
    type: String,
  },
});

const roomModel = mongoose.model("Room", roomSchema);
module.exports = roomModel;
