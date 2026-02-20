import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

//지출/수입 타이틀 버튼
class TitleButton extends StatelessWidget {
  final Color color;
  final Border? border;
  final String text;
  final Color textColor;
  const TitleButton({
    required this.color,
    this.border,
    required this.text,
    this.textColor = Colors.white,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, border: border),
      padding: EdgeInsets.symmetric(vertical: 12.hClamp),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            fontFamily: 'ScoreMedium',
          ),
        ),
      ),
    );
  }
}
