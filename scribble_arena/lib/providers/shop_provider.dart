import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shop_item_model.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  final profileNotifier = ref.read(profileProvider.notifier);
  final authState = ref.watch(authProvider);
  return ShopNotifier(profileNotifier, authState.user?.ownedBrushes ?? [], authState.user?.ownedThemes ?? [], authState.user?.ownedFrames ?? []);
});

class ShopState {
  final List<ShopItemModel> items;
  final bool isLoading;
  final String? error;

  const ShopState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  ShopState copyWith({
    List<ShopItemModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return ShopState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ShopNotifier extends StateNotifier<ShopState> {
  final ProfileNotifier _profileNotifier;
  final List<String> _ownedBrushes;
  final List<String> _ownedThemes;
  final List<String> _ownedFrames;

  ShopNotifier(this._profileNotifier, this._ownedBrushes, this._ownedThemes, this._ownedFrames)
      : super(const ShopState()) {
    loadShopItems();
  }

  void loadShopItems() {
    final defaultItems = [
      // Brushes
      ShopItemModel(id: 'neon', name: 'Neon Pack', emoji: '🌈', price: 200, description: 'Glow-in-the-dark brushes', category: 'brushes', isOwned: _ownedBrushes.contains('neon')),
      ShopItemModel(id: 'galaxy', name: 'Galaxy Pack', emoji: '🌌', price: 350, description: 'Starry stroke effects', category: 'brushes', isOwned: _ownedBrushes.contains('galaxy')),
      ShopItemModel(id: 'pixel', name: 'Pixel Pack', emoji: '👾', price: 150, description: 'Retro pixel brushes', category: 'brushes', isOwned: _ownedBrushes.contains('pixel')),
      ShopItemModel(id: 'calligraphy', name: 'Calligraphy', emoji: '✒️', price: 250, description: 'Elegant writing brushes', category: 'brushes', isOwned: _ownedBrushes.contains('calligraphy')),
      // Themes
      ShopItemModel(id: 'midnight', name: 'Midnight', emoji: '🌙', price: 300, description: 'Dark purple canvas', category: 'themes', isOwned: _ownedThemes.contains('midnight')),
      ShopItemModel(id: 'ocean', name: 'Ocean', emoji: '🌊', price: 300, description: 'Blue gradient canvas', category: 'themes', isOwned: _ownedThemes.contains('ocean')),
      ShopItemModel(id: 'sunset', name: 'Sunset', emoji: '🌅', price: 300, description: 'Warm orange canvas', category: 'themes', isOwned: _ownedThemes.contains('sunset')),
      ShopItemModel(id: 'forest', name: 'Forest', emoji: '🌲', price: 250, description: 'Green nature canvas', category: 'themes', isOwned: _ownedThemes.contains('forest')),
      // Frames
      ShopItemModel(id: 'gold_ring', name: 'Golden Ring', emoji: '💫', price: 500, description: 'Premium gold frame', category: 'frames', isOwned: _ownedFrames.contains('gold_ring')),
      ShopItemModel(id: 'fire_ring', name: 'Fire Ring', emoji: '🔥', price: 400, description: 'Blazing fire frame', category: 'frames', isOwned: _ownedFrames.contains('fire_ring')),
      ShopItemModel(id: 'ice_ring', name: 'Ice Ring', emoji: '❄️', price: 400, description: 'Frozen crystal frame', category: 'frames', isOwned: _ownedFrames.contains('ice_ring')),
      ShopItemModel(id: 'rainbow_ring', name: 'Rainbow Ring', emoji: '🌈', price: 450, description: 'Rainbow glow frame', category: 'frames', isOwned: _ownedFrames.contains('rainbow_ring')),
    ];
    state = state.copyWith(items: defaultItems);
  }

  Future<bool> purchaseItem(ShopItemModel item, int userCoins) async {
    if (userCoins < item.price) {
      state = state.copyWith(error: 'Not enough coins');
      return false;
    }

    try {
      state = state.copyWith(isLoading: true);
      // Calculate remaining coins
      final newCoins = userCoins - item.price;

      // Update local ownership profile
      final List<String> updatedBrushes = [..._ownedBrushes];
      final List<String> updatedThemes = [..._ownedThemes];
      final List<String> updatedFrames = [..._ownedFrames];

      if (item.category == 'brushes') {
        updatedBrushes.add(item.id);
      } else if (item.category == 'themes') {
        updatedThemes.add(item.id);
      } else if (item.category == 'frames') {
        updatedFrames.add(item.id);
      }

      await _profileNotifier.updateProfile({
        'coins': newCoins,
        'ownedBrushes': updatedBrushes,
        'ownedThemes': updatedThemes,
        'ownedFrames': updatedFrames,
      });

      // Reload
      loadShopItems();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
