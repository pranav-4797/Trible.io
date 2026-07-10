const userRepository = require('./userRepository');

const leaderboardRepository = {
  /**
   * Get top users by a specific field
   */
  async getTopUsers(field, limit) {
    return userRepository.getTopUsers(field, limit);
  },
};

module.exports = leaderboardRepository;
