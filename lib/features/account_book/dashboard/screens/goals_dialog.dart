import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  Future<void> _saveGoal() async {
    final supabase = Supabase.instance.client;
    final month =
        widget.month ??
        "${nowKst().year}-${nowKst().month.toString().padLeft(2, '0')}";
    final userId = supabase.auth.currentUser?.id;

    try {
      final title = widget.goalController.text.trim();
      final expenseAmount = _parseAmount(widget.expenseController.text);
      final incomeAmount = _parseAmount(widget.incomeController.text);
      final hasAnyAmount = expenseAmount != null || incomeAmount != null;

      var hasError = false;
      if (title.isEmpty) {
        hasError = true;
        _titleErrorText = '목표 이름을 작성해주세요';
      } else {
        _titleErrorText = null;
      }

      if (!hasAnyAmount) {
        showAppSnackBar('금액을 작성해주세요.');
        return;
      }

      if (hasError) {
        if (mounted) setState(() {});
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
      final expenseGoals = await goalService.isGoalExists(
        userId,
        month,
        'expense',
      );
      final incomeGoals = await goalService.isGoalExists(
        userId,
        month,
        'income',
      );

      if (expenseGoals || incomeGoals) {
        showAppSnackBar('이번 달 목표는 이미 설정되어 있습니다.');
        return;
      }

      final confirmed = await _showConfirmDialog();
      if (!confirmed) return;

      // 소비 데이터 삽입
      if (expenseAmount != null) {
        await supabase.from('goals').insert({
          'user_id': supabase.auth.currentUser?.id,
          'month': month,
          'goal_type': 'expense',
          'target_amount': expenseAmount,
          'title': title,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // 수입 데이터 삽입
      if (incomeAmount != null) {
        await supabase.from('goals').insert({
          'user_id': supabase.auth.currentUser?.id,
          'month': month,
          'goal_type': 'income',
          'target_amount': incomeAmount, // 목표 금액
          'title': title,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      showAppSnackBar('이번달의 목표가 저장되었습니다.');
      if (!mounted) return;
      Navigator.of(context).pop(); // 다이얼로그 닫기
    } catch (e) {
      showAppSnackBar('저장 중 오류가 발생했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_loadingExisting) ...[
                SizedBox(height: 8.hClamp),
                Center(
                  child: CircularProgressIndicator(color: MainColors.mainLight),
                ),
                SizedBox(height: 12.hClamp),
              ],
              TextField(
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
                onPressed: _goalAlreadySet
                    ? null
                    : _saveGoal, // Supabase로 데이터 저장
                child: Text(
                  _goalAlreadySet ? "목표 설정 완료" : "목표 설정",
                  style: TextStyle(
                    fontSize: 16.spClamp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
