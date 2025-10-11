import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

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
              isSelected: widget.selectedButton == 1,
              onPressed: () {
                setState(() {
                  widget.onButtonSelected(1);
                });
              },
            ),
            const SizedBox(height: 12),
            _buildGoalsAmount(
              textController: widget.incomeController,
              text: "수입",
              hintText: "목표 금액을 입력하세요.",
              isSelected: widget.selectedButton == 0,
              onPressed: () {
                setState(() {
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
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
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
