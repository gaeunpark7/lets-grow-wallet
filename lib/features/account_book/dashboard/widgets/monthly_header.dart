import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/goals_dialog.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class MonthlyHeader extends StatefulWidget {
  const MonthlyHeader({super.key});

  @override
  State<MonthlyHeader> createState() => _MonthlyHeaderState();
}

class _MonthlyHeaderState extends State<MonthlyHeader> {
  var goalController = TextEditingController();
  var expenseController = TextEditingController();
  var incomeController = TextEditingController();
  int selectedButton = 0; //기본 0, 눌리면 1

  @override
  void dispose() {
    goalController.dispose();
    expenseController.dispose();
    incomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // 반응형 너비
    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          Spacer(),
          Spacer(),
          Text(
            "이번달의 목표는?",
            style: TextStyle(
              color: MainColors.mainDark,
              fontSize: screenWidth * 0.06, // 반응형 폰트
              fontWeight: FontWeight.w900,
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => GoalDialog(
                  goalController: goalController,
                  expenseController: expenseController,
                  incomeController: incomeController,
                  selectedButton: selectedButton,
                  onButtonSelected: (int index) {
                    setState(() {
                      selectedButton = index;
                    });
                  },
                ),
              );
            },
            child: Icon(Icons.edit_square, size: 30, color: MainColors.point),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
