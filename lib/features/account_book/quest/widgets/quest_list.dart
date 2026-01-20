import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/features/account_book/model/daily_quest_model.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/quest_reward_controller.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class QuestList extends ConsumerStatefulWidget {
  const QuestList({
    super.key,
    required this.index,
    required this.quest,
    this.onRewardClaimed,
  });
  final DailyQuest quest;
  final int index;
  final VoidCallback? onRewardClaimed;

  @override
  ConsumerState<QuestList> createState() => _QuestListState();
}

class _QuestListState extends ConsumerState<QuestList> {
  bool _claimingReward = false;

  Future<void> _claimReward() async {
    if (_claimingReward) return;
    setState(() {
      _claimingReward = true;
    });

    try {
      await ref
          .read(questRewardControllerProvider)
          .claimDailyQuestReward(questId: widget.quest.id);

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('보상 획득'),
            content: const Text('15xp, 15coin 획득!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          );
        },
      );

      widget.onRewardClaimed?.call();
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar('보상 수령 실패: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _claimingReward = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool completed = widget.quest.isCompleted;
    final double progress = completed ? 1.0 : 0.0; //진행률: 1(완료), 0(미완료)
    //퀘스트 완료, 보상 미지급, 유효한 id일 때 보상 수령
    final bool canClaimReward =
        completed && !widget.quest.rewardGiven && widget.quest.id.isNotEmpty;
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
        crossAxisAlignment: CrossAxisAlignment.center,
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
            mainAxisAlignment: canClaimReward
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.end,
            children: [
              Text(
                "달성률 ${(progress * 100).toStringAsFixed(0)}%",
                style: TextStyle(fontSize: 14, color: MainColors.mainLight),
              ),
              if (canClaimReward) ...[
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _claimingReward ? null : _claimReward,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MainColors.mainLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: _claimingReward
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('보상 받기'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
