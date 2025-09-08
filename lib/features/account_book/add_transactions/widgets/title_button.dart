import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
