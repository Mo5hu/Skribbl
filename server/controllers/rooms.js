const Room = require("../models/room");

module.exports = {
  getRooms,
};

async function getRooms(_req, res, next) {
  try {
    const rooms = await Room.find({
      isActive: true,
      isPublic: true,
    });
    res.json({
      rooms,
    });
  } catch (error) {
    next(new Error(error.message))
  }
}
