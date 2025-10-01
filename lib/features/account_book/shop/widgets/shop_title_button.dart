import 'package:flutter/material.dart';

class ShopTitleButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color backColor;
  final VoidCallback? onPressed;

  const ShopTitleButton({
    super.key,
    this.textColor = Colors.white,
    required this.backColor,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: backColor,
            borderRadius: BorderRadius.circular(5),
          ),
          height: 50,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
