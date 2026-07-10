/**
 * Score calculation service.
 * Points based on guess speed, position, combo, and drawing quality.
 */

const MAX_GUESS_SCORE = 500;
const MIN_GUESS_SCORE = 100;
const FIRST_GUESS_BONUS = 100;
const DRAWER_BASE_SCORE = 50;
const DRAWER_BONUS_PER_GUESS = 25;

const scoreService = {
  /**
   * Calculate score for a correct guess.
   * @param {number} elapsedSeconds - Time since turn started
   * @param {number} totalSeconds - Total draw time
   * @param {number} guessPosition - 1st, 2nd, 3rd... correct guesser
   * @param {number} totalGuessers - Total number of potential guessers
   * @returns {number} Score earned
   */
  calculateGuessScore(elapsedSeconds, totalSeconds, guessPosition, totalGuessers) {
    // Base score: decreases linearly with time
    const timeRatio = Math.max(0, 1 - (elapsedSeconds / totalSeconds));
    let score = Math.round(MIN_GUESS_SCORE + (MAX_GUESS_SCORE - MIN_GUESS_SCORE) * timeRatio);

    // First guess bonus
    if (guessPosition === 1) {
      score += FIRST_GUESS_BONUS;
    }

    // Position bonus (earlier guesses get more)
    const positionMultiplier = Math.max(0.5, 1 - ((guessPosition - 1) / totalGuessers) * 0.5);
    score = Math.round(score * positionMultiplier);

    return Math.max(MIN_GUESS_SCORE, score);
  },

  /**
   * Calculate score for the drawer.
   * More points if more people guessed correctly.
   * @param {number} correctGuesses - Number of correct guesses
   * @param {number} totalGuessers - Total potential guessers
   * @returns {number} Drawer score
   */
  calculateDrawerScore(correctGuesses, totalGuessers) {
    if (correctGuesses === 0) return 0;

    const baseScore = DRAWER_BASE_SCORE;
    const bonusScore = correctGuesses * DRAWER_BONUS_PER_GUESS;
    const ratioBonus = Math.round((correctGuesses / totalGuessers) * 100);

    return baseScore + bonusScore + ratioBonus;
  },

  /**
   * Calculate XP earned from a game.
   * @param {object} stats - Player game stats
   * @returns {number} XP earned
   */
  calculateGameXp(stats) {
    let xp = 20; // Base XP for playing

    if (stats.won) xp += 50;
    xp += (stats.correctGuesses || 0) * 10;
    if (stats.drew) xp += 15;

    return xp;
  },

  /**
   * Calculate coins earned from a game.
   * @param {object} stats
   * @returns {number} Coins earned
   */
  calculateGameCoins(stats) {
    let coins = 10; // Base coins

    if (stats.won) coins += 30;
    if (stats.firstGuess) coins += 15;

    return coins;
  },
};

module.exports = scoreService;
