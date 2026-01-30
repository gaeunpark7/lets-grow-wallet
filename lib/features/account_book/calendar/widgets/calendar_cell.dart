import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/model/daily_stat_model.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CalendarCell extends StatelessWidget {
  final DateTime day;
  final DailyStat? stat;
  final String? emotion;
  final bool isToday;
  final bool isSelected;
  final bool isOutside;
  final VoidCallback? onTap;

  const CalendarCell({
    super.key,
    required this.day,
    this.stat,
    this.emotion,
    this.isToday = false,
    this.isSelected = false,
    this.isOutside = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isOutside ? Colors.grey[300] : MainColors.mainDark;

    return GestureDetector(
      onTap: isOutside ? null : onTap,
      child: SizedBox(
        height: 110,
        width: 110,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF9FA8DA)
                : isToday
                ? const Color(0xFFF5F5FA)
                : Colors.white,
            borderRadius: BorderRadius.zero,
            border: Border.all(color: Color(0xFFE8EAF6)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              SizedBox(height: 5),
              if (emotion != null)
                Image.asset(
                  'assets/emotions/$emotion.png',
                  width: 25,
                  height: 25,
                  errorBuilder: (context, error, stackTrace) {
                    return SizedBox.shrink();
                  },
                ),
              if (stat != null) ...[
                if (stat!.totalExpense != 0)
                  Text(
                    '-${stat!.totalExpense}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.red,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (stat!.totalIncome != 0)
                  Text(
                    '+${stat!.totalIncome}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7986CB),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
