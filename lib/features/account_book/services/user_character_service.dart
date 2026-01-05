import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lets_grow_wallet/features/account_book/model/user_character_model.dart';

class UserCharacterService {
  final supabase = Supabase.instance.client;

  // 활성화된 캐릭터
  Future<UserCharacterModel?> getActiveCharacter() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await supabase
        .from('user_characters')
        .select('''
            id,
            user_id,
            character_id,
            experience,
            is_active,
            stage,
            characters (
              name,
              character_images (
                character_id,
                stage,
                emotion,
                image_url,
                is_default
              )
            )
          ''')
        .eq('user_id', userId)
        .eq('is_active', true)
        .maybeSingle();

    if (response == null) return null;

    return UserCharacterModel.fromMap(response);
  }

  // 경험치 업데이트
  Future<void> updateExperience(
    String userCharacterId,
    int newExperience,
  ) async {
    try {
      await supabase
          .from('user_characters')
          .update({'experience': newExperience})
          .eq('id', userCharacterId);
    } catch (e) {
      throw Exception('경험치 업데이트 실패: $e');
    }
  }

  // 경험치
  Future<void> addExperience(String userCharacterId, int expToAdd) async {
    try {
      // 현재 경험치
      final response = await supabase
          .from('user_characters')
          .select('experience')
          .eq('id', userCharacterId)
          .single();

      final currentExp = (response['experience'] as num?)?.toInt() ?? 0;
      final newExp = currentExp + expToAdd;

      await updateExperience(userCharacterId, newExp);
    } catch (e) {
      throw Exception('경험치 추가 실패: $e');
    }
  }
}
