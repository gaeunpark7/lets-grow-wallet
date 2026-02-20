import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/screens/add_expense_page.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/widgets/calendar_design.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/transaction_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/services/transaction_service.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/widgets/category_selector.dart';
import 'package:lets_grow_wallet/features/main/widgets/date_selector.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/widgets/payment_amount_row.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/utils/kst_time.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/transaction_model.dart';
import '../../model/category_model.dart';

class EditExpensePage extends ConsumerStatefulWidget {
  final TransactionModel transaction;
  const EditExpensePage({super.key, required this.transaction});

  @override
  ConsumerState<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends ConsumerState<EditExpensePage> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final memoController = TextEditingController();

  DateTime selectedDate = todayKst();
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
    if (!mounted) return;
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
    final now = nowKst();
    final first = DateTime(2026, 1, 1);
    final last = DateTime(now.year, now.month, now.day); //오늘까지만 선택 가능

    final initial = selectedDate.isBefore(first)
        ? first
        : (selectedDate.isAfter(last) ? last : selectedDate);

    final DateTime? picked = await showDatePicker(
      context: context,
      currentDate: todayKst(),
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      locale: const Locale('ko'),
      builder: (context, child) {
        return CalendarDesign(child: child!);
      },
    );
    // if (!mounted) return;
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _updateTransaction(
    TransactionModel transaction,
    WidgetRef ref,
  ) async {
    try {
      await ref
          .read(transactionNotifierProvider.notifier)
          .updateTransaction(transaction);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: MainColors.mainLight,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            '지출 수정',
            style: TextStyle(
              fontSize: 24.spClamp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'ScoreMedium',
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.wClamp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 18.hClamp),
                // 날짜 선택
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 157,
                      child: DateSelector(
                        selectedDate: selectedDate,
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    SizedBox(width: 12.wClamp),
                    // 제목 입력
                    Expanded(
                      child: TextField(
                        controller: titleController,
                        style: TextStyle(
                          color: MainColors.mainDark,
                          fontFamily: 'ScoreMedium',
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          hintText: "제목을 입력하세요",
                          hintStyle: TextStyle(
                            color: MainColors.mainDark.withOpacity(0.6),
                            fontFamily: 'ScoreMedium',
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12.wClamp,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: MainColors.mainDark,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: MainColors.mainDark,
                              width: 2,
                            ),
                          ),
                        ),
                        maxLength: 8,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.hClamp),
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
                // SizedBox(height: 8.hClamp),
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

                const SizedBox(height: 18),
                TextField(
                  controller: memoController,
                  style: TextStyle(
                    color: MainColors.mainDark,
                    fontFamily: 'ScoreMedium',
                  ),
                  inputFormatters: [MaxLinesTextInputFormatter(maxLines: 4)],
                  maxLength: 50,
                  maxLines: 4,
                  minLines: 3,
                  decoration: InputDecoration(
                    hintText: '메모 입력',
                    hintStyle: TextStyle(
                      color: MainColors.mainDark.withOpacity(0.6),
                      fontFamily: 'ScoreMedium',
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                        color: MainColors.mainDark,
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                        color: MainColors.mainDark,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18.hClamp),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MainColors.mainLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 0,
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
                        showAppSnackBar('로그인이 필요합니다.');
                        return;
                      }
                      if (selectedCategoryIdx == null) {
                        showAppSnackBar('카테고리를 선택해주세요.');
                        return;
                      }

                      if (amountController.text.trim().isEmpty) {
                        showAppSnackBar('금액을 입력해주세요.');
                        return;
                      }
                      if (selectedCategoryIdx == null) return;

                      final titleText = titleController.text.trim().isEmpty
                          ? categories[selectedCategoryIdx!].label
                          : titleController.text.trim();
                      final transaction = TransactionModel(
                        id: widget.transaction.id,
                        userId: userId,
                        title: titleText,
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
                      try {
                        await _updateTransaction(transaction, ref);
                        if (!mounted) return;

                        final didPop = await Navigator.of(context).maybePop();
                        if (!didPop) {
                          if (!mounted) return;
                          context.go(Routes.home);
                        }
                        showAppSnackBar('수정되었습니다.');
                      } catch (e) {
                        showAppSnackBar('수정에 실패하였습니다. 다시 시도해주세요.');
                        print("수정 실패: $e");
                      }
                    },
                    child: Text(
                      "지출 수정",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'ScoreMedium',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.hClamp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
