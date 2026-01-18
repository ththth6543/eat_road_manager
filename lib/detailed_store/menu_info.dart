class MenuInfo {
  final String? description;
  final String name;
  final int price;
  final String? imageUrl;
  final DateTime createdAt;

  MenuInfo({
    this.description,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.createdAt,
  });

  factory MenuInfo.fromMap(Map<String, dynamic> map) {
    return MenuInfo(
      description: map['description'] as String?,
      name: map['name'] as String,
      price: map['price'] as int,
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}