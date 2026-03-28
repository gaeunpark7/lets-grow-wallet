class CharacterModel {
  //캐릭터구매
  final String id;
  final String name;
  final String description;
  final int price;
  final String image;
  final bool isAvailable;
  final bool isPurchased;
  // 0 = 가장 최근 구매, 값이 작을수록 최근
  final int? purchaseRank;

  CharacterModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.isAvailable,
    this.isPurchased = false,
    this.purchaseRank,
  });

  CharacterModel copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    String? image,
    bool? isAvailable,
    bool? isPurchased,
    int? purchaseRank,
  }) {
    return CharacterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      isAvailable: isAvailable ?? this.isAvailable,
      isPurchased: isPurchased ?? this.isPurchased,
      purchaseRank: purchaseRank ?? this.purchaseRank,
    );
  }

  factory CharacterModel.fromMap(Map<String, dynamic> map) {
    final images = (map['character_images'] as List<dynamic>?) ?? [];

    // 기본 이미지(알) 가져오기
    final defaultImage = images.isNotEmpty
        ? images.firstWhere(
                (img) => img['is_default'] == true,
                orElse: () => {'image_url': ''},
              )['image_url'] ??
              ''
        : '';

    return CharacterModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'] ?? 0,
      isAvailable: map['is_available'],
      image: defaultImage,
    );
  }
}
