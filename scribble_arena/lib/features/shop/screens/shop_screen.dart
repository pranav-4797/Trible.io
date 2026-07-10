import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Shop screen for purchasing brushes, themes, and avatar frames.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ─── Brush Packs ───
            _sectionTitle('Brush Packs', Icons.brush_rounded, isDark)
                .animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 12),
            _buildShopGrid([
              _ShopItem('Neon Pack', '🌈', 200, 'Glow-in-the-dark brushes'),
              _ShopItem('Galaxy Pack', '🌌', 350, 'Starry stroke effects'),
              _ShopItem('Pixel Pack', '👾', 150, 'Retro pixel brushes'),
              _ShopItem('Calligraphy', '✒️', 250, 'Elegant writing brushes'),
            ], isDark).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: 24),

            // ─── Themes ───
            _sectionTitle('Themes', Icons.palette_rounded, isDark)
                .animate().fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 12),
            _buildShopGrid([
              _ShopItem('Midnight', '🌙', 300, 'Dark purple canvas'),
              _ShopItem('Ocean', '🌊', 300, 'Blue gradient canvas'),
              _ShopItem('Sunset', '🌅', 300, 'Warm orange canvas'),
              _ShopItem('Forest', '🌲', 250, 'Green nature canvas'),
            ], isDark).animate().fadeIn(duration: 400.ms, delay: 300.ms),

            const SizedBox(height: 24),

            // ─── Avatar Frames ───
            _sectionTitle('Avatar Frames', Icons.auto_awesome_rounded, isDark)
                .animate().fadeIn(duration: 400.ms, delay: 400.ms),
            const SizedBox(height: 12),
            _buildShopGrid([
              _ShopItem('Golden Ring', '💫', 500, 'Premium gold frame'),
              _ShopItem('Fire Ring', '🔥', 400, 'Blazing fire frame'),
              _ShopItem('Ice Ring', '❄️', 400, 'Frozen crystal frame'),
              _ShopItem('Rainbow Ring', '🌈', 450, 'Rainbow glow frame'),
            ], isDark).animate().fadeIn(duration: 400.ms, delay: 500.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.headlineMedium(isDark: isDark)),
      ],
    );
  }

  Widget _buildShopGrid(List<_ShopItem> items, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(item.name, style: AppTextStyles.titleMedium(isDark: isDark)),
              const SizedBox(height: 2),
              Text(item.description, style: AppTextStyles.bodySmall(isDark: isDark), textAlign: TextAlign.center),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coinGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text('${item.price}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShopItem {
  final String name;
  final String emoji;
  final int price;
  final String description;

  _ShopItem(this.name, this.emoji, this.price, this.description);
}
