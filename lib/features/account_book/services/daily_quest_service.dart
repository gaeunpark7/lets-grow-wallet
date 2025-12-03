import 'package:lets_grow_wallet/features/account_book/model/daily_quest_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DailyQuestService {
  final supabase = Supabase.instance.client;

  // 오늘 퀘스트 조회하기
  Future<List<DailyQuest>> getTodayQuests() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      print('DailyQuestService.getTodayQuests: no current user');
      return [];
    }
    final userId = user.id;

    final today = DateTime.now();
    final start = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();
    final end = DateTime(
      today.year,
      today.month,
      today.day,
      23,
      59,
      59,
    ).toIso8601String();

    print(
      'DailyQuestService.getTodayQuests: user=$userId start=$start end=$end',
    );

    try {
      final response = await supabase
          .from('daily_quests')
          .select()
          .eq('user_id', userId)
          .gte('created_at', start)
          .lte('created_at', end);

      print('DailyQuestService.getTodayQuests raw response: $response');

      final list = List<Map<String, dynamic>>.from(response);
      final result = <DailyQuest>[];
      for (var m in list) {
        try {
          // created_at이 null일 수 있으므로 안전하게 파싱
          final createdAtRaw = m['created_at'];
          final createdAt = createdAtRaw != null
              ? DateTime.parse(createdAtRaw.toString())
              : DateTime.now();
          result.add(
            DailyQuest(
              id: m['id'] is int
                  ? m['id'] as int
                  : int.tryParse('${m['id']}') ?? 0,
              questType: m['quest_type']?.toString() ?? '',
              isCompleted: m['is_completed'] == true,
              rewardGiven: m['reward_given'] == true,
              createdAt: createdAt,
            ),
          );
        } catch (e, st) {
          print('DailyQuestService: failed to parse item $m -> $e\n$st');
          // parsing 실패 항목은 건너뜀
        }
      }
      print('DailyQuestService.getTodayQuests parsed count: ${result.length}');
      return result;
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

    await supabase
        .from('daily_quests')
        .update({'is_completed': true})
        .eq('user_id', userId)
        .eq('quest_type', questType)
        .gte(
          'created_at',
          "${DateTime.now().toIso8601String().substring(0, 10)} 00:00:00",
        );
  }
}
