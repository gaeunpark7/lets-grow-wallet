import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class MonthlyGoals extends StatelessWidget {
  final String goalTitle;
  final String subtitle;
  const MonthlyGoals({
    super.key,
    required this.goalTitle,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        constraints: BoxConstraints(minHeight: 80),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: MainColors.mainLight),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                goalTitle,
                style: TextStyle(fontSize: 18, color: MainColors.mainDark),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: MainColors.mainLight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
