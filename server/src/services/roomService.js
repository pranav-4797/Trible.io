const { v4: uuidv4 } = require('uuid');
const logger = require('../utils/logger');
const { RoomError, GameError } = require('../utils/errors');

// In-memory room storage for realtime game state
// Firestore is used for persistence/history, in-memory for hot game state
const rooms = new Map();
const playerRooms = new Map(); // uid -> roomId mapping

/**
 * Room Manager — handles all room operations in memory.
 */
const RoomManager = {
  /**
   * Create a new room.
   */
  createRoom(hostUser, settings = {}) {
    const roomId = uuidv4();
    const code = generateRoomCode();

    const room = {
      id: roomId,
      code,
      hostId: hostUser.uid,
      hostName: hostUser.username,
      isPrivate: settings.isPrivate || false,
      status: 'waiting', // waiting | playing | finished
      maxPlayers: settings.maxPlayers || 8,
      rounds: settings.rounds || 3,
      drawTime: settings.drawTime || 80,
      difficulty: settings.difficulty || 'medium',
      categories: settings.categories || [],
      players: [{
        uid: hostUser.uid,
        username: hostUser.username,
        avatar: hostUser.avatar || '🎨',
        socketId: hostUser.socketId,
        isReady: true,
        isHost: true,
        isConnected: true,
        score: 0,
      }],
      game: null,
      createdAt: Date.now(),
      lastActivity: Date.now(),
    };

    rooms.set(roomId, room);
    playerRooms.set(hostUser.uid, roomId);

    logger.info(`Room created: ${roomId} (${code}) by ${hostUser.username}`);
    return room;
  },

  /**
   * Join a room by code.
   */
  joinRoom(code, user) {
    const room = this.findByCode(code);
    if (!room) throw new RoomError('Room not found', 'ROOM_NOT_FOUND');
    if (room.status === 'playing') throw new RoomError('Game in progress', 'GAME_IN_PROGRESS');
    if (room.players.length >= room.maxPlayers) throw new RoomError('Room is full', 'ROOM_FULL');

    // Check if player already in room
    const existingIdx = room.players.findIndex(p => p.uid === user.uid);
    if (existingIdx >= 0) {
      // Reconnect
      room.players[existingIdx].socketId = user.socketId;
      room.players[existingIdx].isConnected = true;
      logger.info(`Player reconnected: ${user.username} to room ${room.code}`);
    } else {
      room.players.push({
        uid: user.uid,
        username: user.username,
        avatar: user.avatar || '🎨',
        socketId: user.socketId,
        isReady: false,
        isHost: false,
        isConnected: true,
        score: 0,
      });
      logger.info(`Player joined: ${user.username} to room ${room.code}`);
    }

    playerRooms.set(user.uid, room.id);
    room.lastActivity = Date.now();
    return room;
  },

  /**
   * Leave a room.
   */
  leaveRoom(uid) {
    const roomId = playerRooms.get(uid);
    if (!roomId) return null;

    const room = rooms.get(roomId);
    if (!room) {
      playerRooms.delete(uid);
      return null;
    }

    room.players = room.players.filter(p => p.uid !== uid);
    playerRooms.delete(uid);

    // If room is empty, delete it
    if (room.players.length === 0) {
      rooms.delete(roomId);
      logger.info(`Room deleted (empty): ${room.code}`);
      return null;
    }

    // If host left, assign new host
    if (room.hostId === uid) {
      const newHost = room.players[0];
      room.hostId = newHost.uid;
      room.hostName = newHost.username;
      newHost.isHost = true;
      logger.info(`New host: ${newHost.username} for room ${room.code}`);
    }

    room.lastActivity = Date.now();
    return room;
  },

  /**
   * Set player ready status.
   */
  setReady(uid, isReady) {
    const roomId = playerRooms.get(uid);
    if (!roomId) return null;

    const room = rooms.get(roomId);
    if (!room) return null;

    const player = room.players.find(p => p.uid === uid);
    if (player) {
      player.isReady = isReady;
    }

    return room;
  },

  /**
   * Kick a player (host only).
   */
  kickPlayer(hostUid, targetUid) {
    const roomId = playerRooms.get(hostUid);
    if (!roomId) throw new RoomError('Not in a room');

    const room = rooms.get(roomId);
    if (!room) throw new RoomError('Room not found');
    if (room.hostId !== hostUid) throw new RoomError('Only host can kick players');
    if (hostUid === targetUid) throw new RoomError('Cannot kick yourself');

    room.players = room.players.filter(p => p.uid !== targetUid);
    playerRooms.delete(targetUid);
    room.lastActivity = Date.now();

    logger.info(`Player kicked: ${targetUid} from room ${room.code}`);
    return room;
  },

  /**
   * Update room settings (host only).
   */
  updateSettings(hostUid, settings) {
    const roomId = playerRooms.get(hostUid);
    if (!roomId) throw new RoomError('Not in a room');

    const room = rooms.get(roomId);
    if (!room) throw new RoomError('Room not found');
    if (room.hostId !== hostUid) throw new RoomError('Only host can change settings');
    if (room.status !== 'waiting') throw new RoomError('Cannot change settings during game');

    if (settings.maxPlayers) room.maxPlayers = settings.maxPlayers;
    if (settings.rounds) room.rounds = settings.rounds;
    if (settings.drawTime) room.drawTime = settings.drawTime;
    if (settings.difficulty) room.difficulty = settings.difficulty;
    if (settings.categories) room.categories = settings.categories;
    if (settings.isPrivate !== undefined) room.isPrivate = settings.isPrivate;

    room.lastActivity = Date.now();
    return room;
  },

  /**
   * Handle player disconnect.
   */
  handleDisconnect(socket) {
    const uid = socket.user?.uid;
    if (!uid) return;

    const roomId = playerRooms.get(uid);
    if (!roomId) return;

    const room = rooms.get(roomId);
    if (!room) return;

    const player = room.players.find(p => p.uid === uid);
    if (player) {
      player.isConnected = false;
      player.socketId = null;
      logger.info(`Player disconnected: ${player.username} from room ${room.code}`);
    }

    // Auto-remove disconnected players after 60 seconds in waiting state
    if (room.status === 'waiting') {
      setTimeout(() => {
        const currentRoom = rooms.get(roomId);
        if (!currentRoom) return;
        const p = currentRoom.players.find(pl => pl.uid === uid);
        if (p && !p.isConnected) {
          this.leaveRoom(uid);
        }
      }, 60000);
    }
  },

  // ─── Lookup Methods ───

  findByCode(code) {
    for (const room of rooms.values()) {
      if (room.code === code.toUpperCase()) return room;
    }
    return null;
  },

  findById(id) {
    return rooms.get(id) || null;
  },

  getPlayerRoom(uid) {
    const roomId = playerRooms.get(uid);
    return roomId ? rooms.get(roomId) : null;
  },

  getRoomCount() {
    return rooms.size;
  },

  getPlayerCount() {
    let count = 0;
    for (const room of rooms.values()) {
      count += room.players.length;
    }
    return count;
  },

  /**
   * Get public rooms for matchmaking.
   */
  getPublicRooms() {
    const publicRooms = [];
    for (const room of rooms.values()) {
      if (!room.isPrivate && room.status === 'waiting' && room.players.length < room.maxPlayers) {
        publicRooms.push({
          id: room.id,
          code: room.code,
          hostName: room.hostName,
          players: room.players.length,
          maxPlayers: room.maxPlayers,
          rounds: room.rounds,
          difficulty: room.difficulty,
        });
      }
    }
    return publicRooms;
  },

  /**
   * Clean up empty/stale rooms.
   */
  cleanupEmptyRooms() {
    const now = Date.now();
    let cleaned = 0;
    for (const [id, room] of rooms.entries()) {
      const isStale = now - room.lastActivity > 300000; // 5 minutes
      const isEmpty = room.players.length === 0;
      const allDisconnected = room.players.every(p => !p.isConnected);

      if (isEmpty || (isStale && allDisconnected)) {
        // Clean up player mappings
        for (const p of room.players) {
          playerRooms.delete(p.uid);
        }
        rooms.delete(id);
        cleaned++;
      }
    }
    return cleaned;
  },
};

/**
 * Generate a random 6-character room code.
 */
function generateRoomCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No I,O,0,1 to avoid confusion
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars[Math.floor(Math.random() * chars.length)];
  }
  // Ensure uniqueness
  for (const room of rooms.values()) {
    if (room.code === code) return generateRoomCode();
  }
  return code;
}

module.exports = { RoomManager };
