const userRepository = require('../repositories/userRepository');
const logger = require('../utils/logger');

/**
 * User service — business logic for user operations.
 */
const userService = {
  /**
   * Create or update a user profile.
   */
  async createOrUpdate(userData) {
    const { uid, username, avatar, email, isGuest } = userData;
    const now = Date.now();

    const existing = await userRepository.findByUid(uid);

    if (existing) {
      // Update existing user
      const updates = {
        username: username || existing.username,
        avatar: avatar || existing.avatar,
        lastSeen: now,
        isOnline: true,
      };
      await userRepository.update(uid, updates);
      return { ...existing, ...updates };
    }

    // Create new user
    const newUser = {
      uid,
      username,
      avatar,
      email: email || '',
      isGuest: isGuest || false,
      isOnline: true,
      coins: 100,
      xp: 0,
      level: 1,
      totalWins: 0,
      totalGames: 0,
      totalCorrectGuesses: 0,
      totalDrawings: 0,
      guessAccuracy: 0,
      rank: 'Beginner',
      title: 'Newbie',
      avatarFrame: 'default',
      ownedBrushes: ['basic'],
      ownedThemes: ['default'],
      ownedFrames: ['default'],
      ownedTitles: ['Newbie'],
      friendIds: [],
      achievements: [],
      createdAt: now,
      lastSeen: now,
    };

    await userRepository.create(newUser);
    logger.info(`New user created: ${uid} (${username})`);
    return newUser;
  },

  /**
   * Find user by UID.
   */
  async findByUid(uid) {
    return userRepository.findByUid(uid);
  },

  /**
   * Find user by username.
   */
  async findByUsername(username) {
    return userRepository.findByUsername(username);
  },

  /**
   * Update user fields.
   */
  async update(uid, updates) {
    await userRepository.update(uid, updates);
    return userRepository.findByUid(uid);
  },

  /**
   * Update online status.
   */
  async updateOnlineStatus(uid, isOnline) {
    await userRepository.update(uid, {
      isOnline,
      lastSeen: Date.now(),
    });
  },

  /**
   * Add XP and handle leveling.
   */
  async addXp(uid, amount) {
    const user = await userRepository.findByUid(uid);
    if (!user) return null;

    const newXp = (user.xp || 0) + amount;
    const newLevel = calculateLevel(newXp);
    const newRank = calculateRank(newLevel);

    await userRepository.update(uid, {
      xp: newXp,
      level: newLevel,
      rank: newRank,
    });

    return { xp: newXp, level: newLevel, rank: newRank, leveledUp: newLevel > (user.level || 1) };
  },

  /**
   * Add coins.
   */
  async addCoins(uid, amount) {
    const user = await userRepository.findByUid(uid);
    if (!user) return 0;

    const newCoins = Math.max(0, (user.coins || 0) + amount);
    await userRepository.update(uid, { coins: newCoins });
    return newCoins;
  },

  /**
   * Record game stats.
   */
  async recordGameResult(uid, { won, correctGuesses, drew }) {
    const user = await userRepository.findByUid(uid);
    if (!user) return;

    const updates = {
      totalGames: (user.totalGames || 0) + 1,
    };

    if (won) updates.totalWins = (user.totalWins || 0) + 1;
    if (correctGuesses) updates.totalCorrectGuesses = (user.totalCorrectGuesses || 0) + correctGuesses;
    if (drew) updates.totalDrawings = (user.totalDrawings || 0) + 1;

    // Recalculate accuracy
    if (updates.totalCorrectGuesses || user.totalCorrectGuesses) {
      const totalGuesses = updates.totalCorrectGuesses || user.totalCorrectGuesses || 0;
      const totalGames = updates.totalGames || user.totalGames || 1;
      updates.guessAccuracy = Math.round((totalGuesses / totalGames) * 100) / 100;
    }

    await userRepository.update(uid, updates);
  },
};

/**
 * Calculate level from total XP.
 */
function calculateLevel(xp) {
  let level = 1;
  let required = 100;
  let accumulated = 0;
  while (accumulated + required <= xp) {
    accumulated += required;
    level++;
    required = Math.round(100 * (1.5 * (level - 1) + 1));
  }
  return level;
}

/**
 * Calculate rank from level.
 */
function calculateRank(level) {
  if (level >= 50) return 'Legend';
  if (level >= 40) return 'Master';
  if (level >= 30) return 'Diamond';
  if (level >= 20) return 'Platinum';
  if (level >= 15) return 'Gold';
  if (level >= 10) return 'Silver';
  if (level >= 5) return 'Bronze';
  return 'Beginner';
}

module.exports = userService;
