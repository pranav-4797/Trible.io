const { RoomManager } = require('../services/roomService');
const { handleCorrectGuess, activeGames } = require('./gameHandler');
const { guessRateLimiter, chatRateLimiter } = require('../middleware/rateLimit');
const logger = require('../utils/logger');

/**
 * Socket.IO Chat handler.
 * Manages chat messages, guess validation, and typing indicators.
 */
module.exports = function chatHandler(io, socket) {
  // ─── Chat Message / Guess ───
  socket.on('chat:message', (data) => {
    if (chatRateLimiter.isRateLimited(socket.id)) {
      socket.emit('chat:system', { message: 'Slow down! You\'re sending messages too fast.' });
      return;
    }

    const { message } = data;
    if (!message || message.trim().length === 0) return;
    if (message.trim().length > 100) return;

    const uid = socket.user.uid;
    const room = RoomManager.getPlayerRoom(uid);
    if (!room) return;

    const game = activeGames.get(room.id);

    // If game is active, treat messages as guesses
    if (game && game.currentWord && uid !== game.currentDrawer) {
      const guess = message.trim().toLowerCase();
      const word = game.currentWord.toLowerCase();

      if (guessRateLimiter.isRateLimited(socket.id)) {
        socket.emit('chat:system', { message: 'You\'re guessing too fast!' });
        return;
      }

      // Check if already guessed correctly
      if (game.guessedPlayers.has(uid)) {
        // Player already guessed — only show to other correct guessers
        const correctGuessers = [...game.guessedPlayers];
        for (const guesserUid of correctGuessers) {
          const guesserSocket = findSocketByUid(io, guesserUid);
          if (guesserSocket) {
            guesserSocket.emit('chat:message', {
              uid,
              username: socket.user.username,
              message: message.trim(),
              type: 'chat',
              timestamp: Date.now(),
            });
          }
        }
        return;
      }

      // Check if correct guess
      if (guess === word) {
        handleCorrectGuess(io, room.id, uid);
        return;
      }

      // Check if close guess
      if (isCloseGuess(guess, word)) {
        socket.emit('chat:close', {
          message: 'You\'re close!',
        });
      }

      // Show guess to everyone (but don't reveal the word)
      io.to(room.id).emit('chat:message', {
        uid,
        username: socket.user.username,
        message: message.trim(),
        type: 'guess',
        timestamp: Date.now(),
      });
    } else {
      // Regular chat message (not during active guessing)
      io.to(room.id).emit('chat:message', {
        uid,
        username: socket.user.username,
        message: message.trim(),
        type: 'chat',
        timestamp: Date.now(),
      });
    }
  });

  // ─── Typing Indicator ───
  socket.on('chat:typing', () => {
    const uid = socket.user.uid;
    const room = RoomManager.getPlayerRoom(uid);
    if (!room) return;

    socket.to(room.id).emit('chat:typing', {
      uid,
      username: socket.user.username,
    });
  });

  // ─── Emoji Reaction ───
  socket.on('chat:reaction', (data) => {
    const uid = socket.user.uid;
    const room = RoomManager.getPlayerRoom(uid);
    if (!room) return;

    io.to(room.id).emit('chat:reaction', {
      uid,
      username: socket.user.username,
      emoji: data.emoji,
      timestamp: Date.now(),
    });
  });
};

/**
 * Check if a guess is close (within Levenshtein distance of 2).
 */
function isCloseGuess(guess, word) {
  if (guess === word) return false;
  const distance = levenshteinDistance(guess, word);
  return distance <= 2 && distance > 0;
}

/**
 * Levenshtein distance calculation.
 */
function levenshteinDistance(s, t) {
  if (s === t) return 0;
  if (s.length === 0) return t.length;
  if (t.length === 0) return s.length;

  const prev = Array.from({ length: t.length + 1 }, (_, i) => i);
  const curr = new Array(t.length + 1).fill(0);

  for (let i = 0; i < s.length; i++) {
    curr[0] = i + 1;
    for (let j = 0; j < t.length; j++) {
      const cost = s[i] !== t[j] ? 1 : 0;
      curr[j + 1] = Math.min(
        curr[j] + 1,
        prev[j + 1] + 1,
        prev[j] + cost,
      );
    }
    for (let j = 0; j <= t.length; j++) {
      prev[j] = curr[j];
    }
  }

  return prev[t.length];
}

function findSocketByUid(io, uid) {
  for (const [, s] of io.sockets.sockets) {
    if (s.user?.uid === uid) return s;
  }
  return null;
}
