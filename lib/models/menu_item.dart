class MenuItem {
  final String? id;
  final String? description;
  final String name;
  final int price;
  final String? imageUrl;
  final DateTime? createdAt;

  MenuItem({
    this.id,
    this.description,
    required this.name,
    required this.price,
    this.imageUrl,
    this.createdAt,
  });

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id']?.toString(),
      description: map['description'] as String?,
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      imageUrl: map['image_url'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap({String? storeId}) {
    final map = <String, dynamic>{
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl,
    };
    if (storeId != null) {
      map['store_id'] = storeId;
    }
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }
    return map;
  }
}

// Alias for existing MenuInfo usages
typedef MenuInfo = MenuItem;
