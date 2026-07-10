const words = require('../data/words.json');
const logger = require('../utils/logger');

// Pre-process word lists by difficulty for fast access
const wordsByDifficulty = {};
const wordsByCategory = {};
const allWords = [];

// Initialize word indices on startup
function initializeWords() {
  for (const [category, difficulties] of Object.entries(words)) {
    wordsByCategory[category] = [];
    for (const [difficulty, wordList] of Object.entries(difficulties)) {
      if (!wordsByDifficulty[difficulty]) wordsByDifficulty[difficulty] = [];
      wordsByDifficulty[difficulty].push(...wordList);
      wordsByCategory[category].push(...wordList);
      allWords.push(...wordList);
    }
  }
  logger.info(`Word dictionary loaded: ${allWords.length} words across ${Object.keys(words).length} categories`);
}

initializeWords();

const wordService = {
  /**
   * Get 3 random word choices for the drawer.
   * Avoids words already used in the current game.
   * @param {string} difficulty - 'easy', 'medium', 'hard', or mix
   * @param {string[]} categories - Restrict to specific categories (empty = all)
   * @param {Set} usedWords - Set of words already used this game
   * @returns {string[]} Array of 3 word choices
   */
  getWordChoices(difficulty = 'medium', categories = [], usedWords = new Set()) {
    let pool = [];

    // Build word pool based on filters
    if (categories.length > 0) {
      for (const cat of categories) {
        if (words[cat]) {
          if (difficulty && words[cat][difficulty]) {
            pool.push(...words[cat][difficulty]);
          } else {
            // All difficulties from category
            for (const dWords of Object.values(words[cat])) {
              pool.push(...dWords);
            }
          }
        }
      }
    } else if (difficulty && wordsByDifficulty[difficulty]) {
      pool = [...wordsByDifficulty[difficulty]];
    } else {
      pool = [...allWords];
    }

    // Remove used words
    pool = pool.filter(w => !usedWords.has(w));

    // If pool is too small, reset used words
    if (pool.length < 3) {
      pool = difficulty && wordsByDifficulty[difficulty]
        ? [...wordsByDifficulty[difficulty]]
        : [...allWords];
    }

    // Pick 3 random unique words
    const choices = [];
    const poolCopy = [...pool];
    for (let i = 0; i < Math.min(3, poolCopy.length); i++) {
      const idx = Math.floor(Math.random() * poolCopy.length);
      choices.push(poolCopy[idx]);
      poolCopy.splice(idx, 1);
    }

    return choices;
  },

  /**
   * Generate a progressive hint for a word.
   * @param {string} word
   * @param {number} hintLevel - 1, 2, or 3
   * @returns {string} Hint string with some letters revealed
   */
  generateHint(word, hintLevel) {
    const letters = word.split('');
    const totalLetters = letters.filter(c => c !== ' ').length;
    const lettersToReveal = Math.ceil((hintLevel / 4) * totalLetters);

    // Get random positions to reveal
    const positions = [];
    for (let i = 0; i < letters.length; i++) {
      if (letters[i] !== ' ') positions.push(i);
    }
    shuffle(positions);
    const revealed = new Set(positions.slice(0, lettersToReveal));

    return letters
      .map((char, i) => (char === ' ' || revealed.has(i)) ? char : '_')
      .join('');
  },

  /**
   * Get total word count.
   */
  getTotalWords() {
    return allWords.length;
  },

  /**
   * Get category list.
   */
  getCategories() {
    return Object.keys(words);
  },
};

function shuffle(arr) {
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

module.exports = wordService;
