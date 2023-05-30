const { Types } = require("mongoose");

module.exports = {
  getRandomPlayerIndex,
  stringToObjectId,
  getRandomLetter,
  updateHint,
  replaceAlphaNumericWithUnderscores,
  transformDoc,
};

function stringToObjectId(id) {
  return Types.ObjectId(id);
}

function getRandomStringIndex(string) {
  return Math.floor(Math.random() * string.length);
}

function replaceAlphaNumericWithUnderscores(word) {
  return word
    .split("")
    .map((item) => (item === " " ? " " : "_"))
    .join("");
}

function getRandomStringIndex(string) {
  return Math.floor(Math.random() * string.length);
}

function updateHint(word, previousHint, noOfLettersToExpose = 1) {
  const newExposedLetters = [];
  let newString = previousHint;
  for (let i = 0; i < noOfLettersToExpose; i++) {
    let condition = true;
    while (condition) {
      const position = getRandomStringIndex(word);
      const letter = word[position];
      if (previousHint[position] !== letter) {
        newExposedLetters.push({
          position,
          letter,
        });
        condition = false;
      }
    }
  }
  newExposedLetters.forEach(({ position, letter }) => {
    const res = newString.split("");
    res.splice(position, 1, letter);
    newString = res.join("");
  });
  return newString;
}

function getRandomLetter(string, exposedLetters = []) {
  let letter = string[getRandomStringIndex(string)];
  let condition = true;
  while (condition) {
    if (!exposedLetters.includes(letter)) {
      condition = false;
      break;
    }
    letter = string[getRandomStringIndex(string)];
  }
  return [letter, string.indexOf(letter)];
}

function getRandomPlayerIndex(max) {
  return Math.floor(Math.random() * max);
}

function transformDoc({ _doc: document }) {
  return {
    ...document,
    id: document._id,
  };
}
