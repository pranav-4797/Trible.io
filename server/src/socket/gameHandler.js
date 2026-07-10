const { RoomManager } = require('../services/roomService');
const wordService = require('../services/wordService');
const scoreService = require('../services/scoreService');
const logger = require('../utils/logger');

// Active game states: roomId -> gameState
const activeGames = new Map();

/**
 * Socket.IO Game handler.
 * Manages game flow: start, rounds, turns, word selection, timer, scoring.
 */
module.exports = function gameHandler(io, socket) {
  // ─── Start Game ───
  socket.on('game:start', (data, callback) => {
    try {
      const uid = socket.user.uid;
      const room = RoomManager.getPlayerRoom(uid);

      if (!room) throw new Error('Not in a room');
      if (room.hostId !== uid) throw new Error('Only host can start');
      if (room.players.length < 2) throw new Error('Need at least 2 players');
      if (room.status === 'playing') throw new Error('Game already in progress');

      // Initialize game state
      const gameState = initializeGame(room);
      activeGames.set(room.id, gameState);
      room.status = 'playing';

      logger.info(`Game started in room ${room.code} with ${room.players.length} players`);

      // Notify all players
      io.to(room.id).emit('game:starting', {
        countdown: 3,
        totalRounds: room.rounds,
        players: room.players.map(p => ({
          uid: p.uid,
          username: p.username,
          avatar: p.avatar,
          score: 0,
        })),
      });

      // Start first round after countdown
      setTimeout(() => startNextTurn(io, room.id), 3000);

      if (typeof callback === 'function') {
        callback({ success: true });
      }
    } catch (error) {
      logger.error('Game start error', { error: error.message });
      if (typeof callback === 'function') {
        callback({ success: false, error: error.message });
      }
    }
  });

  // ─── Word Choice ───
  socket.on('game:word_chosen', (data, callback) => {
    try {
      const uid = socket.user.uid;
      const room = RoomManager.getPlayerRoom(uid);
      if (!room) return;

      const game = activeGames.get(room.id);
      if (!game || game.currentDrawer !== uid) return;

      const { wordIndex } = data;
      const word = game.wordChoices[wordIndex];
      if (!word) return;

      game.currentWord = word;
      game.wordChoices = [];
      game.turnStartTime = Date.now();

      // Tell drawer the word
      socket.emit('game:turn_start', {
        word,
        isDrawer: true,
        timeLimit: room.drawTime,
      });

      // Tell guessers the word length (hint)
      const hint = word.replace(/[a-zA-Z]/g, '_');
      socket.to(room.id).emit('game:turn_start', {
        hint,
        wordLength: word.length,
        isDrawer: false,
        timeLimit: room.drawTime,
        drawerUid: uid,
        drawerName: game.players.find(p => p.uid === uid)?.username,
      });

      // Start turn timer
      startTurnTimer(io, room.id, room.drawTime);

      // Schedule hints
      scheduleHints(io, room.id, word, room.drawTime);

      if (typeof callback === 'function') {
        callback({ success: true });
      }
    } catch (error) {
      logger.error('Word choice error', { error: error.message });
    }
  });

  // ─── Rematch ───
  socket.on('game:rematch', (data, callback) => {
    try {
      const uid = socket.user.uid;
      const room = RoomManager.getPlayerRoom(uid);
      if (!room) return;

      // Reset scores and game state
      room.players.forEach(p => { p.score = 0; p.isReady = false; });
      room.status = 'waiting';
      activeGames.delete(room.id);

      io.to(room.id).emit('game:rematch_accepted', {
        room: {
          id: room.id,
          code: room.code,
          hostId: room.hostId,
          players: room.players,
        },
      });

      if (typeof callback === 'function') {
        callback({ success: true });
      }
    } catch (error) {
      logger.error('Rematch error', { error: error.message });
    }
  });
};

/**
 * Initialize game state.
 */
function initializeGame(room) {
  const playerOrder = shuffleArray([...room.players]);
  const totalTurns = room.rounds * room.players.length;

  return {
    roomId: room.id,
    players: playerOrder.map(p => ({
      uid: p.uid,
      username: p.username,
      avatar: p.avatar,
      score: 0,
      hasGuessedCorrectly: false,
      consecutiveWins: 0,
    })),
    currentRound: 1,
    totalRounds: room.rounds,
    currentTurnIndex: 0,
    totalTurns,
    currentDrawer: null,
    currentWord: null,
    wordChoices: [],
    usedWords: new Set(),
    turnStartTime: null,
    turnTimer: null,
    hintTimers: [],
    hintsRevealed: 0,
    guessedPlayers: new Set(),
    difficulty: room.difficulty,
    categories: room.categories,
  };
}

/**
 * Start the next turn in the game.
 */
function startNextTurn(io, roomId) {
  const game = activeGames.get(roomId);
  const room = RoomManager.findById(roomId);
  if (!game || !room) return;

  // Clear previous timers
  clearTimers(game);

  // Check if game is over
  if (game.currentTurnIndex >= game.totalTurns) {
    endGame(io, roomId);
    return;
  }

  // Check if new round
  const roundNumber = Math.floor(game.currentTurnIndex / game.players.length) + 1;
  if (roundNumber !== game.currentRound) {
    game.currentRound = roundNumber;
    io.to(roomId).emit('game:round_start', { round: roundNumber, totalRounds: game.totalRounds });
  }

  // Select drawer
  const drawerIndex = game.currentTurnIndex % game.players.length;
  const drawer = game.players[drawerIndex];
  game.currentDrawer = drawer.uid;
  game.currentWord = null;
  game.guessedPlayers.clear();
  game.hintsRevealed = 0;

  // Reset hasGuessedCorrectly for all players
  game.players.forEach(p => { p.hasGuessedCorrectly = false; });

  // Generate word choices
  const words = wordService.getWordChoices(game.difficulty, game.categories, game.usedWords);
  game.wordChoices = words;

  // Send word choices to drawer only
  const drawerSocket = findSocketByUid(io, drawer.uid);
  if (drawerSocket) {
    drawerSocket.emit('game:word_choices', {
      words,
      timeLimit: 15,
      round: game.currentRound,
      turn: game.currentTurnIndex + 1,
    });
  }

  // Notify everyone else
  io.to(roomId).emit('game:turn_start', {
    drawerUid: drawer.uid,
    drawerName: drawer.username,
    round: game.currentRound,
    turn: game.currentTurnIndex + 1,
    isChoosingWord: true,
  });

  // Auto-select word after 15 seconds if drawer hasn't chosen
  game.turnTimer = setTimeout(() => {
    if (!game.currentWord && game.wordChoices.length > 0) {
      const autoWord = game.wordChoices[0];
      game.currentWord = autoWord;
      game.wordChoices = [];
      game.turnStartTime = Date.now();

      if (drawerSocket) {
        drawerSocket.emit('game:turn_start', {
          word: autoWord,
          isDrawer: true,
          timeLimit: room.drawTime,
        });
      }

      const hint = autoWord.replace(/[a-zA-Z]/g, '_');
      drawerSocket?.broadcast.to(roomId).emit('game:turn_start', {
        hint,
        wordLength: autoWord.length,
        isDrawer: false,
        timeLimit: room.drawTime,
        drawerUid: drawer.uid,
        drawerName: drawer.username,
      });

      startTurnTimer(io, roomId, room.drawTime);
      scheduleHints(io, roomId, autoWord, room.drawTime);
    }
  }, 15000);

  game.currentTurnIndex++;
}

/**
 * Start the turn countdown timer.
 */
function startTurnTimer(io, roomId, duration) {
  const game = activeGames.get(roomId);
  if (!game) return;

  let remaining = duration;

  game.turnTimer = setInterval(() => {
    remaining--;
    io.to(roomId).emit('game:timer', { remaining, total: duration });

    if (remaining <= 0) {
      clearInterval(game.turnTimer);
      endTurn(io, roomId, false);
    }
  }, 1000);
}

/**
 * Schedule progressive letter hints.
 */
function scheduleHints(io, roomId, word, duration) {
  const game = activeGames.get(roomId);
  if (!game) return;

  const hintInterval = Math.floor(duration / 4); // 3 hints during the turn
  const letters = word.split('');
  const revealOrder = shuffleArray(
    letters.map((_, i) => i).filter(i => letters[i] !== ' ')
  );

  for (let h = 1; h <= 3; h++) {
    const timer = setTimeout(() => {
      if (!activeGames.has(roomId)) return;
      const currentGame = activeGames.get(roomId);
      if (currentGame.currentWord !== word) return;

      currentGame.hintsRevealed = h;
      const lettersToReveal = Math.ceil((h / 4) * revealOrder.length);
      const revealed = new Set(revealOrder.slice(0, lettersToReveal));

      const hint = letters
        .map((char, i) => (char === ' ' || revealed.has(i)) ? char : '_')
        .join('');

      io.to(roomId).emit('game:word_hint', {
        hint,
        hintNumber: h,
      });
    }, hintInterval * h * 1000);

    game.hintTimers.push(timer);
  }
}

/**
 * End the current turn.
 */
function endTurn(io, roomId, allGuessed) {
  const game = activeGames.get(roomId);
  const room = RoomManager.findById(roomId);
  if (!game || !room) return;

  clearTimers(game);

  // Calculate drawer score
  const drawerPlayer = game.players.find(p => p.uid === game.currentDrawer);
  if (drawerPlayer && game.guessedPlayers.size > 0) {
    const drawerScore = scoreService.calculateDrawerScore(game.guessedPlayers.size, game.players.length - 1);
    drawerPlayer.score += drawerScore;

    // Update room player score
    const roomPlayer = room.players.find(p => p.uid === game.currentDrawer);
    if (roomPlayer) roomPlayer.score = drawerPlayer.score;
  }

  // Broadcast turn end
  io.to(roomId).emit('game:turn_end', {
    word: game.currentWord,
    scores: game.players.map(p => ({
      uid: p.uid,
      username: p.username,
      score: p.score,
      guessedCorrectly: game.guessedPlayers.has(p.uid),
    })),
  });

  // Add word to used list
  if (game.currentWord) {
    game.usedWords.add(game.currentWord);
  }

  // Start next turn after 5 seconds
  setTimeout(() => startNextTurn(io, roomId), 5000);
}

/**
 * End the game and show final scores.
 */
function endGame(io, roomId) {
  const game = activeGames.get(roomId);
  const room = RoomManager.findById(roomId);
  if (!game || !room) return;

  clearTimers(game);

  // Sort by score
  const sortedPlayers = [...game.players].sort((a, b) => b.score - a.score);

  room.status = 'finished';

  io.to(roomId).emit('game:end', {
    winner: sortedPlayers[0],
    rankings: sortedPlayers.map((p, i) => ({
      ...p,
      rank: i + 1,
    })),
  });

  activeGames.delete(roomId);
  logger.info(`Game ended in room ${room.code}. Winner: ${sortedPlayers[0]?.username}`);
}

/**
 * Handle a correct guess (called from chatHandler).
 */
function handleCorrectGuess(io, roomId, uid) {
  const game = activeGames.get(roomId);
  const room = RoomManager.findById(roomId);
  if (!game || !room) return;

  if (game.guessedPlayers.has(uid)) return; // Already guessed
  if (uid === game.currentDrawer) return; // Drawer can't guess

  game.guessedPlayers.add(uid);
  const player = game.players.find(p => p.uid === uid);
  if (player) {
    player.hasGuessedCorrectly = true;

    // Calculate score
    const elapsed = (Date.now() - game.turnStartTime) / 1000;
    const guessScore = scoreService.calculateGuessScore(
      elapsed,
      room.drawTime,
      game.guessedPlayers.size,
      game.players.length - 1,
    );
    player.score += guessScore;

    // Update room player score
    const roomPlayer = room.players.find(p => p.uid === uid);
    if (roomPlayer) roomPlayer.score = player.score;
  }

  // Broadcast correct guess
  io.to(roomId).emit('chat:correct', {
    uid,
    username: player?.username,
    position: game.guessedPlayers.size,
  });

  // Update scoreboard
  io.to(roomId).emit('score:update', {
    scores: game.players.map(p => ({
      uid: p.uid,
      username: p.username,
      score: p.score,
    })),
  });

  // Check if everyone has guessed
  const guessers = game.players.filter(p => p.uid !== game.currentDrawer);
  if (game.guessedPlayers.size >= guessers.length) {
    endTurn(io, roomId, true);
  }
}

// ─── Helpers ───

function clearTimers(game) {
  if (game.turnTimer) {
    clearTimeout(game.turnTimer);
    clearInterval(game.turnTimer);
    game.turnTimer = null;
  }
  for (const t of game.hintTimers) {
    clearTimeout(t);
  }
  game.hintTimers = [];
}

function shuffleArray(arr) {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

function findSocketByUid(io, uid) {
  for (const [, socket] of io.sockets.sockets) {
    if (socket.user?.uid === uid) return socket;
  }
  return null;
}

// Expose for chatHandler
module.exports.handleCorrectGuess = handleCorrectGuess;
module.exports.activeGames = activeGames;
