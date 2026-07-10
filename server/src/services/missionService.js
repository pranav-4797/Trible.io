const userRepository = require('../repositories/userRepository');
const logger = require('../utils/logger');

const DAILY_MISSIONS = [
  { id: 'PLAY_GAMES', title: 'Play 3 Games', target: 3, reward: 50, type: 'games' },
  { id: 'GUESS_WORDS', title: 'Guess 10 Words', target: 10, reward: 75, type: 'guesses' },
  { id: 'DRAW_TIMES', title: 'Draw 5 Times', target: 5, reward: 60, type: 'drawings' },
  { id: 'WIN_MATCHES', title: 'Win 2 Matches', target: 2, reward: 100, type: 'wins' },
];

const missionService = {
  /**
   * Get daily missions for a user.
   */
  async getDailyMissions(uid) {
    try {
      const user = await userRepository.findByUid(uid);
      if (!user) return [];

      // Check if user has daily missions metadata, initialize if empty
      const userMissions = user.dailyMissions || DAILY_MISSIONS.map(m => ({
        ...m,
        progress: 0,
        completed: false,
        claimed: false,
      }));

      return userMissions;
    } catch (error) {
      logger.error('Error fetching daily missions', error);
      return [];
    }
  },

  /**
   * Update mission progress for a specific action type.
   * @param {string} uid
   * @param {string} type - 'games' | 'guesses' | 'drawings' | 'wins'
   * @param {number} amount - incremental progress value
   */
  async updateProgress(uid, type, amount = 1) {
    try {
      const user = await userRepository.findByUid(uid);
      if (!user) return;

      const userMissions = user.dailyMissions || DAILY_MISSIONS.map(m => ({
        ...m,
        progress: 0,
        completed: false,
        claimed: false,
      }));

      let coinsToAward = 0;
      let missionsUpdated = false;

      const updated = userMissions.map(mission => {
        if (mission.type === type && !mission.completed) {
          missionsUpdated = true;
          const newProgress = Math.min(mission.target, mission.progress + amount);
          const isCompleted = newProgress >= mission.target;

          if (isCompleted) {
            coinsToAward += mission.reward;
          }

          return {
            ...mission,
            progress: newProgress,
            completed: isCompleted,
          };
        }
        return mission;
      });

      if (missionsUpdated) {
        const updates = { dailyMissions: updated };
        if (coinsToAward > 0) {
          updates.coins = (user.coins || 0) + coinsToAward;
          logger.info(`User ${user.username} completed missions, rewarded ${coinsToAward} coins`);
        }
        await userRepository.update(uid, updates);
      }
    } catch (error) {
      logger.error('Error updating mission progress', error);
    }
  },
};

module.exports = missionService;
