const mongoose = require("mongoose");
const config = require(".");

main().catch((err) => console.log(err));

async function main() {
  await mongoose.connect(config.connectionString, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });
}
