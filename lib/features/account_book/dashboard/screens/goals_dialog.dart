import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/goals_dialog_amount_row.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/goals_dialog_confirm.dart';
import 'package:lets_grow_wallet/features/account_book/services/goal_service.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/kst_time.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoalDialog extends StatefulWidget {
  final TextEditingController goalController;
  final TextEditingController expenseController;
  final TextEditingController incomeController;
  final int selectedButton;
  final ValueChanged<int> onButtonSelected;
  final String? month;

  const GoalDialog({
    super.key,
    required this.goalController,
    required this.expenseController,
    required this.incomeController,
    required this.selectedButton,
    this.month,
    required this.onButtonSelected,
  });

  @override
  State<GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<GoalDialog> {
  int selectedButton = 0;
  late GoalService _goalService;
  bool _loadingExisting = true;
  bool _goalAlreadySet = false;
  String? _titleErrorText;
  bool _isSaving = false;

  Future<bool> _showConfirmDialog() async {
    if (!mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => GoalsDialogConfirm(),
    );
    return result ?? false;
  }

  int? _parseAmount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed.replaceAll(',', ''));
  }

  @override
  void initState() {
    super.initState();
    selectedButton = widget.selectedButton; // 초기값 설정
    _goalService = GoalService(Supabase.instance.client);
    _loadExistingGoalIfAny();
  }

  Future<void> _loadExistingGoalIfAny() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _loadingExisting = false;
        _goalAlreadySet = false;
      });
      return;
    }

    final month =
        widget.month ??
        "${nowKst().year}-${nowKst().month.toString().padLeft(2, '0')}";

    try {
      final goals = await _goalService.getGoalsForUserMonth(userId, month);

      final expense = goals
          .where((g) => g.goalType.toLowerCase() == 'expense')
          .toList();
      final income = goals
          .where((g) => g.goalType.toLowerCase() == 'income')
          .toList();

      final hasExisting = expense.isNotEmpty || income.isNotEmpty;
      if (hasExisting) {
        // title은 첫 목표의 title을 사용
        final title = (expense.isNotEmpty ? expense.first : income.first).title;
        widget.goalController.text = title;

        if (expense.isNotEmpty) {
          final amount = expense.first.targetAmount ?? 0;
          widget.expenseController.text = NumberFormat('#,###').format(amount);
        }

        if (income.isNotEmpty) {
          final amount = income.first.targetAmount ?? 0;
          widget.incomeController.text = NumberFormat('#,###').format(amount);
        }

        // 목표가 하나만 있으면 해당 타입이 선택되도록
        if (expense.isNotEmpty && income.isEmpty) {
          selectedButton = 1;
          widget.onButtonSelected(1);
        } else if (income.isNotEmpty && expense.isEmpty) {
          selectedButton = 0;
          widget.onButtonSelected(0);
        }
      }

      if (!mounted) return;
      setState(() {
        _goalAlreadySet = hasExisting;
        _loadingExisting = false;
      });
    } catch (e) {
      // 로딩 실패 시에도 입력은 가능하게
      if (!mounted) return;
      setState(() {
        _goalAlreadySet = false;
        _loadingExisting = false;
      });
    }
  }

  bool _isCurrentMonth(String month) {
    final parts = month.split('-');
    if (parts.length != 2) return true;

    final year = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (year == null || m == null) return true;

    final now = nowKst();
    final currentMonth = DateTime(now.year, now.month, 1);
    final selected = DateTime(year, m, 1);
    return selected == currentMonth;
  }

  Future<bool> _didPersistAfterError({
    required String userId,
    required String month,
    required bool hasExpense,
    required bool hasIncome,
  }) async {
    if (!hasExpense && !hasIncome) return false;
    try {
      if (hasExpense) {
        final exists = await _goalService.isGoalExists(
          userId,
          month,
          'expense',
        );
        if (!exists) return false;
      }
      if (hasIncome) {
        final exists = await _goalService.isGoalExists(userId, month, 'income');
        if (!exists) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveGoal() async {
    final supabase = Supabase.instance.client;
    final month =
        widget.month ??
        "${nowKst().year}-${nowKst().month.toString().padLeft(2, '0')}";
    final userId = supabase.auth.currentUser?.id;

    final navigator = Navigator.maybeOf(context);
    final route = ModalRoute.of(context);

    if (_isSaving) return;

    try {
      final title = widget.goalController.text.trim();
      final expenseAmountRaw = _parseAmount(widget.expenseController.text);
      final incomeAmountRaw = _parseAmount(widget.incomeController.text);

      final hasExpenseToSave =
          (expenseAmountRaw != null && expenseAmountRaw > 0);
      final hasIncomeToSave = (incomeAmountRaw != null && incomeAmountRaw > 0);
      final hasAnyPositiveAmount = hasExpenseToSave || hasIncomeToSave;

      final hasZeroAmount = expenseAmountRaw == 0 || incomeAmountRaw == 0;

      var hasError = false;
      if (title.isEmpty) {
        hasError = true;
        _titleErrorText = '목표 이름을 작성해주세요';
      } else {
        _titleErrorText = null;
      }

      // 입력 검증: 에러 텍스트는 항상 setState로 반영
      if (hasError) {
        if (mounted) setState(() {});
      }

      if (!hasAnyPositiveAmount || hasZeroAmount) {
        showAppSnackBar('금액을 작성해주세요.');
        return;
      }

      if (hasError) {
        return;
      }

      if (!_isCurrentMonth(month)) {
        showAppSnackBar('이번 달의 목표만 설정 가능합니다.');
        return;
      }

      if (userId == null) {
        showAppSnackBar('로그인이 필요합니다.');
        return;
      }

      final goalService = GoalService(supabase); //이번 달 목표가 이미 있는지 확인
      if (hasExpenseToSave) {
        final exists = await goalService.isGoalExists(userId, month, 'expense');
        if (exists) {
          showAppSnackBar('이번 달 목표는 이미 설정되어 있습니다.');
          return;
        }
      }
      if (hasIncomeToSave) {
        final exists = await goalService.isGoalExists(userId, month, 'income');
        if (exists) {
          showAppSnackBar('이번 달 목표는 이미 설정되어 있습니다.');
          return;
        }
      }

      final confirmed = await _showConfirmDialog();
      if (!confirmed) return;

      if (!mounted) return;
      setState(() {
        _isSaving = true;
      });

      final rows = <Map<String, dynamic>>[];
      final hasExpense = hasExpenseToSave;
      final hasIncome = hasIncomeToSave;

      if (hasExpense) {
        rows.add({
          'user_id': supabase.auth.currentUser?.id,
          'month': month,
          'goal_type': 'expense',
          'target_amount': expenseAmountRaw,
          'title': title,
        });
      }

      if (hasIncome) {
        rows.add({
          'user_id': supabase.auth.currentUser?.id,
          'month': month,
          'goal_type': 'income',
          'target_amount': incomeAmountRaw, // 목표 금액
          'title': title,
        });
      }

      // 한 번의 insert로 처리해서 부분 저장/부분 실패를 방지
      await supabase.from('goals').insert(rows);

      if (!mounted) return;
      if (route?.isActive == true && navigator != null && navigator.canPop()) {
        navigator.pop();
      }

      showAppSnackBar('목표가 저장되었습니다.');
    } on PostgrestException catch (e) {
      //저장 여부 재확인 로직
      if (userId != null) {
        final expenseAmount = _parseAmount(widget.expenseController.text);
        final incomeAmount = _parseAmount(widget.incomeController.text);
        final persisted = await _didPersistAfterError(
          userId: userId,
          month: month,
          hasExpense: expenseAmount != null && expenseAmount > 0,
          hasIncome: incomeAmount != null && incomeAmount > 0,
        );
        if (persisted) {
          if (mounted &&
              route?.isActive == true &&
              navigator != null &&
              navigator.canPop()) {
            navigator.pop();
          }
          showAppSnackBar('목표가 저장되었습니다.');
          return;
        }
      }

      final parts = <String>[];
      if (e.message.isNotEmpty) parts.add(e.message);
      final details = e.details?.toString().trim();
      if (details != null && details.isNotEmpty) parts.add(details);
      final hint = e.hint?.toString().trim();
      if (hint != null && hint.isNotEmpty) parts.add(hint);
      showAppSnackBar(parts.isEmpty ? e.toString() : parts.join('\n'));
    } catch (e) {
      if (userId != null) {
        final expenseAmount = _parseAmount(widget.expenseController.text);
        final incomeAmount = _parseAmount(widget.incomeController.text);
        final persisted = await _didPersistAfterError(
          userId: userId,
          month: month,
          hasExpense: expenseAmount != null && expenseAmount > 0,
          hasIncome: incomeAmount != null && incomeAmount > 0,
        );
        if (persisted) {
          if (mounted &&
              route?.isActive == true &&
              navigator != null &&
              navigator.canPop()) {
            navigator.pop();
          }
          showAppSnackBar('목표가 저장되었습니다.');
          return;
        }
      }

      showAppSnackBar('저장 중 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_loadingExisting) ...[
                  SizedBox(height: 8.hClamp),
                  Center(
                    child: CircularProgressIndicator(
                      color: MainColors.mainLight,
                    ),
                  ),
                  SizedBox(height: 12.hClamp),
                ],
                TextField(
                  style: TextStyle(
                    color: const Color.fromARGB(255, 84, 99, 128),
                    fontFamily: 'ScoreMedium',
                    fontWeight: FontWeight.bold,
                    fontSize: 18.spClamp,
                  ),
                  controller: widget.goalController,
                  enabled: !_goalAlreadySet,
                  onChanged: (value) {
                    if (_titleErrorText == null) return;
                    if (value.trim().isNotEmpty) {
                      setState(() {
                        _titleErrorText = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: MainColors.mainLight,
                        width: 2,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: MainColors.mainLight,
                        width: 2,
                      ),
                    ),
                    labelText: "이번달의 목표는?",
                    labelStyle: TextStyle(
                      fontFamily: 'ScoreMedium',
                      color: MainColors.mainDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.spClamp,
                    ),
                    errorText: _goalAlreadySet ? null : _titleErrorText,
                    suffixIcon: Icon(
                      Icons.edit,
                      color: MainColors.mainLight,
                      size: 30.hClamp,
                    ),
                    contentPadding: EdgeInsets.only(bottom: 4),
                    counterText: '',
                  ),
                  maxLength: 10,
                ),
                SizedBox(height: 12.hClamp),
                GoalsDialogAmountRow(
                  textController: widget.expenseController,
                  text: "지출",
                  hintText: "목표 금액을 입력하세요.",
                  isSelected: selectedButton == 1,
                  enabled: !_goalAlreadySet,
                  onPressed: () {
                    setState(() {
                      selectedButton = 1;
                      widget.onButtonSelected(1);
                    });
                  },
                ),
                SizedBox(height: 12.hClamp),
                GoalsDialogAmountRow(
                  textController: widget.incomeController,
                  text: "수입",
                  hintText: "목표 금액을 입력하세요.",
                  isSelected: selectedButton == 0,
                  enabled: !_goalAlreadySet,
                  onPressed: () {
                    setState(() {
                      selectedButton = 0;
                      widget.onButtonSelected(0);
                    });
                  },
                ),
                SizedBox(height: 12.hClamp),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: MainColors.mainLight,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: MainColors.mainLight,
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    fixedSize: Size(
                      MediaQuery.of(context).size.width * 1,
                      50.hClamp,
                    ),
                  ),
                  onPressed: (_goalAlreadySet || _isSaving)
                      ? null
                      : _saveGoal, // Supabase로 데이터 저장
                  child: Text(
                    _isSaving
                        ? '저장 중...'
                        : (_goalAlreadySet ? "목표 설정 완료" : "목표 설정"),
                    style: TextStyle(
                      fontSize: 16.spClamp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ScoreMedium',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
