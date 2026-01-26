import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/model/monthly_category_stat_model.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/transaction_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/user_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/services/stat_service.dart';

final statServiceProvider = Provider((ref) => StatService());

// 통계 화면- 월별 선택 상태관리
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

// 통계 화면- 월별 카테고리 그래프
class MonthlyCategoryStatsNotifier
    extends AsyncNotifier<List<MonthlyCategoryStat>> {
  final _statService = StatService();
  late DateTime _selectedMonth;

  @override
  Future<List<MonthlyCategoryStat>> build() async {
    // 로그인/로그아웃/계정 전환 시 통계 캐시 자동 갱신
    final userId = ref.watch(authUserIdProvider).value;
    if (userId == null) return [];

    _selectedMonth = ref.watch(selectedMonthProvider);
    ref.watch(transactionNotifierProvider); // 거래 변경시 자동 갱신
    return _fetchMonthlyCategoryStats(_selectedMonth);
  }

  Future<List<MonthlyCategoryStat>> _fetchMonthlyCategoryStats(
    DateTime month,
  ) async {
    return _statService.fetchMonthlyCategoryStats(month);
  }

  // 통계 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetchMonthlyCategoryStats(_selectedMonth),
    );
  }
}

final monthlyCategoryStatsNotifierProvider =
    AsyncNotifierProvider<
      MonthlyCategoryStatsNotifier,
      List<MonthlyCategoryStat>
    >(() {
      return MonthlyCategoryStatsNotifier();
    });

//util
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
      .where((e) => e.amount > 0)
      .toList();
}
