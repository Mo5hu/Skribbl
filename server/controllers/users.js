module.exports = {
  getUserData,
};

async function getUserData(req, res, next) {
  const uid = req.authId;
  res.json({
    uid,
  });
}
