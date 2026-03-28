import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/model/daily_stat_model.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

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
        height: 110.hClamp,
        width: 110.wClamp,
        child: Container(
          decoration: BoxDecoration(
            // color: isSelected
            //     ? const Color(0xFF9FA8DA)
            //     :
            color: isToday ? const Color(0xFFF5F5FA) : Colors.white,
            borderRadius: BorderRadius.zero,
            border: Border.all(color: Color(0xFFE8EAF6)),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 4.hClamp,
            horizontal: 2.wClamp,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 16.spClamp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ScoreMedium',
                  color: textColor,
                ),
              ),

              SizedBox(height: 5.hClamp),
              if (emotion != null)
                Image.asset(
                  'assets/emotions/$emotion.png',
                  width: 25.wClamp,
                  height: 25.hClamp,
                  errorBuilder: (context, error, stackTrace) {
                    return SizedBox.shrink();
                  },
                ),
              SizedBox(height: 5.hClamp),
              if (stat != null) ...[
                if (stat!.totalExpense != 0)
                  Text(
                    '-${stat!.totalExpense}',
                    style: TextStyle(
                      fontSize: 11.spClamp,
                      fontFamily: 'ScoreMedium',
                      color: Colors.red,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (stat!.totalIncome != 0)
                  Text(
                    '+${stat!.totalIncome}',
                    style: TextStyle(
                      fontSize: 11.spClamp,
                      fontFamily: 'ScoreMedium',
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
