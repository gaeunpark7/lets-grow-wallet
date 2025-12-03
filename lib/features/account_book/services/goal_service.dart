import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/goal_model.dart';

class GoalService {
  final SupabaseClient _client;

  GoalService(this._client);

  Future<bool> isGoalExists(
    String userId,
    String month,
    String goalType,
  ) async {
    final response = await _client
        .from('goals')
        .select()
        .eq('user_id', userId)
        .eq('month', month)
        .eq('goal_type', goalType)
        .maybeSingle(); // 단일 결과

    if (response == null) {
      return false;
    }

    return true;
  }

  // 목표 저장- 중복방지
  Future<void> saveGoal(GoalModel goal) async {
    final exists = await isGoalExists(goal.userId!, goal.month, goal.goalType);

    if (exists) {
      throw Exception('이미 해당 달에 목표가 존재합니다.');
    }

    final response = await _client.from('goals').insert(goal.toJson());

    if (response == null) {
      throw Exception('Error saving goal: 데이터 삽입 실패');
    }
  }

  //이번달 목표 가져오기.
  Future<String?> getGoalTitle(String userId, String month) async {
    try {
      final response = await _client
          .from('goals')
          .select('title')
          .eq('user_id', userId)
          .eq('month', month)
          .limit(1)
          .maybeSingle();
      print('Supabase 응답: $response');

      return response?['title'] as String?;
    } catch (e) {
      print('목표를 가져오는 중 오류 발생: $e');
      throw Exception('목표를 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  //특정 달의 모든 목표 조회
  Future<List<GoalModel>> getGoalsForUserMonth(
    String userId,
    String month,
  ) async {
    try {
      final resp = await _client
          .from('goals')
          .select('*')
          .eq('user_id', userId)
          .eq('month', month);
      final List data = resp ?? [];
      return data
          .map((e) => GoalModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      print('getGoalsForUserMonth error: $e');
      return [];
    }
  }
}
