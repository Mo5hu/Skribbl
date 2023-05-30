const admin = require("firebase-admin");
const { getAuth } = require("firebase-admin/auth");
const config = require("../config");

const defaultApp = admin.initializeApp({
  credential: admin.credential.cert({
    clientEmail: config.clientEmail,
    privateKey: config.privateKey,
    projectId: config.projectId,
  }),
});

const auth = getAuth(defaultApp);

module.exports = {
  getUser,
  verifyToken,
};

async function verifyToken(token) {
  return await auth.verifyIdToken(token);
}

async function getUser(uid) {
  return await auth.getUser(uid);
}
