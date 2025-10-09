import 'package:lets_grow_wallet/features/account_book/model/category_model.dart';
import 'package:lets_grow_wallet/features/account_book/model/transaction_model.dart';
import 'package:lets_grow_wallet/utils/category_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {
  final supabase = Supabase.instance.client;

  //내역 추가 - 소비
  Future<void> addTransaction(TransactionModel transaction) async {
    await supabase.from('transactions').insert(transaction.toMap());
  }

  //  거래 내역 조회 (조인)
  // Future<List<TransactionModel>> fetchTransactions() async {
  //   final response = await supabase
  //       .from('transactions')
  //       .select('*, categories(name)')
  //       .order('date', ascending: false);
  //   print(response);
  //   return (response as List).map((e) => TransactionModel.fromMap(e)).toList();
  // }

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
