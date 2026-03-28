import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lets_grow_wallet/features/account_book/model/user_character_model.dart';
import 'package:lets_grow_wallet/utils/character_interation_enum.dart';
import 'package:lets_grow_wallet/utils/kst_time.dart';
import 'package:uuid/uuid.dart';

class UserCharacterService {
  final supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  static final Map<String, String> _recordedDayByCharacterId = {};

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
              background_url,
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

  // 도감에서 선택한 캐릭터를 활성화 (기존 활성 캐릭터는 비활성화)
  Future<void> setActiveCharacterByCharacterId(String characterId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    // 1) 기존 활성 캐릭터 비활성화
    await supabase
        .from('user_characters')
        .update({'is_active': false})
        .eq('user_id', userId)
        .eq('is_active', true);

    // 2) 선택한 캐릭터 활성화
    final updated = await supabase
        .from('user_characters')
        .update({'is_active': true})
        .eq('user_id', userId)
        .eq('character_id', characterId)
        .select('id')
        .maybeSingle();

    if (updated == null) {
      throw Exception('캐릭터 활성화에 실패했습니다. (구매한 캐릭터가 아닐 수 있어요)');
    }
  }

  // 캐릭터 상호작용 기록 저장(하루 1회, 로컬 날짜 기준)
  Future<void> recordInteractionOncePerDay({
    required String characterId,
    required InteractionType interactionType,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    // KST 기준 '하루 1회' 보장 (디바이스가 UTC로 잡혀도 날짜가 밀리지 않도록)
    final now = nowKst();
    final kstDayKey =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (_recordedDayByCharacterId[characterId] == kstDayKey) return;

    // KST 자정(00:00) ~ 다음날 자정(00:00)을 UTC 타임스탬프로 변환
    final startUtc = DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(hours: 9));
    final endUtc = startUtc.add(const Duration(days: 1));

    try {
      // KST 날짜 경계를 UTC ISO 문자열로 비교 (created_at이 timestamptz라고 가정)
      final start = startUtc.toIso8601String();
      final end = endUtc.toIso8601String();

      final existing = await supabase
          .from('character_interactions')
          .select('id')
          .eq('user_id', userId)
          .eq('character_id', characterId)
          .gte('created_at', start)
          .lt('created_at', end)
          .limit(1)
          .maybeSingle();

      // 하루 1회 저장
      if (existing != null) {
        _recordedDayByCharacterId[characterId] = kstDayKey;
        return;
      }

      await supabase.from('character_interactions').insert({
        'id': _uuid.v4(),
        'user_id': userId,
        'character_id': characterId,
        'interaction_type': interactionType.name,
      });

      _recordedDayByCharacterId[characterId] = kstDayKey;
    } on PostgrestException catch (e) {
      if (e.code == '23505') return;
      rethrow;
    }
  }
}
