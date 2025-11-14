import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class QuestTitle extends StatelessWidget {
  String title;
  QuestTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: MainColors.main,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(color: MainColors.mainDark, fontSize: 20),
        ),
      ),
    );
  }
}
