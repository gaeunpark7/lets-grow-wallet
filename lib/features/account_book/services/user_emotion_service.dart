import 'package:supabase_flutter/supabase_flutter.dart';

class UserEmotionService {
  final supabase = Supabase.instance.client;

  Future<void> saveEmotion({
    required String iconName,
    required DateTime date,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요합니다.');

    final today = DateTime.now();
    if (date.year != today.year ||
        date.month != today.month ||
        date.day != today.day) {
      throw Exception('오늘의 감정만 등록할 수 있습니다.');
    }

    final dateString = date.toIso8601String().substring(0, 10);

    // 기존 감정이 있는지 확인
    final existing = await supabase
        .from('emotions')
        .select()
        .eq('user_id', userId)
        .eq('date', dateString)
        .maybeSingle();

    if (existing != null) {
      throw Exception('이미 오늘의 감정을 등록했어요.');
    }
    // 새로 삽입
    await supabase.from('emotions').insert({
      'user_id': userId,
      'icon_name': iconName,
      'date': dateString,
    });
  }

  Future<String?> getEmotion({required DateTime date}) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final dateString = date.toIso8601String().substring(0, 10);

    final response = await supabase
        .from('emotions')
        .select('icon_name')
        .eq('user_id', userId)
        .eq('date', dateString)
        .maybeSingle();

    return response?['icon_name'] as String?;
  }

  Future<Map<DateTime, String>> getEmotionsByMonth(DateTime month) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return {};

    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);
    final startDateString = startDate.toIso8601String().substring(0, 10);
    final endDateString = endDate.toIso8601String().substring(0, 10);

    final response = await supabase
        .from('emotions')
        .select('date, icon_name')
        .eq('user_id', userId)
        .gte('date', startDateString)
        .lte('date', endDateString);

    final Map<DateTime, String> emotionMap = {};
    for (var item in response) {
      final dateString = item['date'] as String;
      final parts = dateString.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      emotionMap[date] = item['icon_name'] as String;
    }

    return emotionMap;
  }
}
