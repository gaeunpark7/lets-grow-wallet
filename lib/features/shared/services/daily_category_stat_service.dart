import 'package:lets_grow_wallet/features/account_book/model/daily_category_stat_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DailyCategoryStatService {
  final supabase = Supabase.instance.client;

  Future<List<DailyCategoryStatModel>> fetchDailyCategoryStat({
    required DateTime date,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final response = await supabase
        .from('daily_category_stats')
        .select()
        .eq('user_id', user.id)
        .eq('date', date.toIso8601String().substring(0, 10));

    return response
        .map<DailyCategoryStatModel>((e) => DailyCategoryStatModel.fromMap(e))
        .toList();
  }
}
