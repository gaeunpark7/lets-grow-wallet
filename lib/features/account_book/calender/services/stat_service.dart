import 'package:lets_grow_wallet/features/account_book/calender/model/daily_stat_model.dart';
import 'package:lets_grow_wallet/features/account_book/calender/model/montyle_stat_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatService {
  final supabase = Supabase.instance.client;

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
}
