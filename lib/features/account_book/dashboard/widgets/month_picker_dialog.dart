import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/kst_time.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

Future<DateTime?> showMonthPickerDialog({
  required BuildContext context,
  required DateTime initialMonth,
  int firstYear = 2025,
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

          return Dialog(
            // insetPadding: EdgeInsets.symmetric(
            //   horizontal: 20.wClamp,
            //   vertical: 20.hClamp,
            // ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.rClamp),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.wClamp,
                  right: 16.wClamp,
                  bottom: 16.h,
                  top: 8.hClamp,
                ),
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
                          icon: Icon(Icons.chevron_left),
                          color: MainColors.mainDark,
                          disabledColor: MainColors.point,
                        ),
                        Text(
                          '$tempYear년',
                          style: TextStyle(
                            color: MainColors.mainDark,
                            fontSize: 16.spClamp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: canNextYear
                              ? () => setLocalState(() => tempYear++)
                              : null,
                          icon: Icon(Icons.chevron_right),
                          color: MainColors.mainDark,
                          disabledColor: MainColors.point,
                        ),
                      ],
                    ),
                    // SizedBox(height: 6.hClamp),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 6.hClamp,
                        crossAxisSpacing: 6.wClamp,
                        childAspectRatio: 2.5,
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
                          borderRadius: BorderRadius.circular(10.rClamp),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? MainColors.mainLight
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10.rClamp),
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
                                fontSize: 14.spClamp,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.hClamp),
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
                        SizedBox(width: 8.wClamp),
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
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildButton(
  BuildContext context,
  VoidCallback onPressed,
  Color backColor,
  Color textColor,
  String text,
) {
  return SizedBox(
    height: 42.hClamp,
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: backColor,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.rClamp),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 16.spClamp, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
