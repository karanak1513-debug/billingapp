class Product {
  final String id;
  final String name;
  final String category; // 'snacks' | 'drinks'
  final double sellingPrice;
  final double costPrice;
  final String portion;
  final String imageAsset;
  final String? badge;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.sellingPrice,
    required this.costPrice,
    required this.portion,
    required this.imageAsset,
    this.badge,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  bool get isBundledAsset => imageAsset.startsWith('assets/');
  bool get hasImage => imageAsset.trim().isNotEmpty;

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? sellingPrice,
    double? costPrice,
    String? portion,
    String? imageAsset,
    String? badge,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      costPrice: costPrice ?? this.costPrice,
      portion: portion ?? this.portion,
      imageAsset: imageAsset ?? this.imageAsset,
      badge: badge ?? this.badge,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'selling_price': sellingPrice,
      'cost_price': costPrice,
      'portion': portion,
      'image_asset': imageAsset,
      'badge': badge,
      'description': description,
      'is_active': isActive ? 1 : 0,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      sellingPrice: (map['selling_price'] as num).toDouble(),
      costPrice: (map['cost_price'] as num).toDouble(),
      portion: map['portion'] as String? ?? '/ portion',
      imageAsset: map['image_asset'] as String? ?? '',
      badge: map['badge'] as String?,
      description: map['description'] as String?,
      isActive: (map['is_active'] as int?) != 0,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'] as String) : null,
    );
  }
}
