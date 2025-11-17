import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/model/montyle_stat_model.dart';
import 'package:lets_grow_wallet/features/account_book/services/stat_service.dart';
import '../model/daily_stat_model.dart';
import '../model/monthly_category_stat_model.dart';

final statServiceProvider = Provider((ref) => StatService());

//월별 통계 (총합)
final monthlyStatProvider = FutureProvider.family<MonthlyStat?, DateTime>((
  ref,
  month,
) {
  final svc = ref.watch(statServiceProvider);
  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 1); // 다음달 1일
  return svc.fetchMonthlyStat(start, end);
});

// 일별 통계
// final dailyStatProvider = FutureProvider.family<DailyStat?, DateTime>((
//   ref,
//   day,
// ) {
//   final svc = ref.watch(statServiceProvider);
//   return svc.fetchDailyStat(day);
// });

// 월별 카테고리별 통계
final monthlyCategoryStatsProvider =
    FutureProvider.family<List<MonthlyCategoryStat>, DateTime>((ref, month) {
      final svc = ref.watch(statServiceProvider);
      return svc.fetchMonthlyCategoryStats(month);
    });

enum StatsKind { income, expense }

List<({String id, String name, int amount})> pickAmounts(
  List<MonthlyCategoryStat> list,
  StatsKind kind,
) {
  return list
      .map(
        (e) => (
          id: e.categoryId,
          name: e.categoryName,
          amount: kind == StatsKind.income ? e.totalIncome : e.totalExpense,
        ),
      )
      .where((e) => e.amount > 0) // 0원인 카테고리는 제외
      .toList();
}

// 달 선택
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});
