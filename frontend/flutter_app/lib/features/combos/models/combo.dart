class ComboModel {
  final String id;
  final String name;
  final String? description;
  final double sellingPrice;
  final double costPrice;
  final String imageAsset;
  final String? badge;
  final bool isActive;
  final List<String> includedProductIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ComboModel({
    required this.id,
    required this.name,
    this.description,
    required this.sellingPrice,
    this.costPrice = 0.0,
    required this.imageAsset,
    this.badge,
    this.isActive = true,
    this.includedProductIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'selling_price': sellingPrice,
      'cost_price': costPrice,
      'image_asset': imageAsset,
      'badge': badge,
      'is_active': isActive ? 1 : 0,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory ComboModel.fromMap(
    Map<String, dynamic> map, {
    List<String> includedProductIds = const [],
  }) {
    return ComboModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      sellingPrice: (map['selling_price'] as num).toDouble(),
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0.0,
      imageAsset: map['image_asset'] as String? ?? '',
      badge: map['badge'] as String?,
      isActive: (map['is_active'] as int?) != 0,
      includedProductIds: includedProductIds,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'] as String) : null,
    );
  }
}
