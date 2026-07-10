const leaderboardService = require('../services/leaderboardService');

const leaderboardController = {
  /**
   * GET /api/leaderboard?type=xp&limit=10
   */
  async getLeaderboard(req, res, next) {
    try {
      const type = req.query.type || 'xp'; // 'xp' | 'wins' | 'coins'
      const limit = parseInt(req.query.limit, 10) || 50;

      const entries = await leaderboardService.getLeaderboard(type, limit);

      res.json({
        success: true,
        data: entries,
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = leaderboardController;
