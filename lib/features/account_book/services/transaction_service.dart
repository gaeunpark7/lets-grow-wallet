import 'package:lets_grow_wallet/features/account_book/model/category_model.dart';
import 'package:lets_grow_wallet/features/account_book/model/transaction_model.dart';
import 'package:lets_grow_wallet/utils/category_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {
  final supabase = Supabase.instance.client;

  String _formatDateOnly(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }

  int _compareByDayDescTimeAsc(TransactionModel a, TransactionModel b) {
    final aDay = DateTime(a.date.year, a.date.month, a.date.day);
    final bDay = DateTime(b.date.year, b.date.month, b.date.day);

    final dayCompare = bDay.compareTo(aDay); // 날짜는 내림차순
    if (dayCompare != 0) return dayCompare;

    // 같은 날짜의  created_at기준 오름차순
    return a.createdAt.compareTo(b.createdAt);
  }

  //내역 추가 - 소비
  Future<void> addTransaction(TransactionModel transaction) async {
    await supabase.from('transactions').insert(transaction.toMap());
  }

  // 날짜 범위로 거래 내역 조회 (카테고리 이름 포함)
  Future<List<TransactionModel>> fetchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final startDate = _formatDateOnly(start);
    final endDate = _formatDateOnly(end);

    final response = await supabase
        .from('transactions')
        .select('*, categories(name)')
        .gte('date', startDate)
        .lt('date', endDate)
        .order('date', ascending: false)
        .order('created_at', ascending: true);

    final transactions = (response as List)
        .map((e) => TransactionModel.fromMap(e))
        .toList();
    transactions.sort(_compareByDayDescTimeAsc);
    return transactions;
  }

  // 거래 내역 수정
  Future<void> updateTransaction(TransactionModel transaction) async {
    await supabase
        .from('transactions')
        .update(transaction.toMap())
        .eq('id', transaction.id);
  }

  // 거래 내역 삭제
  Future<void> deleteTransaction(String transactionId) async {
    await supabase.from('transactions').delete().eq('id', transactionId);
  }

  //카테고리 목록 조회
  Future<List<Category>> fetchCategories() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('categories')
        .select()
        .isFilter('user_id', null)
        .eq('type', 'expense');

    return (response as List)
        .map(
          (e) => Category(
            id: e['id'].toString(),
            icon: getCategoryIcon(e['name']),
            label: e['name'],
          ),
        )
        .toList();
  }
}

//수입 내역 추가
class TransactionServiceIncome {
  final supabase = Supabase.instance.client;

  Future<void> addTransaction(TransactionModel transaction) async {
    await supabase.from('transactions').insert(transaction.toMap());
  }

  Future<List<Category>> fetchCategories() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('categories')
        .select()
        .isFilter('user_id', null)
        .eq('type', 'income');

    return (response as List)
        .map(
          (e) => Category(
            id: e['id'].toString(),
            icon: getCategoryIcon(e['name']),
            label: e['name'],
          ),
        )
        .toList();
  }
}
