var express = require('express');
var router = express.Router();

const { getUserData } = require("../controllers/users");
const { checkIfAuthenticated, getAuthToken } = require("../middlewares");

/* GET users listing. */
router.get('/', function(req, res, next) {
  res.send('respond with a resource');
});

router.use(getAuthToken)
router.use(checkIfAuthenticated);
/* POST get user info */
router.post("/", getUserData);

module.exports = router;
