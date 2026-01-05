import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CharacterPageLevel extends StatelessWidget {
  final String level;
  final String characterName;
  final double progress;
  final double currentExp;
  final double maxExp;
  const CharacterPageLevel({
    super.key,
    required this.level,
    required this.characterName,
    required this.progress,
    required this.currentExp,
    required this.maxExp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              level,
              style: TextStyle(color: MainColors.mainDark, fontSize: 24),
            ),
            SizedBox(width: 8),
            Column(
              children: [
                Text(
                  characterName,
                  style: TextStyle(color: MainColors.mainDark, fontSize: 24),
                ),
                SizedBox(height: 4),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 16,
            backgroundColor: MainColors.main,
            valueColor: const AlwaysStoppedAnimation(MainColors.mainLight),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${currentExp.toInt()} / ${maxExp.toInt()} EXP',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}
