import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/app_exception.dart';
import '../core/utils/logger.dart';
import '../models/user_model.dart';

/// Firebase Authentication service.
/// Handles Google Sign-In, Guest login, and user profile management.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger _logger = AppLogger('AuthService');

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      _logger.info('Starting Google Sign-In');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException.signInCancelled();
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      _logger.info('Google Sign-In successful: ${userCredential.user?.uid}');
      return userCredential;
    } on AuthException {
      rethrow;
    } catch (e, stack) {
      _logger.error('Google Sign-In failed', e, stack);
      throw AuthException.signInFailed(e);
    }
  }

  /// Sign in as guest (anonymous)
  Future<UserCredential> signInAsGuest() async {
    try {
      _logger.info('Starting Guest Sign-In');
      final userCredential = await _auth.signInAnonymously();
      _logger.info('Guest Sign-In successful: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e, stack) {
      _logger.error('Guest Sign-In failed', e, stack);
      throw AuthException.signInFailed(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _logger.info('Signing out');
      await _updateOnlineStatus(false);
      await _googleSignIn.signOut();
      await _auth.signOut();
      _logger.info('Sign out successful');
    } catch (e, stack) {
      _logger.error('Sign out failed', e, stack);
    }
  }

  /// Check if a username is already taken
  Future<bool> isUsernameTaken(String username) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e, stack) {
      _logger.error('Username check failed', e, stack);
      return false;
    }
  }

  /// Create or update user profile in Firestore
  Future<UserModel> createUserProfile({
    required String username,
    required String avatar,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw AuthException.userNotFound();

      final now = DateTime.now();
      final isGuest = user.isAnonymous;

      final userModel = UserModel(
        uid: user.uid,
        username: username,
        avatar: avatar,
        email: user.email ?? '',
        isGuest: isGuest,
        isOnline: true,
        coins: 100, // Starting coins
        xp: 0,
        level: 1,
        createdAt: now,
        lastSeen: now,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap(), SetOptions(merge: true));

      _logger.info('User profile created: ${user.uid}');
      return userModel;
    } catch (e, stack) {
      _logger.error('Create profile failed', e, stack);
      throw AuthException(message: 'Failed to create profile');
    }
  }

  /// Get user profile from Firestore
  Future<UserModel?> getUserProfile([String? uid]) async {
    try {
      final targetUid = uid ?? currentUser?.uid;
      if (targetUid == null) return null;

      final doc = await _firestore.collection('users').doc(targetUid).get();
      if (!doc.exists || doc.data() == null) return null;

      return UserModel.fromMap(doc.data()!);
    } catch (e, stack) {
      _logger.error('Get profile failed', e, stack);
      return null;
    }
  }

  /// Check if user profile exists
  Future<bool> hasProfile() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.exists && doc.data()?['username'] != null;
    } catch (e, stack) {
      _logger.error('Profile check failed', e, stack);
      return false;
    }
  }

  /// Update user's online status
  Future<void> _updateOnlineStatus(bool isOnline) async {
    try {
      final user = currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': isOnline,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      _logger.warning('Failed to update online status: $e');
    }
  }

  /// Update user profile fields
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      final user = currentUser;
      if (user == null) throw AuthException.userNotFound();

      await _firestore.collection('users').doc(user.uid).update(updates);
      _logger.info('Profile updated: ${updates.keys}');
    } catch (e, stack) {
      _logger.error('Update profile failed', e, stack);
      throw AuthException(message: 'Failed to update profile');
    }
  }

  /// Get Firebase ID token for server authentication
  Future<String?> getIdToken() async {
    try {
      return await currentUser?.getIdToken();
    } catch (e) {
      _logger.error('Get ID token failed', e);
      return null;
    }
  }

  /// Set user online
  Future<void> setOnline() => _updateOnlineStatus(true);

  /// Set user offline
  Future<void> setOffline() => _updateOnlineStatus(false);
}
