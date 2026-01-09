import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lets_grow_wallet/features/account_book/model/user_character_model.dart';
import 'package:lets_grow_wallet/utils/character_interation_enum.dart';
import 'package:uuid/uuid.dart';

class UserCharacterService {
  final supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  // 세션 내 중복 기록 방지(오늘 1회): characterId -> yyyy-mm-dd
  static final Map<String, String> _recordedDayByCharacterId = {};

  static String _iso8601WithTimezoneOffset(DateTime dt) {
    // 예: 2026-01-09T00:00:00.000+09:00
    final base = dt.toIso8601String();
    final offset = dt.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final abs = offset.abs();
    final hh = abs.inHours.toString().padLeft(2, '0');
    final mm = abs.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$base$sign$hh:$mm';
  }

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

  // 캐릭터 상호작용 기록 저장(하루 1회, 로컬 날짜 기준)
  Future<void> recordInteractionOncePerDay({
    required String characterId,
    required InteractionType interactionType,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final nowLocal = DateTime.now();
    final localDayKey =
        '${nowLocal.year.toString().padLeft(4, '0')}-${nowLocal.month.toString().padLeft(2, '0')}-${nowLocal.day.toString().padLeft(2, '0')}';
    if (_recordedDayByCharacterId[characterId] == localDayKey) return;

    final startOfDayLocal = DateTime(
      nowLocal.year,
      nowLocal.month,
      nowLocal.day,
    );
    final startOfNextDayLocal = startOfDayLocal.add(const Duration(days: 1));

    try {
      // 로컬 날짜 경계를 로컬 타임존 오프셋 포함 ISO 문자열로 비교
      final startLocal = _iso8601WithTimezoneOffset(startOfDayLocal);
      final endLocal = _iso8601WithTimezoneOffset(startOfNextDayLocal);

      final existing = await supabase
          .from('character_interactions')
          .select('id')
          .eq('user_id', userId)
          .eq('character_id', characterId)
          .gte('created_at', startLocal)
          .lt('created_at', endLocal)
          .limit(1)
          .maybeSingle();

      // 하루 1회 저장
      if (existing != null) {
        _recordedDayByCharacterId[characterId] = localDayKey;
        return;
      }

      await supabase.from('character_interactions').insert({
        'id': _uuid.v4(),
        'user_id': userId,
        'character_id': characterId,
        'interaction_type': interactionType.name,
      });

      _recordedDayByCharacterId[characterId] = localDayKey;
    } on PostgrestException catch (e) {
      if (e.code == '23505') return;
      rethrow;
    }
  }
}
