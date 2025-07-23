import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/features/account_book/services/transaction_service.dart';
import 'package:lets_grow_wallet/features/account_book/widgets/category_selector.dart';
import 'package:lets_grow_wallet/features/account_book/widgets/date_selector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../model/transaction_model.dart';
import '../model/category_model.dart';
// import 'package:lets_grow_wallet/utils/category_utils.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
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

  //supabase transaction model
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('transactions')
          .insert(transaction.toMap());
    } catch (e) {
      rethrow;
    }
  }

  //기본 카테고리 불러오기
  Future<void> loadCategories() async {
    final service = TransactionService();
    final fetched = await service.fetchCategories();
    setState(() {
      categories = fetched;
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

  Widget singleButton({
    required String text,
    required bool selected,
    required VoidCallback onTap,
    BorderRadius? borderRadius,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.white,
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: borderRadius,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
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
                      child: title_button(
                        Colors.white,
                        Border.all(color: Colors.black, width: 1),
                        "수입",
                      ),
                    ),
                    Expanded(
                      child: title_button(
                        Colors.blue,
                        Border(
                          left: BorderSide.none,
                          top: BorderSide(color: Colors.black),
                          right: BorderSide(color: Colors.black),
                          bottom: BorderSide(color: Colors.black),
                        ),
                        "지출",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
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
                Row(
                  children: [
                    singleButton(
                      text: "카드",
                      selected: selectedPayType == 0,
                      onTap: () {
                        setState(() {
                          selectedPayType = 0;
                        });
                      },
                    ),
                    singleButton(
                      text: "현금",
                      selected: selectedPayType == 1,
                      onTap: () {
                        setState(() {
                          selectedPayType = 1;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 38,
                        child: TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          maxLength: 12,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "금액",
                            isDense: true,
                            counterText: "",
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                          ),
                          onChanged: (value) {
                            final formatted = formatAmount(
                              value.replaceAll(',', ''),
                            );
                            if (formatted != value) {
                              amountController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                  offset: formatted.length,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
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
                        // 로그인 안 된 경우 처리(예: 알림, 로그인 페이지 이동 등)
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
                        id: Uuid().v4(),
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
                        createdAt: DateTime.now(),
                        type: 'expense',
                      );
                      await addTransaction(transaction);
                      // 저장 후 처리(예: 화면 닫기, 메시지 등)
                      Navigator.pop(context, true);
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

  Container title_button(Color color, Border border, String text) {
    return Container(
      decoration: BoxDecoration(color: color, border: border),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
