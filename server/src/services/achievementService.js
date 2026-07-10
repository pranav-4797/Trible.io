const userRepository = require('../repositories/userRepository');
const logger = require('../utils/logger');

const ALL_ACHIEVEMENTS = {
  FIRST_STEPS: { id: 'FIRST_STEPS', name: 'First Steps', description: 'Play your first game', emoji: '🎮' },
  QUICK_DRAW: { id: 'QUICK_DRAW', name: 'Quick Draw', description: 'Win a game in under 30 seconds', emoji: '⚡' },
  ART_MASTER: { id: 'ART_MASTER', name: 'Art Master', description: 'Complete 50 drawings', emoji: '🎨' },
  WORD_WIZARD: { id: 'WORD_WIZARD', name: 'Word Wizard', description: 'Guess 100 words correctly', emoji: '🧙' },
  SOCIAL_BUTTERFLY: { id: 'SOCIAL_BUTTERFLY', name: 'Social Butterfly', description: 'Add 10 friends', emoji: '🦋' },
  WINNING_STREAK: { id: 'WINNING_STREAK', name: 'Winning Streak', description: 'Win 5 games in a row', emoji: '🔥' },
  SHARPSHOOTER: { id: 'SHARPSHOOTER', name: 'Sharpshooter', description: 'Guess correctly within 5 seconds', emoji: '🎯' },
  CENTURION: { id: 'CENTURION', name: 'Centurion', description: 'Play 100 games', emoji: '💯' },
  GOLD_RUSH: { id: 'GOLD_RUSH', name: 'Gold Rush', description: 'Earn 10,000 coins', emoji: '💰' },
  LEVEL_10: { id: 'LEVEL_10', name: 'Level 10', description: 'Reach level 10', emoji: '⭐' },
  LEVEL_25: { id: 'LEVEL_25', name: 'Level 25', description: 'Reach level 25', emoji: '🌟' },
  LEVEL_50: { id: 'LEVEL_50', name: 'Level 50', description: 'Reach level 50', emoji: '✨' },
};

const achievementService = {
  /**
   * Check and unlock achievements for a player.
   * @param {string} uid
   * @param {object} statsUpdates - Key stats to check against
   */
  async checkAchievements(uid, statsUpdates = {}) {
    try {
      const user = await userRepository.findByUid(uid);
      if (!user) return [];

      const currentAchievements = new Set(user.achievements || []);
      const newlyUnlocked = [];

      // Check level achievements
      if (user.level >= 10 && !currentAchievements.has('LEVEL_10')) newlyUnlocked.push('LEVEL_10');
      if (user.level >= 25 && !currentAchievements.has('LEVEL_25')) newlyUnlocked.push('LEVEL_25');
      if (user.level >= 50 && !currentAchievements.has('LEVEL_50')) newlyUnlocked.push('LEVEL_50');

      // Check games played achievements
      if (user.totalGames >= 1 && !currentAchievements.has('FIRST_STEPS')) newlyUnlocked.push('FIRST_STEPS');
      if (user.totalGames >= 100 && !currentAchievements.has('CENTURION')) newlyUnlocked.push('CENTURION');

      // Check drawing achievements
      if (user.totalDrawings >= 50 && !currentAchievements.has('ART_MASTER')) newlyUnlocked.push('ART_MASTER');

      // Check guess achievements
      if (user.totalCorrectGuesses >= 100 && !currentAchievements.has('WORD_WIZARD')) newlyUnlocked.push('WORD_WIZARD');

      // Check coin achievements
      if (user.coins >= 10000 && !currentAchievements.has('GOLD_RUSH')) newlyUnlocked.push('GOLD_RUSH');

      // Check conditional stats (e.g. quick guesses, win streak) from statsUpdates
      if (statsUpdates.winStreak >= 5 && !currentAchievements.has('WINNING_STREAK')) newlyUnlocked.push('WINNING_STREAK');
      if (statsUpdates.fastGuess && !currentAchievements.has('SHARPSHOOTER')) newlyUnlocked.push('SHARPSHOOTER');
      if (statsUpdates.quickWin && !currentAchievements.has('QUICK_DRAW')) newlyUnlocked.push('QUICK_DRAW');

      if (newlyUnlocked.length > 0) {
        const updatedAchievements = [...currentAchievements, ...newlyUnlocked];
        await userRepository.update(uid, { achievements: updatedAchievements });
        logger.info(`User ${user.username} unlocked achievements: ${newlyUnlocked.join(', ')}`);
      }

      return newlyUnlocked.map(id => ALL_ACHIEVEMENTS[id]);
    } catch (error) {
      logger.error('Error checking achievements', error);
      return [];
    }
  },

  getAllAchievements() {
    return Object.values(ALL_ACHIEVEMENTS);
  },
};

module.exports = achievementService;
