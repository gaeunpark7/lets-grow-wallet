import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/model/transaction_model.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/calendar_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/month_selection_notifier.dart'
    as dashboard_month;
import 'package:lets_grow_wallet/features/account_book/notifier/stats_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/services/transaction_service.dart';

class TransactionNotifier extends AsyncNotifier<List<TransactionModel>> {
  final _service = TransactionService();

  @override
  Future<List<TransactionModel>> build() async {
    return _fetchMonthlyTransactions();
  }

  // 이번 달 거래 내역 불러오기
  Future<List<TransactionModel>> _fetchMonthlyTransactions() async {
    final selectedMonth = ref.watch(dashboard_month.selectedMonthProvider);
    final start = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final end = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
    return _service.fetchTransactionsByDateRange(start, end);
  }

  // CRUD 처리 (공통 로직)
  Future<void> _refreshAfterCrud() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMonthlyTransactions());

    // 캘린더와 통계 새로고침
    ref.read(calendarStatNotifierProvider.notifier).refreshDailyStats();
    ref.read(monthlyCategoryStatsNotifierProvider.notifier).refresh();
  }

  // 거래 추가
  Future<void> addTransaction(TransactionModel transaction) async {
    await _service.addTransaction(transaction);
    await _refreshAfterCrud();
  }

  // 거래 수정
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _service.updateTransaction(transaction);
    await _refreshAfterCrud();
  }

  // 거래 삭제
  Future<void> deleteTransaction(String transactionId) async {
    await _service.deleteTransaction(transactionId);
    await _refreshAfterCrud();
  }

  // 수동 새로고침
  Future<void> refresh() async {
    await _refreshAfterCrud();
  }
}

final transactionNotifierProvider =
    AsyncNotifierProvider<TransactionNotifier, List<TransactionModel>>(() {
      return TransactionNotifier();
    });
