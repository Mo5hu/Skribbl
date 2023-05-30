const Player = require("../models/player");
const { transformDoc } = require("../utils");

module.exports = {
  getPlayerInfo,
};

async function getPlayerInfo(req, res, next) {
  try {
    const uid = req.authId;
    let player = await Player.findOne({ uid });
    if (!player) {
      player = new Player({ uid })
      await player.save()
    }
    res.json({
      ...transformDoc(player),
    });
  } catch (error) {
    next(new Error(error));
  }
}
