import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    selectedButton = widget.selectedButton; // 초기값 설정
  }

  Future<void> _saveGoal() async {
    final supabase = Supabase.instance.client;
    // 현재 날짜를 기준으로 이번 달을 계산
    final now = DateTime.now();
    final month = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    try {
      // 소비 데이터 삽입
      if (widget.expenseController.text.isNotEmpty) {
        await supabase.from('goals').insert({
          'user_id': supabase.auth.currentUser?.id, // 현재 사용자 ID
          'month': month, // 이번 달
          'goal_type': 'expense', // 소비
          'target_amount': int.tryParse(widget.expenseController.text), // 목표 금액
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
          'target_amount': int.tryParse(widget.incomeController.text), // 목표 금액
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
                  Icons.mood_outlined,
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
