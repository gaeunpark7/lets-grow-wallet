import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class QuestTitle extends StatelessWidget {
  String title;
  QuestTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.h,
      decoration: BoxDecoration(
        color: MainColors.main,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: MainColors.mainDark,
            fontSize: 20.spClampBetween(min: 16, max: 20),
          ),
        ),
      ),
    );
  }
}
