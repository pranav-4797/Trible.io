const { getMessaging } = require('../config/firebase');
const logger = require('../utils/logger');

const notificationService = {
  /**
   * Send push notification to a device token.
   */
  async sendToDevice(token, payload = {}) {
    const messaging = getMessaging();
    if (!messaging) {
      logger.warning('Firebase messaging not initialized. Skipping notification.');
      return;
    }

    try {
      const message = {
        token,
        notification: {
          title: payload.title || 'Trible',
          body: payload.body || 'You have a new message!',
        },
        data: payload.data || {},
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
      };

      const response = await messaging.send(message);
      logger.info('Successfully sent push notification', { response });
      return response;
    } catch (error) {
      logger.error('Error sending push notification', error);
    }
  },

  /**
   * Send notification to a topic.
   */
  async sendToTopic(topic, payload = {}) {
    const messaging = getMessaging();
    if (!messaging) return;

    try {
      const message = {
        topic,
        notification: {
          title: payload.title,
          body: payload.body,
        },
        data: payload.data || {},
      };

      const response = await messaging.send(message);
      logger.info(`Successfully sent notification to topic: ${topic}`, { response });
      return response;
    } catch (error) {
      logger.error('Error sending notification to topic', error);
    }
  },
};

module.exports = notificationService;
