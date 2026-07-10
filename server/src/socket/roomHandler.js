const { RoomManager } = require('../services/roomService');
const logger = require('../utils/logger');
const { chatRateLimiter } = require('../middleware/rateLimit');

/**
 * Socket.IO Room event handler.
 * Manages room lifecycle events: create, join, leave, ready, kick, settings.
 */
module.exports = function roomHandler(io, socket) {
  // ─── Create Room ───
  socket.on('room:create', (data, callback) => {
    try {
      const user = {
        uid: socket.user.uid,
        username: socket.user.username,
        avatar: socket.user.avatar,
        socketId: socket.id,
      };

      const room = RoomManager.createRoom(user, data || {});
      socket.join(room.id);

      logger.info(`Room created via socket: ${room.code}`);

      if (typeof callback === 'function') {
        callback({ success: true, room: sanitizeRoom(room) });
      }
    } catch (error) {
      logger.error('Room create error', { error: error.message });
      if (typeof callback === 'function') {
        callback({ success: false, error: error.message });
      }
    }
  });

  // ─── Join Room ───
  socket.on('room:join', (data, callback) => {
    try {
      const { roomCode } = data;
      const user = {
        uid: socket.user.uid,
        username: socket.user.username,
        avatar: socket.user.avatar,
        socketId: socket.id,
      };

      const room = RoomManager.joinRoom(roomCode, user);
      socket.join(room.id);

      // Notify other players
      socket.to(room.id).emit('lobby:player_joined', {
        player: {
          uid: user.uid,
          username: user.username,
          avatar: user.avatar,
          isReady: false,
          isHost: false,
          isConnected: true,
          score: 0,
        },
      });

      // Send full room state to the joiner
      if (typeof callback === 'function') {
        callback({ success: true, room: sanitizeRoom(room) });
      }

      // Broadcast updated room to all
      io.to(room.id).emit('lobby:update', { room: sanitizeRoom(room) });
    } catch (error) {
      logger.error('Room join error', { error: error.message });
      if (typeof callback === 'function') {
        callback({ success: false, error: error.message });
      }
    }
  });

  // ─── Leave Room ───
  socket.on('room:leave', (data, callback) => {
    try {
      const uid = socket.user.uid;
      const room = RoomManager.getPlayerRoom(uid);
      const roomId = room?.id;

      RoomManager.leaveRoom(uid);
      if (roomId) {
        socket.leave(roomId);
        socket.to(roomId).emit('lobby:player_left', { uid });

        // Send updated room state
        const updatedRoom = RoomManager.findById(roomId);
        if (updatedRoom) {
          io.to(roomId).emit('lobby:update', { room: sanitizeRoom(updatedRoom) });
        }
      }

      if (typeof callback === 'function') {
        callback({ success: true });
      }
    } catch (error) {
      logger.error('Room leave error', { error: error.message });
      if (typeof callback === 'function') {
        callback({ success: false, error: error.message });
      }
    }
  });

  // ─── Toggle Ready ───
  socket.on('lobby:player_ready', (data, callback) => {
    try {
      const uid = socket.user.uid;
      const isReady = data?.isReady ?? true;
      const room = RoomManager.setReady(uid, isReady);

      if (room) {
        io.to(room.id).emit('lobby:update', { room: sanitizeRoom(room) });
      }

      if (typeof callback === 'function') {
        callback({ success: true });
      }
    } catch (error) {
      logger.error('Ready toggle error', { error: error.message });
    }
  });

  // ─── Kick Player ───
  socket.on('lobby:kick', (data, callback) => {
    try {
      const { targetUid } = data;
      const room = RoomManager.kickPlayer(socket.user.uid, targetUid);

      // Notify kicked player
      const kickedPlayer = io.sockets.sockets.get(
        room.players.find(p => p.uid === targetUid)?.socketId
      );
      // The player was already removed, so find their socket differently
      for (const [, s] of io.sockets.sockets) {
        if (s.user?.uid === targetUid) {
          s.emit('lobby:player_kicked', { reason: 'Kicked by host' });
          s.leave(room.id);
          break;
        }
      }

      io.to(room.id).emit('lobby:update', { room: sanitizeRoom(room) });

      if (typeof callback === 'function') {
        callback({ success: true });
      }
    } catch (error) {
      logger.error('Kick error', { error: error.message });
      if (typeof callback === 'function') {
        callback({ success: false, error: error.message });
      }
    }
  });

  // ─── Update Settings ───
  socket.on('room:settings', (data, callback) => {
    try {
      const room = RoomManager.updateSettings(socket.user.uid, data);
      io.to(room.id).emit('room:settings_updated', { room: sanitizeRoom(room) });

      if (typeof callback === 'function') {
        callback({ success: true });
      }
    } catch (error) {
      logger.error('Settings update error', { error: error.message });
      if (typeof callback === 'function') {
        callback({ success: false, error: error.message });
      }
    }
  });
};

/**
 * Remove sensitive data from room before sending to clients.
 */
function sanitizeRoom(room) {
  return {
    id: room.id,
    code: room.code,
    hostId: room.hostId,
    hostName: room.hostName,
    isPrivate: room.isPrivate,
    status: room.status,
    maxPlayers: room.maxPlayers,
    rounds: room.rounds,
    drawTime: room.drawTime,
    difficulty: room.difficulty,
    categories: room.categories,
    players: room.players.map(p => ({
      uid: p.uid,
      username: p.username,
      avatar: p.avatar,
      isReady: p.isReady,
      isHost: p.isHost,
      isConnected: p.isConnected,
      score: p.score,
    })),
    createdAt: room.createdAt,
  };
}
