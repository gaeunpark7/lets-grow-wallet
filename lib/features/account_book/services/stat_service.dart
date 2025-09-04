import 'package:lets_grow_wallet/features/account_book/model/daily_stat_model.dart';
import 'package:lets_grow_wallet/features/account_book/model/monthly_category_stat_model.dart';
import 'package:lets_grow_wallet/features/account_book/model/montyle_stat_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatService {
  final supabase = Supabase.instance.client;
  //월별 통계
  Future<MonthlyStat?> fetchMonthlyStat(DateTime date) async {
    final start = DateTime(date.year, date.month);
    final end = DateTime(date.year, date.month + 1);

    final user = supabase.auth.currentUser;

    final result = await supabase
        .from('monthly_stats')
        .select()
        .eq('user_id', user!.id)
        .gte('month', start.toIso8601String())
        .lt('month', end.toIso8601String());

    if (result.isEmpty) return null;

    return MonthlyStat.fromMap(result.first);
  }

  //일별 통계
  Future<DailyStat?> fetchDailyStat(DateTime date) async {
    final user = supabase.auth.currentUser;

    final result = await supabase
        .from('daily_stats')
        .select()
        .eq('user_id', user!.id)
        .eq('day', date.toIso8601String().split('T')[0]); // '2025-08-08'

    if (result.isEmpty) return null;

    return DailyStat.fromMap(result.first);
  }

  // 카테고리 별 통계
  Future<List<MonthlyCategoryStat>> fetchMonthlyCategoryStats(
    DateTime month,
  ) async {
    final user = supabase.auth.currentUser!;
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    final rows = await supabase
        .from('monthly_category_stats')
        .select()
        .eq('user_id', user.id)
        .gte('month', start.toIso8601String())
        .lt('month', end.toIso8601String());

    return (rows as List)
        .map((m) => MonthlyCategoryStat.fromMap(m as Map<String, dynamic>))
        .toList();
  }
}
