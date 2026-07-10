const { getFirestore } = require('../config/firebase');
const logger = require('../utils/logger');

// In-memory fallback for dev without Firebase
const memoryStore = new Map();

const userRepository = {
  /**
   * Create a user document.
   */
  async create(user) {
    const db = getFirestore();
    if (db) {
      await db.collection('users').doc(user.uid).set(user);
    } else {
      memoryStore.set(user.uid, { ...user });
    }
    return user;
  },

  /**
   * Find user by UID.
   */
  async findByUid(uid) {
    const db = getFirestore();
    if (db) {
      const doc = await db.collection('users').doc(uid).get();
      return doc.exists ? doc.data() : null;
    }
    return memoryStore.get(uid) || null;
  },

  /**
   * Find user by username (case-insensitive).
   */
  async findByUsername(username) {
    const db = getFirestore();
    if (db) {
      const snapshot = await db
        .collection('users')
        .where('username', '==', username.toLowerCase())
        .limit(1)
        .get();
      return snapshot.empty ? null : snapshot.docs[0].data();
    }
    for (const user of memoryStore.values()) {
      if (user.username?.toLowerCase() === username.toLowerCase()) {
        return user;
      }
    }
    return null;
  },

  /**
   * Update user fields.
   */
  async update(uid, updates) {
    const db = getFirestore();
    if (db) {
      await db.collection('users').doc(uid).update(updates);
    } else {
      const existing = memoryStore.get(uid);
      if (existing) {
        memoryStore.set(uid, { ...existing, ...updates });
      }
    }
  },

  /**
   * Delete a user document.
   */
  async delete(uid) {
    const db = getFirestore();
    if (db) {
      await db.collection('users').doc(uid).delete();
    } else {
      memoryStore.delete(uid);
    }
  },

  /**
   * Get top users by a field (for leaderboards).
   */
  async getTopUsers(field, limit = 50) {
    const db = getFirestore();
    if (db) {
      const snapshot = await db
        .collection('users')
        .orderBy(field, 'desc')
        .limit(limit)
        .get();
      return snapshot.docs.map((doc) => doc.data());
    }
    return Array.from(memoryStore.values())
      .sort((a, b) => (b[field] || 0) - (a[field] || 0))
      .slice(0, limit);
  },

  /**
   * Get multiple users by UIDs.
   */
  async findByUids(uids) {
    if (uids.length === 0) return [];

    const db = getFirestore();
    if (db) {
      // Firestore 'in' query supports max 30 items
      const chunks = [];
      for (let i = 0; i < uids.length; i += 30) {
        chunks.push(uids.slice(i, i + 30));
      }

      const results = [];
      for (const chunk of chunks) {
        const snapshot = await db
          .collection('users')
          .where('uid', 'in', chunk)
          .get();
        results.push(...snapshot.docs.map((doc) => doc.data()));
      }
      return results;
    }

    return uids
      .map((uid) => memoryStore.get(uid))
      .filter((u) => u != null);
  },
};

module.exports = userRepository;
