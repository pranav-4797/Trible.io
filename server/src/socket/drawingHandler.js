const logger = require('../utils/logger');
const { drawRateLimiter } = require('../middleware/rateLimit');

/**
 * Socket.IO Drawing handler.
 * Relays drawing strokes between players in realtime.
 * Optimized for low latency — minimal processing on each stroke.
 */
module.exports = function drawingHandler(io, socket) {
  // ─── Draw Start (pen/finger down) ───
  socket.on('draw:start', (data) => {
    if (drawRateLimiter.isRateLimited(socket.id)) return;

    const room = getPlayerRoom(socket);
    if (!room) return;

    // Relay to all other players in the room
    socket.to(room).emit('draw:start', {
      x: data.x,
      y: data.y,
      color: data.color,
      size: data.size,
      tool: data.tool || 'brush',
      uid: socket.user.uid,
    });
  });

  // ─── Draw Move (pen/finger drag) ───
  socket.on('draw:move', (data) => {
    if (drawRateLimiter.isRateLimited(socket.id)) return;

    const room = getPlayerRoom(socket);
    if (!room) return;

    // Relay with minimal overhead
    socket.to(room).emit('draw:move', {
      x: data.x,
      y: data.y,
      uid: socket.user.uid,
    });
  });

  // ─── Draw End (pen/finger up) ───
  socket.on('draw:end', (data) => {
    const room = getPlayerRoom(socket);
    if (!room) return;

    socket.to(room).emit('draw:end', {
      uid: socket.user.uid,
    });
  });

  // ─── Draw Batch (batched stroke points) ───
  socket.on('draw:batch', (data) => {
    if (drawRateLimiter.isRateLimited(socket.id)) return;

    const room = getPlayerRoom(socket);
    if (!room) return;

    // Relay entire batch for efficiency
    socket.to(room).emit('draw:batch', {
      points: data.points,
      color: data.color,
      size: data.size,
      tool: data.tool || 'brush',
      uid: socket.user.uid,
    });
  });

  // ─── Undo ───
  socket.on('draw:undo', () => {
    const room = getPlayerRoom(socket);
    if (!room) return;

    socket.to(room).emit('draw:undo', {
      uid: socket.user.uid,
    });
  });

  // ─── Clear Canvas ───
  socket.on('draw:clear', () => {
    const room = getPlayerRoom(socket);
    if (!room) return;

    socket.to(room).emit('draw:clear', {
      uid: socket.user.uid,
    });
  });

  // ─── Bucket Fill ───
  socket.on('draw:fill', (data) => {
    const room = getPlayerRoom(socket);
    if (!room) return;

    socket.to(room).emit('draw:fill', {
      color: data.color,
      uid: socket.user.uid,
    });
  });
};

/**
 * Get the room ID for a socket's user.
 */
function getPlayerRoom(socket) {
  // Get all rooms the socket is in (excluding its own room)
  const socketRooms = Array.from(socket.rooms);
  // First room is always the socket's own ID
  return socketRooms.length > 1 ? socketRooms[1] : null;
}
