import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/model/daily_quest_model.dart';
import 'package:lets_grow_wallet/features/account_book/model/goal_model.dart';
import 'package:lets_grow_wallet/features/account_book/quest/widgets/monthly_goals.dart';
import 'package:lets_grow_wallet/features/account_book/quest/widgets/quest_list.dart';
import 'package:lets_grow_wallet/features/account_book/quest/widgets/quest_star.dart';
import 'package:lets_grow_wallet/features/account_book/quest/widgets/quest_title.dart';
import 'package:lets_grow_wallet/features/account_book/services/daily_quest_service.dart';
import 'package:lets_grow_wallet/features/account_book/services/goal_service.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_appbar.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuestPage extends StatefulWidget {
  const QuestPage({super.key});

  @override
  State<QuestPage> createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  final GoalService _goalService = GoalService(Supabase.instance.client);
  List<GoalModel> _monthlyGoals = [];
  bool _loadingMonthly = true;

  final DailyQuestService _questService = DailyQuestService();
  List<DailyQuest> _todayQuests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _questService.createTodayQuestsIfNeeded();
      } catch (e) {
        print('오늘의 미션 생성 실패: $e');
      }
      await _loadQuests();
      await _loadMonthlyGoals();
    });
  }

  //월별 목표 로드
  Future<void> _loadMonthlyGoals() async {
    setState(() => _loadingMonthly = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _monthlyGoals = [];
      } else {
        final now = DateTime.now();
        final month =
            "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}";
        final list = await _goalService.getGoalsForUserMonth(user.id, month);
        setState(() => _monthlyGoals = list);
      }
    } catch (e) {
      print('월별 목표 로드 실패: $e');
      _monthlyGoals = [];
    } finally {
      setState(() => _loadingMonthly = false);
    }
  }

  // 월별 목표 제목 포맷팅
  String _formatGoalTitle(GoalModel g) {
    final amount = g.targetAmount ?? 0;
    if (g.goalType.toLowerCase() == 'income') {
      return '$amount원 모으기';
    } else if (g.goalType.toLowerCase() == 'expense') {
      return '$amount원 소비하기';
    }
    return g.title;
  }

  // 일별 목표 로드
  Future<void> _loadQuests() async {
    setState(() => _loading = true);
    try {
      final list = await _questService.getTodayQuests();
      // 항상 3개 표시
      final order = [
        'register_transaction',
        'character_interaction',
        'register_emotion',
      ];
      final Map<String, DailyQuest> map = {for (var q in list) q.questType: q};
      final padded = order.map((t) {
        return map[t] ??
            DailyQuest(
              id: '',
              questType: t,
              isCompleted: false,
              rewardGiven: false,
              createdAt: DateTime.now(),
            );
      }).toList();
      setState(() {
        _todayQuests = padded;
      });
    } catch (e) {
      _todayQuests = [];
      print('오늘의 미션 로드 실패: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildDailyQuests() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _todayQuests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return QuestList(
          quest: _todayQuests[index],
          index: index,
          onRewardClaimed: _loadQuests,
        );
      },
    );
  }

  Widget _buildMonthlyGoals(double maxWidth) {
    if (_loadingMonthly)
      return const Center(child: CircularProgressIndicator());
    if (_monthlyGoals.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: MainColors.mainLight),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                "월별 목표가 없습니다. \n목표를 설정해보세요!",
                style: TextStyle(fontSize: 16, color: MainColors.mainDark),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      children: _monthlyGoals.map((g) {
        return MonthlyGoals(goalTitle: _formatGoalTitle(g), subtitle: g.title);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const ShopAppbar(),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 0,
                  left: 12,
                  right: 12,
                  bottom: 12,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: MainColors.mainLight),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 36,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        QuestTitle(title: "일일 미션"),
                        const SizedBox(height: 6),
                        QuestStar(
                          claimedCount: _todayQuests
                              .where((q) => q.isCompleted && q.rewardGiven)
                              .length,
                        ),
                        const SizedBox(height: 12),
                        _buildDailyQuests(),
                        const SizedBox(height: 12),
                        QuestTitle(title: "월별 미션"),
                        const SizedBox(height: 12),
                        _buildMonthlyGoals(maxWidth),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
