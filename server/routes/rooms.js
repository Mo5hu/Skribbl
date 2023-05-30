var express = require("express");
var router = express.Router();

const { getRooms } = require("../controllers/rooms");
const { checkIfAuthenticated, getAuthToken } = require("../middlewares");

router.use(getAuthToken);
router.use(checkIfAuthenticated);

/* GET get rooms info */
router.get("/", getRooms);

module.exports = router;
