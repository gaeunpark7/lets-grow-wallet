import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class QuestStar extends StatelessWidget {
  static const double iconSize = 65;
  final int claimedCount;

  const QuestStar({super.key, required this.claimedCount});

  Widget _filledStar() {
    return const Icon(Icons.star, color: MainColors.mainLight, size: iconSize);
  }

  Widget _hollowStar() {
    return const Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.star, color: MainColors.mainLight, size: iconSize),
        Icon(Icons.star, color: Colors.white, size: iconSize * 0.85),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filled = claimedCount.clamp(0, 3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        filled >= 1 ? _filledStar() : _hollowStar(),
        SizedBox(width: iconSize * 0.1),
        filled >= 2 ? _filledStar() : _hollowStar(),
        SizedBox(width: iconSize * 0.1),
        filled >= 3 ? _filledStar() : _hollowStar(),
      ],
    );
  }
}
