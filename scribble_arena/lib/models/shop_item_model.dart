import 'package:equatable/equatable.dart';

class ShopItemModel extends Equatable {
  final String id;
  final String name;
  final String emoji;
  final int price;
  final String description;
  final String category; // 'brushes' | 'themes' | 'frames'
  final bool isOwned;

  const ShopItemModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.description,
    required this.category,
    this.isOwned = false,
  });

  factory ShopItemModel.fromMap(Map<String, dynamic> map) {
    return ShopItemModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      emoji: map['emoji'] as String? ?? '🎁',
      price: map['price'] as int? ?? 100,
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'brushes',
      isOwned: map['isOwned'] as bool? ?? false,
    );
  }

  ShopItemModel copyWith({
    String? id,
    String? name,
    String? emoji,
    int? price,
    String? description,
    String? category,
    bool? isOwned,
  }) {
    return ShopItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      isOwned: isOwned ?? this.isOwned,
    );
  }

  @override
  List<Object?> get props => [id, name, price, isOwned];
}
