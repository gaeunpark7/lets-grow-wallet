import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class GoalsDialogConfirm extends StatelessWidget {
  // final VoidCallback onTap;

  const GoalsDialogConfirm({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30.h),
            Text(
              "목표는 월 1회 지정할수 있으며,\n수정이 불가능합니다. 저장하시겠습니까?",
              style: TextStyle(
                fontSize: 16.spClamp,
                color: MainColors.mainDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30.h),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: MainColors.mainDark,
                      backgroundColor: MainColors.main,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      "취소",
                      style: TextStyle(color: MainColors.mainDark),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: MainColors.mainLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text("확인"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
