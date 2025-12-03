import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/model/daily_quest_model.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class QuestList extends StatefulWidget {
  const QuestList({super.key, required this.index, required this.quest});
  final DailyQuest quest;
  final int index;

  @override
  State<QuestList> createState() => _QuestListState();
}

class _QuestListState extends State<QuestList> {
  @override
  Widget build(BuildContext context) {
    final bool completed = widget.quest.isCompleted;
    final double progress = completed ? 1.0 : 0.0;

    String subtitle;
    switch (widget.quest.questType) {
      case 'register_transaction':
        subtitle = '소비 또는 지출 추가하기';
        break;
      case 'register_emotion':
        subtitle = '오늘의 감정 등록하기';
        break;
      case 'character_interaction':
        subtitle = '캐릭터와 상호작용하기';
        break;
      default:
        subtitle = '미션을 완료하세요';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: MainColors.mainLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            subtitle,
            style: TextStyle(fontSize: 18, color: MainColors.mainDark),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: MainColors.main,
              valueColor: AlwaysStoppedAnimation(
                progress > 0.0 ? MainColors.mainLight : MainColors.main,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "달성률 ${(progress * 100).toStringAsFixed(0)}%",
                style: TextStyle(fontSize: 14, color: MainColors.mainLight),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
