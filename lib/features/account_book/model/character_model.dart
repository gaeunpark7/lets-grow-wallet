class CharacterModel {
  final String id;
  final String name;
  final String description;
  final int price;
  final String image;
  final bool isAvailable;

  CharacterModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.isAvailable,
  });
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
