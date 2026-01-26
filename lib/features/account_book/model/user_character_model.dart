import 'package:lets_grow_wallet/features/account_book/model/character_images_model.dart';
import 'package:lets_grow_wallet/utils/character_interation_enum.dart';
import 'package:lets_grow_wallet/utils/character_interaction_overrides.dart';

class UserCharacterModel {
  final String id;
  final String userId;
  final String characterId;
  final int experience;
  final bool isActive;
  final String characterName;
  final String characterImage;
  final Stage stage;
  final List<CharacterImagesModel> characterImages;

  bool get isSelected => isActive;

  UserCharacterModel({
    required this.id,
    required this.userId,
    required this.characterId,
    required this.experience,
    required this.isActive,
    required this.characterName,
    required this.characterImage,
    required this.stage,
    required this.characterImages,
  });

  factory UserCharacterModel.fromMap(Map<String, dynamic> map) {
    final character = map['characters'] as Map<String, dynamic>?;
    final characterImagesRaw =
        (character?['character_images'] as List<dynamic>?) ?? const [];

    final parsedImages = characterImagesRaw
        .whereType<Map<String, dynamic>>()
        .map(CharacterImagesModel.fromMap)
        .toList(growable: false);

    final exp = (map['experience'] as num?)?.toInt() ?? 0;
    // 혹시 stage가 비어있을 때만 experience로 fallback
    final stage = _parseStage(map['stage']) ?? stageFromExperience(exp);

    final defaultImageUrl = _defaultImageUrlForStage(
      stage: stage,
      images: parsedImages,
    );

    return UserCharacterModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      characterId: map['character_id'] ?? '',
      experience: exp,
      isActive: map['is_active'] ?? false,
      characterName: character?['name'] ?? '',
      characterImage: defaultImageUrl,
      stage: stage,
      characterImages: parsedImages,
    );
  }

  static Stage stageFromExperience(int experience) {
    if (experience < 300) return Stage.egg;
    if (experience < 1000) return Stage.child;
    return Stage.adult;
  }

  static Stage? _parseStage(dynamic value) {
    if (value is String) {
      switch (value) {
        case 'egg':
          return Stage.egg;
        case 'child':
          return Stage.child;
        case 'adult':
          return Stage.adult;
      }
    }
    return null;
  }

  static String _defaultImageUrlForStage({
    required Stage stage,
    required List<CharacterImagesModel> images,
  }) {
    final stageNames = _stageNamesFor(stage);

    // 1) 현재 stage의 is_default
    for (final img in images) {
      if (stageNames.contains(img.stage) && img.isDefault) {
        return img.imageUrl;
      }
    }

    // 2) 현재 stage의 basic 감정
    for (final img in images) {
      if (stageNames.contains(img.stage) && img.emotion == Emotion.basic.name) {
        return img.imageUrl;
      }
    }

    // 3) 현재 stage의 아무 이미지
    for (final img in images) {
      if (stageNames.contains(img.stage)) {
        return img.imageUrl;
      }
    }

    return '';
  }

  String imageUrlForEmotion(Emotion emotion) {
    final stageNames = _stageNamesFor(stage);

    for (final img in characterImages) {
      if (stageNames.contains(img.stage) && img.emotion == emotion.name) {
        return img.imageUrl;
      }
    }

    return characterImage;
  }

  static Set<String> _stageNamesFor(Stage stage) {
    return {stage.name};
  }

  Emotion emotionForInteraction(InteractionType interaction) {
    final stageOverrides =
        interactionEmotionOverridesByStage[characterId]?[stage];

    final overrideEmotion = stageOverrides?[interaction];
    if (overrideEmotion != null) return overrideEmotion;

    return resolveEmotion(interaction: interaction);
  }
}
