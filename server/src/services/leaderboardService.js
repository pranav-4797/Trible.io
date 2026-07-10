const leaderboardRepository = require('../repositories/leaderboardRepository');

const leaderboardService = {
  /**
   * Get leaderboard players.
   * @param {string} type - 'xp' | 'wins' | 'coins'
   * @param {number} limit
   */
  async getLeaderboard(type = 'xp', limit = 50) {
    let field = 'xp';
    if (type === 'wins') {
      field = 'totalWins';
    } else if (type === 'coins') {
      field = 'coins';
    }
    const users = await leaderboardRepository.getTopUsers(field, limit);

    // Map to public leaderboard structures
    return users.map((user, idx) => ({
      rank: idx + 1,
      uid: user.uid,
      username: user.username,
      avatar: user.avatar,
      level: user.level || 1,
      xp: user.xp || 0,
      wins: user.totalWins || 0,
      coins: user.coins || 0,
    }));
  },
};

module.exports = leaderboardService;
