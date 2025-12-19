import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/model/transaction_model.dart';
import 'package:lets_grow_wallet/features/account_book/services/transaction_service.dart';

class TransactionNotifier extends AsyncNotifier<List<TransactionModel>> {
  final _service = TransactionService();

  @override
  Future<List<TransactionModel>> build() async {
    // 초기 데이터 로드
    return _fetchMonthlyTransactions();
  }

  // 이번 달 거래 내역 불러오기
  Future<List<TransactionModel>> _fetchMonthlyTransactions() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    return _service.fetchTransactionsByDateRange(start, end);
  }

  // 거래 추가 후 목록 새로고침
  Future<void> addTransaction(TransactionModel transaction) async {
    await _service.addTransaction(transaction);
    // 데이터 다시 로드
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMonthlyTransactions());
  }

  // 거래 수정 후 목록 새로고침
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _service.updateTransaction(transaction);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMonthlyTransactions());
  }

  // 거래 삭제 후 목록 새로고침
  Future<void> deleteTransaction(String transactionId) async {
    await _service.deleteTransaction(transactionId);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMonthlyTransactions());
  }

  // 수동 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMonthlyTransactions());
  }
}

final transactionProvider =
    AsyncNotifierProvider<TransactionNotifier, List<TransactionModel>>(
      () => TransactionNotifier(),
    );
