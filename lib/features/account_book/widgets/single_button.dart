//카드 , 현금 버튼
import 'package:flutter/material.dart';

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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.white,
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: borderRadius,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
