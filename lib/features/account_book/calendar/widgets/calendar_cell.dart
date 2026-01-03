import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/calendar/screens/calendar_detail.dart';
import 'package:lets_grow_wallet/features/account_book/model/daily_stat_model.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CalendarCell extends StatelessWidget {
  final DateTime day;
  final DailyStat? stat;
  final bool isToday;
  final bool isSelected;
  final bool isOutside;

  const CalendarCell({
    super.key,
    required this.day,
    this.stat,
    this.isToday = false,
    this.isSelected = false,
    this.isOutside = false,
  });

  IconData _getEmotionIcon(String? emotionIcon) {
    switch (emotionIcon) {
      case 'happy':
        return Icons.sentiment_satisfied_outlined;
      case 'basic':
        return Icons.sentiment_neutral_outlined;
      case 'sad':
        return Icons.sentiment_dissatisfied_outlined;
      default:
        return Icons.sentiment_satisfied_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = isOutside ? Colors.grey[300] : MainColors.mainDark;

    return GestureDetector(
      onTap: isOutside
          ? null
          : () {
              showDialog(
                context: context,
                builder: (ctx) => CalendartDetail(selectedDate: day),
              );
            },
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
              if (stat != null) ...[
                Icon(
                  _getEmotionIcon(
                    stat!.emotionIcon.isEmpty ? null : stat!.emotionIcon,
                  ),
                  color: MainColors.mainLight,
                  size: 20,
                ),
                SizedBox(height: 5),
                if (stat!.totalExpense != 0)
                  Text(
                    '- ${stat!.totalExpense}',
                    style: const TextStyle(fontSize: 11, color: Colors.red),
                  ),
                if (stat!.totalIncome != 0)
                  Text(
                    '+${stat!.totalIncome}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7986CB),
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
