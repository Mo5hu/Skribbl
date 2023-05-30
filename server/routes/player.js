var express = require("express");
var router = express.Router();

const { getPlayerInfo } = require("../controllers/player");
const { checkIfAuthenticated, getAuthToken } = require("../middlewares");

router.use(getAuthToken);
router.use(checkIfAuthenticated);

/* GET get player info */
router.get("/", getPlayerInfo);

module.exports = router;
