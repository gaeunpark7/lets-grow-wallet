//카드 , 현금 버튼
import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class SingleButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final BorderRadius? borderRadius;

  const SingleButton({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: selected ? MainColors.mainLight : MainColors.main,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(5),
            side: BorderSide(
              color: selected ? MainColors.mainLight : MainColors.main,
              width: 1,
            ),
          ),
        ),
        onPressed: () {
          onTap();
        },
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : MainColors.mainDark,
            fontWeight: FontWeight.bold,
            fontFamily: 'ScoreMedium',
          ),
        ),
      ),
    );
  }
}
