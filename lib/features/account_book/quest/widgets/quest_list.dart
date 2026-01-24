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
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '보상 획득',
                    style: TextStyle(
                      color: MainColors.mainDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: MainColors.mainDark, height: 0, thickness: 1),
                  const SizedBox(height: 12),
                  _buildDialogTile('EXP', '50 XP'),
                  Divider(
                    color: MainColors.mainDark,
                    thickness: 1 / MediaQuery.of(context).devicePixelRatio,
                    height: 0,
                  ),
                  const SizedBox(height: 8),
                  _buildDialogTile('Coin', '15'),
                  Divider(
                    color: MainColors.mainDark,
                    thickness: 1 / MediaQuery.of(context).devicePixelRatio,
                    height: 0,
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MainColors.mainLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

  Row _buildDialogTile(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 14, color: MainColors.mainDark)),
        Text(value, style: TextStyle(fontSize: 14, color: MainColors.mainDark)),
      ],
    );
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
