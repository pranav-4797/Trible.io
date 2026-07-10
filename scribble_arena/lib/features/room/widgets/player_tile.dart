import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/room_model.dart';

/// Player tile in the lobby showing avatar, name, ready status.
class PlayerTile extends StatelessWidget {
  final RoomPlayer player;
  final bool isCurrentUser;
  final bool isDark;

  const PlayerTile({
    super.key,
    required this.player,
    this.isCurrentUser = false,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.1)
            : (isDark ? AppColors.darkCard : AppColors.lightCard),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentUser
              ? AppColors.primary.withValues(alpha: 0.3)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
            ),
            child: Center(
              child: Text(player.avatar, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),

          // Name & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.username,
                      style: AppTextStyles.titleMedium(isDark: isDark),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(You)',
                        style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
                if (player.isHost)
                  Text(
                    'Host',
                    style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                      color: AppColors.xpGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),

          // Ready Status
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: player.isReady
                  ? AppColors.neonGreen.withValues(alpha: 0.15)
                  : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: player.isReady
                    ? AppColors.neonGreen.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: Text(
              player.isReady ? 'Ready' : 'Waiting',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: player.isReady
                    ? AppColors.neonGreen
                    : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
              ),
            ),
          ),

          // Connection indicator
          if (!player.isConnected)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 18),
            ),
        ],
      ),
    );
  }
}
