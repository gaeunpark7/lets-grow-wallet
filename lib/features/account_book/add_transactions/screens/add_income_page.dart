import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/transaction_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/screens/add_expense_page.dart';
import 'package:lets_grow_wallet/features/account_book/services/transaction_service.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/widgets/category_selector.dart';
import 'package:lets_grow_wallet/features/main/widgets/date_selector.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/widgets/payment_amount_row.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/widgets/title_button.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../model/transaction_model.dart';
import '../../model/category_model.dart';

class AddIncomePage extends ConsumerStatefulWidget {
  const AddIncomePage({super.key});

  @override
  ConsumerState<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends ConsumerState<AddIncomePage> {
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
    loadCategories();
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

  Future<void> _addTransaction(
    TransactionModel transaction,
    WidgetRef ref,
  ) async {
    try {
      await ref
          .read(transactionNotifierProvider.notifier)
          .addTransaction(transaction);
    } catch (e) {
      rethrow;
    }
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
              primary: MainColors.mainLight,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: MainColors.mainDark),
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

  //기본 카테고리 불러오기
  Future<void> loadCategories() async {
    final service = TransactionServiceIncome();
    final fetched = await service.fetchCategories();
    setState(() {
      categories = fetched;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                // 지출/수입 선택 (지출만 파란색)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            context.push('${Routes.home}/${Routes.addExpense}'),
                        child: TitleButton(
                          color: MainColors.main,
                          border: Border(),
                          text: "지출",
                          textColor: MainColors.mainDark,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TitleButton(
                        color: MainColors.mainLight,
                        text: "수입",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // 날짜 선택
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: DateSelector(
                        selectedDate: selectedDate,
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    SizedBox(width: 12),
                    // 제목 입력
                    Expanded(
                      child: TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          hintText: "제목을 입력하세요",
                          hintStyle: TextStyle(color: MainColors.mainDark),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: MainColors.mainDark,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: MainColors.mainDark,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                  maxLength: 50,
                  maxLines: 4,
                  minLines: 3,
                  decoration: const InputDecoration(
                    hintText: '메모 입력',
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MainColors.mainDark,
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MainColors.mainDark,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MainColors.mainLight,
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

                      try {
                        final transaction = TransactionModel(
                          id: Uuid().v4(),
                          userId: userId,
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
                          createdAt: DateTime.now(),
                          type: 'income',
                        );
                        await _addTransaction(transaction, ref);
                        if (mounted) {
                          context.push(Routes.home);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('수입 추가 실패: $e')),
                          );
                        }
                      }
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
