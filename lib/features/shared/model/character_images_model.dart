class CharacterImagesModel {
  final String characterId;
  final String stage;
  final String imageUrl;
  final String emotion;
  final bool isDefault;
  CharacterImagesModel({
    required this.characterId,
    required this.stage,
    required this.imageUrl,
    required this.emotion,
    required this.isDefault,
  });

  factory CharacterImagesModel.fromMap(Map<String, dynamic> map) {
    return CharacterImagesModel(
      characterId: map['character_id'] ?? '',
      stage: map['stage'] ?? 'egg',
      imageUrl: map['image_url'] ?? '',
      emotion: map['emotion'] ?? 'basic',
      isDefault: map['is_default'] ?? false,
    );
  }
}
