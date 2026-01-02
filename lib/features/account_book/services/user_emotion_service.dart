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
}
