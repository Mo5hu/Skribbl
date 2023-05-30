const mongoose = require("mongoose");

const playerSchema = new mongoose.Schema({
  uid: {
    required: true,
    type: String,
  },
  name: {
    type: String,
  },
  picture: {
    type: String,
  },
  guessingState: {
    type: Boolean,
    default: false,
  },
  socketId: {
    type: String,
  },
  prevRoundScore: {
    type: Number,
    default: 0,
  },
  points: {
    type: Number,
    default: 0,
  },
  totalGames: {
    type: Number,
    default: 0,
  },
  totalWins: {
    type: Number,
    default: 0,
  },
});

const playerModel = mongoose.model("player", playerSchema);
module.exports = playerModel;
