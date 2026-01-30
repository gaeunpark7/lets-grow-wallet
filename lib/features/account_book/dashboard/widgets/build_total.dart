import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class BuildTotal extends StatelessWidget {
  final String? text;
  final int topBorder;
  final int rightBorder;
  final Color textColor;
  const BuildTotal({
    super.key,
    this.text,
    this.topBorder = 0,
    this.rightBorder = 0,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: topBorder == 0
              ? BorderSide.none
              : BorderSide(color: MainColors.point, width: 1),
          bottom: BorderSide(color: MainColors.point, width: 1),
          left: BorderSide.none,
          right: rightBorder == 0
              ? BorderSide.none
              : BorderSide(color: MainColors.point, width: 1),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text ?? "",
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 14, color: textColor),
      ),
    );
  }
}
