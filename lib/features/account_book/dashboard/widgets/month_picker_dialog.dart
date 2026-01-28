import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/kst_time.dart';

Future<DateTime?> showMonthPickerDialog({
  required BuildContext context,
  required DateTime initialMonth,
  int firstYear = 2026,
}) {
  final now = nowKst();
  final currentYear = now.year;

  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      int tempYear = initialMonth.year;
      int tempMonth = initialMonth.month;

      return StatefulBuilder(
        builder: (context, setLocalState) {
          final canPrevYear = tempYear > firstYear;
          final canNextYear = tempYear < currentYear;

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white,
            content: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: canPrevYear
                            ? () => setLocalState(() => tempYear--)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                        color: MainColors.mainDark,
                        disabledColor: MainColors.point,
                      ),
                      Text(
                        '$tempYear년',
                        style: TextStyle(
                          color: MainColors.mainDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: canNextYear
                            ? () => setLocalState(() => tempYear++)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                        color: MainColors.mainDark,
                        disabledColor: MainColors.point,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 2.2,
                        ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final m = index + 1;
                      final isSelected = m == tempMonth;
                      final isDisabled =
                          tempYear == currentYear && m > now.month;

                      return InkWell(
                        onTap: isDisabled
                            ? null
                            : () => setLocalState(() => tempMonth = m),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MainColors.mainLight
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? MainColors.mainDark
                                  : MainColors.point,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$m월',
                            style: TextStyle(
                              color: isDisabled
                                  ? MainColors.point
                                  : MainColors.mainDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      context,
                      () => Navigator.pop(context),
                      MainColors.main,
                      MainColors.mainDark,
                      '취소',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildButton(
                      context,
                      () => Navigator.pop(
                        context,
                        DateTime(tempYear, tempMonth, 1),
                      ),
                      MainColors.mainLight,
                      Colors.white,
                      '선택',
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}

_buildButton(
  BuildContext context,
  VoidCallback onPressed,
  Color backColor,
  Color textColor,
  String text,
) {
  return SizedBox(
    height: 40,
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: backColor,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text),
    ),
  );
}
