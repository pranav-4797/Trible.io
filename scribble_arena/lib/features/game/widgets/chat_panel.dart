import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// In-game chat panel for guesses and messages.
class ChatPanel extends StatefulWidget {
  final String roomId;
  final bool isDark;
  final bool isDrawer;

  const ChatPanel({
    super.key,
    required this.roomId,
    required this.isDark,
    required this.isDrawer,
  });

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  // Mock messages
  final List<_ChatMsg> _messages = [
    _ChatMsg('System', 'Game started!', type: 'system'),
    _ChatMsg('Player2', 'is it a cat?', type: 'guess'),
    _ChatMsg('Player3', 'hmm...', type: 'guess'),
    _ChatMsg('Player2', 'guessed correctly!', type: 'correct'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMsg('You', text, type: 'guess'));
    });
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: (widget.isDark ? AppColors.darkSurface : AppColors.lightSurface)
            .withValues(alpha: 0.95),
        border: Border(
          left: BorderSide(
            color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Chat', style: AppTextStyles.titleMedium(isDark: widget.isDark)),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessage(msg);
              },
            ),
          ),

          // Input (non-drawer only)
          if (!widget.isDrawer)
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Guess...',
                          filled: true,
                          fillColor: widget.isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send_rounded, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessage(_ChatMsg msg) {
    Color textColor;
    FontWeight weight = FontWeight.w400;

    switch (msg.type) {
      case 'correct':
        textColor = AppColors.correctGuess;
        weight = FontWeight.w700;
        break;
      case 'close':
        textColor = AppColors.closeGuess;
        weight = FontWeight.w600;
        break;
      case 'system':
        textColor = AppColors.secondary;
        weight = FontWeight.w500;
        break;
      default:
        textColor = widget.isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
    }

    if (msg.type == 'system') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Center(
          child: Text(
            msg.message,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.secondary.withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${msg.username}: ',
              style: AppTextStyles.chatUsername(isDark: widget.isDark),
            ),
            TextSpan(
              text: msg.message,
              style: TextStyle(
                fontSize: 13,
                color: textColor,
                fontWeight: weight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMsg {
  final String username;
  final String message;
  final String type; // 'chat', 'guess', 'correct', 'close', 'system'

  _ChatMsg(this.username, this.message, {this.type = 'chat'});
}
