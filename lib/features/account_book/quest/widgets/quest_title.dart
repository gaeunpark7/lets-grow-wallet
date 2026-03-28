import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class QuestTitle extends StatelessWidget {
  final String title;
  const QuestTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.hClamp,
      decoration: BoxDecoration(
        color: MainColors.main,
        borderRadius: BorderRadius.circular(12.rClamp),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: MainColors.mainDark,
            fontFamily: 'ScoreMedium',
            fontSize: 20.spClampBetween(min: 16, max: 20),
          ),
        ),
      ),
    );
  }
}
