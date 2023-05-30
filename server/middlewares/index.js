const { verifyToken } = require("../services/firebase-admin");

module.exports = {
  getAuthToken,
  socketGetAuthToken: wrap(getAuthToken),
  checkIfAuthenticated,
  socketCheckIfAuthenticated: wrap(checkIfAuthenticated),
};

const UNAUTHORIZED_MSG = "You are not authorized to make this request";

function getAuthToken(req, res, next) {
  if (
    req.headers.authorization &&
    req.headers.authorization.split(" ")[0] === "Bearer"
  ) {
    req.authToken = req.headers.authorization.split(" ")[1];
  } else {
    req.authToken = null;
  }
  next();
}

async function checkIfAuthenticated(req, res, next) { 
  try {
    const { authToken } = req;
    const userInfo = await verifyToken(authToken);
    req.user = userInfo
    req.authId = userInfo.uid;
    return next();
  } catch (e) {
    console.error(e);
    return next(new Error(UNAUTHORIZED_MSG));
  }
}

function wrap(middleware) {
  return function (socket, next) {
    return middleware(socket.request, {}, next);
  };
}
