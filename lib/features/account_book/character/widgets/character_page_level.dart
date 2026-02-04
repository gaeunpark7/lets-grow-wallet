import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                level,
                style: TextStyle(
                  color: MainColors.mainDark,
                  fontSize: 24.spClampBetween(min: 20, max: 24),
                ),
              ),
              SizedBox(width: 8.wClamp),
              Column(
                children: [
                  Text(
                    characterName,
                    style: TextStyle(
                      color: MainColors.mainDark,
                      fontSize: 24.spClampBetween(min: 20, max: 24),
                    ),
                  ),
                  SizedBox(height: 4.hClamp),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.hClamp),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 16.hClamp,
              backgroundColor: MainColors.main,
              valueColor: const AlwaysStoppedAnimation(MainColors.mainLight),
            ),
          ),
          SizedBox(height: 8.hClamp),
          Text(
            '${currentExp.toInt()} / ${maxExp.toInt()} EXP',
            style: TextStyle(color: Colors.grey[600], fontSize: 12.spClamp),
          ),
        ],
      ),
    );
  }
}
