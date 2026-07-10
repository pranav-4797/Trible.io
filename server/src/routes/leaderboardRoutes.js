const express = require('express');
const router = express.Router();
const leaderboardController = require('../controllers/leaderboardController');
const { authenticateJWT } = require('../middleware/auth');

// Get top players by score/wins/level
router.get('/', authenticateJWT, leaderboardController.getLeaderboard);

module.exports = router;
