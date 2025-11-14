import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class QuestList extends StatefulWidget {
  const QuestList({super.key, required this.index});
  final int index;

  @override
  State<QuestList> createState() => _QuestListState();
}

class _QuestListState extends State<QuestList> {
  double maxExp = 100;
  double currentExp = 70;
  int level = 3;

  @override
  Widget build(BuildContext context) {
    final progress = currentExp / maxExp;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 105,
        decoration: BoxDecoration(
          border: Border.all(color: MainColors.mainLight),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Column(
              children: [
                Text(
                  "퀘스트 ${widget.index + 1}",
                  style: TextStyle(fontSize: 18, color: MainColors.mainDark),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 14,
                    backgroundColor: MainColors.main,
                    valueColor: AlwaysStoppedAnimation(
                      progress > 0.0 ? MainColors.mainLight : MainColors.main,
                      // progress > 0.7
                      //     ? Colors.orangeAccent
                      //     : progress > 0.4
                      //     ? MainColors.mainLight
                      //     : Colors.lightBlueAccent,
                    ),
                  ),
                ),
                //달성률
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 4.0),
                      child: Text(
                        "달성률 ${(progress * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                          fontSize: 14,
                          color: MainColors.mainLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
