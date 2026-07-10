const admin = require('firebase-admin');
const config = require('./environment');
const logger = require('../utils/logger');

let db = null;
let auth = null;
let storage = null;
let messaging = null;

/**
 * Initialize Firebase Admin SDK.
 * Uses service account credentials from environment variables.
 */
function initializeFirebase() {
  try {
    if (admin.apps.length > 0) {
      logger.info('Firebase already initialized');
      return;
    }

    const serviceAccount = {
      projectId: config.firebase.projectId,
      clientEmail: config.firebase.clientEmail,
      privateKey: config.firebase.privateKey,
    };

    // Only initialize with credentials if they exist
    const initConfig = {};
    if (serviceAccount.projectId && serviceAccount.clientEmail && serviceAccount.privateKey) {
      initConfig.credential = admin.credential.cert(serviceAccount);
    }
    if (config.firebase.databaseUrl) {
      initConfig.databaseURL = config.firebase.databaseUrl;
    }
    if (config.firebase.storageBucket) {
      initConfig.storageBucket = config.firebase.storageBucket;
    }

    admin.initializeApp(initConfig);

    db = admin.firestore();
    auth = admin.auth();
    storage = admin.storage();
    messaging = admin.messaging();

    // Firestore settings
    db.settings({
      ignoreUndefinedProperties: true,
    });

    logger.info('Firebase Admin SDK initialized successfully');
  } catch (error) {
    logger.error('Failed to initialize Firebase', { error: error.message });
    // Don't crash — allow server to start without Firebase for local dev
    logger.warn('Server will run without Firebase. Some features will be unavailable.');
  }
}

/**
 * Get Firestore instance
 */
function getFirestore() {
  if (!db) {
    logger.warn('Firestore not initialized');
  }
  return db;
}

/**
 * Get Firebase Auth instance
 */
function getAuth() {
  if (!auth) {
    logger.warn('Firebase Auth not initialized');
  }
  return auth;
}

/**
 * Get Firebase Storage instance
 */
function getStorage() {
  if (!storage) {
    logger.warn('Firebase Storage not initialized');
  }
  return storage;
}

/**
 * Get Firebase Messaging instance
 */
function getMessaging() {
  if (!messaging) {
    logger.warn('Firebase Messaging not initialized');
  }
  return messaging;
}

module.exports = {
  initializeFirebase,
  getFirestore,
  getAuth,
  getStorage,
  getMessaging,
  admin,
};
