require("dotenv").config();

module.exports = {
  clientEmail: process.env.CLIENT_EMAIL,
  privateKey: process.env.PRIVATE_KEY.replace(/\\n/g, '\n'),
  projectId: process.env.PROJECT_ID,
  connectionString:
    process.env.CONNECTION_STRING || "mongodb://localhost:27017/skribbl",
};
