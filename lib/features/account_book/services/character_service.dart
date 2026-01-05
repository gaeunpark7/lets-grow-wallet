import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/character_model.dart';

class CharacterService {
  //상점 - 캐릭터 목록 조회
  Future<List<CharacterModel>> fetchCharacters() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('characters')
          .select('''
      id,
      name,
      description,
      price,
      is_available,
      character_images!inner (
        image_url,
        is_default
      )
    ''')
          .eq('character_images.is_default', true);
      final List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(response);

      print(response);
      return dataList.map((data) => CharacterModel.fromMap(data)).toList();
    } on PostgrestException catch (e) {
      print(" Postgres Error: ${e.message}");
      throw Exception("Postgres error: ${e.message}");
    } catch (e) {
      print(" Unknown Error: $e");
      throw Exception("Unknown error: $e");
    }
  }
}
