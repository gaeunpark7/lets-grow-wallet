import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/screens/add_expense_page.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/widgets/calendar_design.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/transaction_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/services/transaction_service.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/widgets/category_selector.dart';
import 'package:lets_grow_wallet/features/main/widgets/date_selector.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/widgets/payment_amount_row.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/widgets/title_button.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/interstitial_ad_controller.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/friendly_error_message.dart';
import 'package:lets_grow_wallet/utils/kst_time.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';
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
  bool _isSaving = false;

  DateTime selectedDate = todayKst();
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

  //기본 카테고리 불러오기
  Future<void> loadCategories() async {
    final service = TransactionServiceIncome();
    final fetched = await service.fetchCategories();
    setState(() {
      categories = fetched;
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
    if (!mounted) return;

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.wClamp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 18.hClamp),
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
                    SizedBox(width: 15.wClamp),
                    Expanded(
                      child: TitleButton(
                        color: MainColors.mainLight,
                        text: "수입",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.hClamp),
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
                          hintText: "제목을 입력하세요",
                          hintStyle: TextStyle(
                            fontFamily: 'ScoreMedium',
                            color: MainColors.mainDark.withOpacity(0.6),
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          counterStyle: TextStyle(
                            fontFamily: 'ScoreMedium',
                            color: MainColors.mainDark.withOpacity(0.7),
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
                SizedBox(height: 10.hClamp),
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

                SizedBox(height: 18.hClamp),
                TextField(
                  controller: memoController,
                  style: TextStyle(
                    color: MainColors.mainDark,
                    fontFamily: 'ScoreMedium',
                  ),
                  inputFormatters: [MaxLinesTextInputFormatter(maxLines: 4)],
                  maxLength: 50,
                  maxLines: 3,
                  minLines: 3,
                  decoration: InputDecoration(
                    hintText: '메모 입력',
                    hintStyle: TextStyle(
                      color: MainColors.mainDark.withOpacity(0.6),
                      fontFamily: 'ScoreMedium',
                    ),
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
                    counterStyle: TextStyle(
                      fontFamily: 'ScoreMedium',
                      color: MainColors.mainDark.withOpacity(0.7),
                    ),
                  ),
                ),
                SizedBox(height: 10.hClamp),
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
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () async {
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

                            try {
                              setState(() {
                                _isSaving = true;
                              });
                              final titleText =
                                  titleController.text.trim().isEmpty
                                  ? categories[selectedCategoryIdx!].label
                                  : titleController.text.trim();
                              final transaction = TransactionModel(
                                id: Uuid().v4(),
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
                                createdAt: nowKst(),
                                type: 'income',
                              );
                              await _addTransaction(transaction, ref);

                              // 3번마다 전면 광고
                              await ref
                                  .read(
                                    interstitialAdControllerProvider.notifier,
                                  )
                                  .onTransactionAdded();

                              if (mounted) {
                                context.go(Routes.home);
                              }
                            } catch (e) {
                              if (mounted) {
                                showAppSnackBar(FriendlyErrorMessage.of(e));
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isSaving = false;
                                });
                              }
                            }
                          },
                    child: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: MainColors.mainLight,
                            ),
                          )
                        : Text(
                            "수입 추가",
                            style: TextStyle(
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
