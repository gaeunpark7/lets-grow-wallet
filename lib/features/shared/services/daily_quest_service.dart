import 'package:lets_grow_wallet/features/account_book/model/daily_quest_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DailyQuestService {
  final supabase = Supabase.instance.client;

  // kst 날짜 형식으로 변환(한국 시간 기준)
  String _formatKstDate(DateTime dt) {
    final kst = dt.toUtc().add(const Duration(hours: 9));
    return '${kst.year.toString().padLeft(4, '0')}-'
        '${kst.month.toString().padLeft(2, '0')}-'
        '${kst.day.toString().padLeft(2, '0')}';
  }

  // 오늘 퀘스트 조회하기
  Future<List<DailyQuest>> getTodayQuests() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return [];
    }
    final userId = user.id;
    final todayDate = _formatKstDate(DateTime.now());

    try {
      final response = await supabase
          .from('daily_quests')
          .select()
          .eq('user_id', userId)
          .eq('user_date', todayDate);

      final list = List<Map<String, dynamic>>.from(response);
      return list.map(DailyQuest.fromMap).toList(growable: false);
    } catch (e, st) {
      print('DailyQuestService.getTodayQuests error: $e\n$st');
      return [];
    }
  }

  /// 오늘 퀘스트 자동 생성
  Future<void> createTodayQuestsIfNeeded() async {
    final quests = await getTodayQuests();

    if (quests.isNotEmpty) return; // 이미 생성됨

    final userId = supabase.auth.currentUser!.id;

    final questTypes = [
      'register_transaction',
      'character_interaction',
      'register_emotion',
    ];

    for (final type in questTypes) {
      await supabase.from('daily_quests').insert({
        'user_id': userId,
        'quest_type': type,
        'is_completed': false,
        'reward_given': false,
      });
    }
  }

  /// 퀘스트 완료 처리
  Future<void> completeQuest(String questType) async {
    final userId = supabase.auth.currentUser!.id;
    final todayDate = _formatKstDate(DateTime.now());

    await supabase
        .from('daily_quests')
        .update({'is_completed': true})
        .eq('user_id', userId)
        .eq('quest_type', questType)
        .eq('user_date', todayDate);
  }

  //퀘스트 보상 지급
  Future<void> giveReward({required String questId}) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('로그인이 필요합니다.');
    }
    if (questId.isEmpty) {
      throw Exception('유효하지 않은 퀘스트 ID입니다.');
    }

    await supabase
        .from('daily_quests')
        .update({'reward_given': true})
        .eq('id', questId)
        .eq('user_id', userId);
  }
}
