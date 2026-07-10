const { RoomManager } = require('../services/roomService');
const logger = require('../utils/logger');
const { RoomError } = require('../utils/errors');

/**
 * Controller to handle REST requests for room operations.
 */
const roomController = {
  /**
   * GET /api/rooms/public
   */
  getPublicRooms(req, res, next) {
    try {
      const publicRooms = RoomManager.getPublicRooms();
      res.json({
        success: true,
        data: publicRooms,
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * GET /api/rooms/:roomId
   */
  getRoomStatus(req, res, next) {
    try {
      const { roomId } = req.params;
      const room = RoomManager.findById(roomId) || RoomManager.findByCode(roomId);

      if (!room) {
        throw new RoomError('Room not found', 'ROOM_NOT_FOUND', 404);
      }

      res.json({
        success: true,
        data: {
          id: room.id,
          code: room.code,
          status: room.status,
          playersCount: room.players.length,
          maxPlayers: room.maxPlayers,
        },
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = roomController;
