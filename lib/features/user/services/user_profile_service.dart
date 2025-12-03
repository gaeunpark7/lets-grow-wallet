import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/user_profile_model.dart';

class UserProfileService {
  final supabase = Supabase.instance.client;

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
}
