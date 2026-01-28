import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/features/account_book/services/goal_service.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/kst_time.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

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
      if (!_isCurrentMonth(month)) {
        showAppSnackBar('이번 달의 목표만 설정 가능합니다.');
        return;
      }

      final goalService = GoalService(supabase); //이번 달 목표가 이미 있는지 확인
      final expenseGoals = await goalService.isGoalExists(
        userId!,
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

      // 소비 데이터 삽입
      if (widget.expenseController.text.isNotEmpty) {
        await supabase.from('goals').insert({
          'user_id': supabase.auth.currentUser?.id,
          'month': month,
          'goal_type': 'expense',
          'target_amount': int.tryParse(
            widget.expenseController.text.replaceAll(',', ''),
          ),
          'title': widget.goalController.text,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // 수입 데이터 삽입
      if (widget.incomeController.text.isNotEmpty) {
        await supabase.from('goals').insert({
          'user_id': supabase.auth.currentUser?.id,
          'month': month,
          'goal_type': 'income',
          'target_amount': int.tryParse(
            widget.incomeController.text.replaceAll(',', ''),
          ), // 목표 금액
          'title': widget.goalController.text,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      showAppSnackBar('목표가 성공적으로 저장되었습니다.');

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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_loadingExisting) ...[
              const SizedBox(height: 8),
              Center(
                child: CircularProgressIndicator(color: MainColors.mainLight),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: widget.goalController,
              enabled: !_goalAlreadySet,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: MainColors.mainLight, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: MainColors.mainLight, width: 2),
                ),
                labelText: "이번달의 목표는?",
                labelStyle: TextStyle(
                  color: MainColors.mainDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                suffixIcon: Icon(
                  Icons.edit,
                  color: MainColors.mainLight,
                  size: 30,
                ),
                contentPadding: EdgeInsets.only(bottom: 4),
                counterText: '',
              ),
              maxLength: 12,
            ),
            const SizedBox(height: 12),
            _buildGoalsAmount(
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
            const SizedBox(height: 12),
            _buildGoalsAmount(
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
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: MainColors.mainLight,
                foregroundColor: Colors.white,
                disabledBackgroundColor: MainColors.mainLight,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                fixedSize: Size(MediaQuery.of(context).size.width * 1, 50),
              ),
              onPressed: _goalAlreadySet ? null : _saveGoal, // Supabase로 데이터 저장
              child: Text(
                _goalAlreadySet ? "목표 설정 완료" : "목표 설정",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _buildGoalsAmount extends StatelessWidget {
  const _buildGoalsAmount({
    required this.textController,
    required this.text,
    required this.hintText,
    this.isSelected = false,
    this.enabled = true,
    required this.onPressed,
  });

  final TextEditingController textController;
  final String text;
  final String hintText;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: isSelected
                ? MainColors.mainLight
                : MainColors.main,
            foregroundColor: isSelected ? Colors.white : MainColors.mainDark,
            disabledBackgroundColor: MainColors.main,
            disabledForegroundColor: MainColors.mainDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            fixedSize: Size(MediaQuery.of(context).size.width * 0.19, 45),
          ),
          onPressed: enabled ? onPressed : null,
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            child: TextField(
              controller: textController,
              enabled: enabled && isSelected,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 가능
                LengthLimitingTextInputFormatter(9), // 최대 9자리 제한
                ThousandsSeparatorInputFormatter(), // 천 단위 구분 추가
              ],
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: MainColors.mainLight),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: MainColors.mainLight, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: MainColors.mainLight, width: 1),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(',', ''); // 기존 , 제거

    // 빈 문자열 처리
    if (text.isEmpty) {
      return TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final number = int.tryParse(text); // 숫자로 변환

    if (number == null) {
      return oldValue; // 숫자가 아니면 기존 값 유지
    }

    final formattedText = NumberFormat('#,###').format(number); // 천 단위 구분
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
