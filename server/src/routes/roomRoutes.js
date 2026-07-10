const express = require('express');
const router = express.Router();
const roomController = require('../controllers/roomController');
const { authenticateJWT } = require('../middleware/auth');

// Public route to list public rooms for matchmaking
router.get('/public', roomController.getPublicRooms);

// Get specific room status
router.get('/:roomId', authenticateJWT, roomController.getRoomStatus);

module.exports = router;
