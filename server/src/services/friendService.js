const userRepository = require('../repositories/userRepository');
const logger = require('../utils/logger');

const friendService = {
  /**
   * Send a friend request by adding to receiver's pending list or directly making friends.
   */
  async addFriend(userId, friendId) {
    try {
      const user = await userRepository.findByUid(userId);
      const friend = await userRepository.findByUid(friendId);

      if (!user || !friend) {
        throw new Error('User or friend not found');
      }

      const userFriends = user.friendIds || [];
      if (userFriends.includes(friendId)) {
        return { success: true, message: 'Already friends' };
      }

      // Directly add to friends list for simple v1 matchmaking/friends system
      const updatedUserFriends = [...new Set([...userFriends, friendId])];
      const updatedFriendFriends = [...new Set([...(friend.friendIds || []), userId])];

      await userRepository.update(userId, { friendIds: updatedUserFriends });
      await userRepository.update(friendId, { friendIds: updatedFriendFriends });

      logger.info(`Users ${userId} and ${friendId} are now friends`);
      return { success: true };
    } catch (error) {
      logger.error('Error adding friend', error);
      throw error;
    }
  },

  /**
   * Get all friends' details and status.
   */
  async getFriendsList(userId) {
    try {
      const user = await userRepository.findByUid(userId);
      if (!user || !user.friendIds || user.friendIds.length === 0) {
        return [];
      }

      const friends = await userRepository.findByUids(user.friendIds);
      return friends.map(f => ({
        uid: f.uid,
        username: f.username,
        avatar: f.avatar,
        isOnline: f.isOnline || false,
        level: f.level || 1,
      }));
    } catch (error) {
      logger.error('Error listing friends', error);
      return [];
    }
  },
};

module.exports = friendService;
