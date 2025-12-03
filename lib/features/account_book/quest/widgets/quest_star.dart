import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class QuestStar extends StatelessWidget {
  static const double iconSize = 50;
  const QuestStar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.star, color: MainColors.mainLight, size: iconSize),
        SizedBox(width: iconSize * 0.1),
        Icon(Icons.star, color: MainColors.mainLight, size: iconSize),
        SizedBox(width: iconSize * 0.1),
        Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.star, color: MainColors.mainLight, size: iconSize),
            Icon(Icons.star, color: Colors.white, size: iconSize * 0.85),
          ],
        ),
      ],
    );
  }
}
