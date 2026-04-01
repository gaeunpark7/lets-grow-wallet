import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/active_character_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/character_book_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/shop_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final questRewardControllerProvider = Provider<QuestRewardController>((ref) {
  return QuestRewardController(ref);
});

class QuestRewardController {
  QuestRewardController(this._ref);

  final Ref _ref;
  final SupabaseClient _supabase = Supabase.instance.client;

  static const int _rewardCoin = 15;

  Future<void> claimDailyQuestReward({required String questId}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('로그인이 필요합니다.');
    }
    if (questId.isEmpty) {
      throw Exception('유효하지 않은 퀘스트 ID입니다.');
    }

    //보상 중복 방지> reward_given=false인 행만 업데이트
    final updatedQuest = await _supabase
        .from('daily_quests')
        .update({'reward_given': true})
        .eq('id', questId)
        .eq('user_id', userId)
        .eq('reward_given', false)
        .select('id')
        .maybeSingle();

    if (updatedQuest == null) {
      return;
    }

    // coin_logs기록
    try {
      await _supabase.from('coin_logs').insert({
        'user_id': userId,
        'amount': _rewardCoin,
        'reason': '일일 퀘스트 보상',
      });
    } catch (_) {}

    // 경험치/코인 지급은 DB에서 처리
    final active = await _supabase
        .from('user_characters')
        .select('id, experience, stage')
        .eq('user_id', userId)
        .eq('is_active', true)
        .maybeSingle();

    if (active != null) {
      final userCharacterId = active['id']?.toString() ?? '';
      final exp = (active['experience'] as num?)?.toInt() ?? 0;
      final currentStage = active['stage']?.toString();
      final computedStage = exp < 300
          ? 'egg'
          : (exp < 1000 ? 'child' : 'adult');

      if (userCharacterId.isNotEmpty && currentStage != computedStage) {
        await _supabase
            .from('user_characters')
            .update({'stage': computedStage})
            .eq('id', userCharacterId)
            .eq('user_id', userId);
      }
    }

    // 화면 즉시 반영 provider
    _ref.invalidate(activeCharacterNotifierProvider);
    _ref.invalidate(characterBookNotifierProvider);
    _ref.invalidate(coinNotifierProvider);
  }
}
