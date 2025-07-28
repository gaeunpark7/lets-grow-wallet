import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/screens/add_income_page.dart';
import 'package:lets_grow_wallet/features/account_book/main/main_page.dart';
import 'package:lets_grow_wallet/features/account_book/services/transaction_service.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/widgets/category_selector.dart';
import 'package:lets_grow_wallet/features/account_book/main/widgets/date_selector.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/widgets/payment_amount_row.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/widgets/single_button.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/widgets/title_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../model/transaction_model.dart';
import '../../model/category_model.dart';

class EditExpensePage extends StatefulWidget {
  final TransactionModel transaction;
  const EditExpensePage({super.key, required this.transaction});

  @override
  State<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final memoController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  int? selectedCategoryIdx;
  int selectedPayType = 0; // 0: 카드, 1: 현금
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    // 기존 데이터로 컨트롤러 및 상태 초기화
    final tx = widget.transaction;
    titleController.text = tx.title;
    amountController.text = NumberFormat('#,###').format(tx.amount);
    memoController.text = tx.memo;
    selectedDate = tx.date;
    selectedPayType = tx.paymentMethod;
    loadCategories(tx.categoryId);
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    memoController.dispose();
    super.dispose();
  }

  // 금액 입력시 3자리마다 콤마
  String formatAmount(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll(',', '')) ?? 0;
    return NumberFormat('#,###').format(number);
  }

  //기존 카테고리 불러오기
  Future<void> loadCategories(String? currentCategoryId) async {
    final service = TransactionService();
    final fetched = await service.fetchCategories();
    int? idx;
    if (currentCategoryId != null) {
      idx = fetched.indexWhere((c) => c.id == currentCategoryId);
      if (idx == -1) idx = null;
    }
    setState(() {
      categories = fetched;
      selectedCategoryIdx = idx;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade400,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade400,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  //수정
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('transactions')
          .update(transaction.toMap())
          .eq('id', transaction.id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            '지출 수정',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                // 지출/수입 선택 (지출만 파란색)

                // 날짜 선택
                DateSelector(
                  selectedDate: selectedDate,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 18),
                // 제목 입력
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "제목을 입력하세요",
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // 카테고리 선택
                CategorySelector(
                  categories: categories,
                  selectedIndex: selectedCategoryIdx,
                  onCategorySelected: (idx) {
                    setState(() {
                      selectedCategoryIdx = idx;
                    });
                  },
                ),
                const SizedBox(height: 18),
                // 결제수단 + 금액 입력
                PaymentAmountRow(
                  selectedPayType: selectedPayType,
                  onPayTypeChanged: (type) {
                    setState(() {
                      selectedPayType = type;
                    });
                  },
                  amountController: amountController,
                  formatAmount: formatAmount,
                ),

                const SizedBox(height: 24),
                TextField(
                  controller: memoController,
                  maxLines: 4,
                  minLines: 3,
                  decoration: const InputDecoration(
                    hintText: '메모 입력',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      final userId =
                          Supabase.instance.client.auth.currentUser?.id;
                      if (userId == null) {
                        // 로그인 안 된 경우 처리
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('로그인이 필요합니다.')),
                        );
                        return;
                      }
                      if (selectedCategoryIdx == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('카테고리를 선택해주세요.')),
                        );
                        return;
                      }

                      if (amountController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('금액을 입력해주세요.')),
                        );
                        return;
                      }
                      if (selectedCategoryIdx == null) return;
                      final transaction = TransactionModel(
                        id: widget.transaction.id,
                        userId: userId, // 실제 로그인 유저 uuid로 대체
                        title: titleController.text,
                        amount:
                            int.tryParse(
                              amountController.text.replaceAll(',', ''),
                            ) ??
                            0, //콤마제거
                        categoryId: categories[selectedCategoryIdx!].id,
                        paymentMethod: selectedPayType,
                        memo: memoController.text,
                        date: selectedDate,
                        createdAt: widget.transaction.createdAt,
                        type: 'expense',
                      );
                      await updateTransaction(transaction);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('수정되었습니다.')));

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => MainPage()),
                      );
                    },
                    child: const Text("지출 추가"),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
