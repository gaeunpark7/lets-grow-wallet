import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/features/account_book/services/goal_service.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

class GoalDialog extends StatefulWidget {
  final TextEditingController goalController;
  final TextEditingController expenseController;
  final TextEditingController incomeController;
  final int selectedButton;
  final ValueChanged<int> onButtonSelected;

  const GoalDialog({
    super.key,
    required this.goalController,
    required this.expenseController,
    required this.incomeController,
    required this.selectedButton,
    required this.onButtonSelected,
  });

  @override
  State<GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<GoalDialog> {
  int selectedButton = 0;
  late GoalService _goalService;

  @override
  void initState() {
    super.initState();
    selectedButton = widget.selectedButton; // 초기값 설정
    _goalService = GoalService(Supabase.instance.client);
  }

  Future<void> _saveGoal() async {
    final supabase = Supabase.instance.client;
    // 현재 날짜를 기준으로 이번 달을 계산
    final now = DateTime.now();
    final month = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    final userId = supabase.auth.currentUser?.id;

    try {
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이번 달 목표는 이미 설정되어 있습니다.')));
        return;
      }

      // 소비 데이터 삽입
      if (widget.expenseController.text.isNotEmpty) {
        await supabase.from('goals').insert({
          'user_id': supabase.auth.currentUser?.id, // 현재 사용자 ID
          'month': month, // 이번 달
          'goal_type': 'expense', // 소비
          'target_amount': int.tryParse(
            widget.expenseController.text.replaceAll(',', ''),
          ), // 목표 금액
          'title': widget.goalController.text, // 목표 제목
          'created_at': DateTime.now().toIso8601String(), // 생성 시간
        });
      }

      // 수입 데이터 삽입
      if (widget.incomeController.text.isNotEmpty) {
        await supabase.from('goals').insert({
          'user_id': supabase.auth.currentUser?.id, // 현재 사용자 ID
          'month': month, // 이번 달
          'goal_type': 'income', // 수입
          'target_amount': int.tryParse(
            widget.incomeController.text.replaceAll(',', ''),
          ), // 목표 금액
          'title': widget.goalController.text, // 목표 제목
          'created_at': DateTime.now().toIso8601String(), // 생성 시간
        });
      }

      // 성공 메시지 출력
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('목표가 성공적으로 저장되었습니다!')));

      Navigator.of(context).pop(); // 다이얼로그 닫기
    } catch (e) {
      // 에러 메시지 출력
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')));
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
            TextField(
              controller: widget.goalController,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: MainColors.mainLight, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: MainColors.mainLight, width: 2),
                ),
                labelText: " 이번달의 목표는?",
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
              ),
            ),
            const SizedBox(height: 12),
            _buildGoalsAmount(
              textController: widget.expenseController,
              text: "지출",
              hintText: "목표 금액을 입력하세요.",
              isSelected: selectedButton == 1,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                fixedSize: Size(MediaQuery.of(context).size.width * 1, 50),
              ),
              onPressed: _saveGoal, // Supabase로 데이터 저장
              child: const Text(
                "목표 설정",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    super.key,
    required this.textController,
    required this.text,
    required this.hintText,
    this.isSelected = false,
    required this.onPressed,
  });

  final TextEditingController textController;
  final String text;
  final String hintText;
  final bool isSelected;
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            fixedSize: Size(MediaQuery.of(context).size.width * 0.19, 45),
          ),
          onPressed: onPressed,
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
              enabled: isSelected,
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
    final text = newValue.text.replaceAll(',', ''); // 기존 ',' 제거

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

    final formattedText = NumberFormat('#,###').format(number); // 천 단위 구분 추가
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
