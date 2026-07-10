/// Socket.IO event names shared between client and server.
/// Keeps all event strings in one place to prevent typos.
class SocketEvents {
  SocketEvents._();

  // ─── Connection ───
  static const String connect = 'connect';
  static const String disconnect = 'disconnect';
  static const String reconnect = 'reconnect';
  static const String error = 'error';
  static const String connectError = 'connect_error';

  // ─── Authentication ───
  static const String authenticate = 'authenticate';
  static const String authenticated = 'authenticated';
  static const String authError = 'auth_error';

  // ─── Room ───
  static const String createRoom = 'room:create';
  static const String roomCreated = 'room:created';
  static const String joinRoom = 'room:join';
  static const String roomJoined = 'room:joined';
  static const String leaveRoom = 'room:leave';
  static const String roomLeft = 'room:left';
  static const String roomUpdate = 'room:update';
  static const String roomClosed = 'room:closed';
  static const String roomError = 'room:error';
  static const String roomSettings = 'room:settings';
  static const String roomSettingsUpdated = 'room:settings_updated';

  // ─── Lobby ───
  static const String playerJoined = 'lobby:player_joined';
  static const String playerLeft = 'lobby:player_left';
  static const String playerReady = 'lobby:player_ready';
  static const String playerUnready = 'lobby:player_unready';
  static const String playerKicked = 'lobby:player_kicked';
  static const String kickPlayer = 'lobby:kick';
  static const String lobbyUpdate = 'lobby:update';

  // ─── Matchmaking ───
  static const String findMatch = 'matchmaking:find';
  static const String matchFound = 'matchmaking:found';
  static const String matchCancelled = 'matchmaking:cancelled';
  static const String cancelMatch = 'matchmaking:cancel';
  static const String matchmakingStatus = 'matchmaking:status';

  // ─── Game Flow ───
  static const String gameStart = 'game:start';
  static const String gameStarting = 'game:starting';
  static const String gameEnd = 'game:end';
  static const String roundStart = 'game:round_start';
  static const String roundEnd = 'game:round_end';
  static const String turnStart = 'game:turn_start';
  static const String turnEnd = 'game:turn_end';
  static const String wordChoices = 'game:word_choices';
  static const String wordChosen = 'game:word_chosen';
  static const String wordHint = 'game:word_hint';
  static const String timerTick = 'game:timer';
  static const String gameState = 'game:state';
  static const String rematch = 'game:rematch';
  static const String rematchVote = 'game:rematch_vote';
  static const String rematchAccepted = 'game:rematch_accepted';

  // ─── Drawing ───
  static const String drawStart = 'draw:start';
  static const String drawMove = 'draw:move';
  static const String drawEnd = 'draw:end';
  static const String drawBatch = 'draw:batch';
  static const String drawUndo = 'draw:undo';
  static const String drawClear = 'draw:clear';
  static const String drawFill = 'draw:fill';
  static const String canvasState = 'draw:canvas_state';

  // ─── Chat & Guessing ───
  static const String chatMessage = 'chat:message';
  static const String chatGuess = 'chat:guess';
  static const String guessResult = 'chat:guess_result';
  static const String correctGuess = 'chat:correct';
  static const String closeGuess = 'chat:close';
  static const String chatTyping = 'chat:typing';
  static const String chatReaction = 'chat:reaction';
  static const String chatSystem = 'chat:system';

  // ─── Score ───
  static const String scoreUpdate = 'score:update';
  static const String leaderboardUpdate = 'score:leaderboard';
  static const String roundScores = 'score:round';
  static const String finalScores = 'score:final';

  // ─── Player Status ───
  static const String playerOnline = 'player:online';
  static const String playerOffline = 'player:offline';
  static const String playerReconnecting = 'player:reconnecting';
  static const String playerReconnected = 'player:reconnected';
  static const String playerDisconnected = 'player:disconnected';

  // ─── Friends ───
  static const String friendRequest = 'friend:request';
  static const String friendAccepted = 'friend:accepted';
  static const String friendDeclined = 'friend:declined';
  static const String friendRemoved = 'friend:removed';
  static const String friendInvite = 'friend:invite';

  // ─── Notifications ───
  static const String notification = 'notification';
}
