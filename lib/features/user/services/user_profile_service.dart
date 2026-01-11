import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/user_profile_model.dart';

class UserProfileService {
  final supabase = Supabase.instance.client;

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<UserProfileModel?> getUserProfile(String userId) async {
    final response = await supabase
        .from('user')
        .select(
          '''id, nickname, email, user_characters!inner(is_active, characters(character_images(image_url)))''',
        )
        .eq('id', userId)
        .eq('user_characters.is_active', true)
        .maybeSingle();

    if (response == null) return null;
    return UserProfileModel.fromMap(response);
  }

  //닉네임 수정
  Future<void> updateNickname(String userId, String newNickname) async {
    await supabase
        .from('user')
        .update({'nickname': newNickname})
        .eq('id', userId);
  }

  // 코인 조회
  Future<int> getUserCoin(String userId) async {
    final response = await supabase
        .from('user')
        .select('coin')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return 0;
    return _parseInt(response['coin']);
  }
}
