import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/features/account_book/model/daily_quest_model.dart';
import 'package:lets_grow_wallet/features/account_book/quest/widgets/quest_list.dart';
import 'package:lets_grow_wallet/features/account_book/quest/widgets/quest_star.dart';
import 'package:lets_grow_wallet/features/account_book/quest/widgets/quest_title.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/user_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/services/admob_service.dart';
import 'package:lets_grow_wallet/features/account_book/services/daily_quest_service.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_appbar.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class QuestPage extends ConsumerStatefulWidget {
  const QuestPage({super.key});

  @override
  ConsumerState<QuestPage> createState() => _QuestPageState();
}

class _QuestPageState extends ConsumerState<QuestPage> {
  BannerAd? _bannerAd;
  ProviderSubscription<bool>? _premiumSubscription;
  final DailyQuestService _questService = DailyQuestService();
  List<DailyQuest> _todayQuests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _premiumSubscription = ref.listenManual<bool>(isPremiumProvider, (
      prev,
      next,
    ) {
      if (!mounted) return;

      if (next) {
        setState(() {
          _bannerAd?.dispose();
          _bannerAd = null;
        });
        return;
      }

      if (_bannerAd == null) {
        setState(_createBannerAd);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _questService.createTodayQuestsIfNeeded();
      } catch (e) {
        print('오늘의 미션 생성 실패: $e');
        showAppSnackBar('오늘의 미션 생성에 실패했습니다.');
      }
      await _loadQuests();
      // await _loadMonthlyGoals();

      if (!ref.read(isPremiumProvider)) {
        _createBannerAd();
        if (mounted) setState(() {});
      }
    });
  }

  void _createBannerAd() {
    final adUnitId = AdmobService.BannerAdUnitId;
    if (adUnitId == null) return;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: AdmobService.bannerAdListener,
    )..load();
  }

  @override
  void dispose() {
    _premiumSubscription?.close();
    _bannerAd?.dispose();
    super.dispose();
  }

  //월별 목표 로드
  // Future<void> _loadMonthlyGoals() async {
  //   setState(() => _loadingMonthly = true);
  //   try {
  //     final user = Supabase.instance.client.auth.currentUser;
  //     if (user == null) {
  //       _monthlyGoals = [];
  //     } else {
  //       final now = nowKst();
  //       final month =
  //           "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}";
  //       final list = await _goalService.getGoalsForUserMonth(user.id, month);
  //       setState(() => _monthlyGoals = list);
  //     }
  //   } catch (e) {
  //     print('월별 목표 로드 실패: $e');
  //     showAppSnackBar('월별 목표를 불러오는 중 오류가 발생했습니다.');
  //     _monthlyGoals = [];
  //   } finally {
  //     setState(() => _loadingMonthly = false);
  //   }
  // }

  // 월별 목표 제목 포맷팅
  // String _formatGoalTitle(GoalModel g) {
  //   final amount = g.targetAmount ?? 0;
  //   if (g.goalType.toLowerCase() == 'income') {
  //     return '$amount원 모으기';
  //   } else if (g.goalType.toLowerCase() == 'expense') {
  //     return '$amount원 소비하기';
  //   }
  //   return g.title;
  // }

  // 일별 목표 로드
  Future<void> _loadQuests() async {
    setState(() => _loading = true);
    try {
      final list = await _questService.getTodayQuests();
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
            );
      }).toList();
      setState(() {
        _todayQuests = padded;
      });
    } catch (e) {
      _todayQuests = [];
      print('오늘의 미션 로드 실패: $e');
      showAppSnackBar('오늘의 미션을 불러오는 중 오류가 발생했습니다.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildDailyQuests() {
    if (_loading)
      return const Center(
        child: CircularProgressIndicator(color: MainColors.mainLight),
      );
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _todayQuests.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.hClamp),
      itemBuilder: (context, index) {
        return QuestList(
          quest: _todayQuests[index],
          index: index,
          onRewardClaimed: _loadQuests,
        );
      },
    );
  }

  // ignore: unused_element
  // Widget _buildMonthlyGoals(double maxWidth) {
  //   if (_loadingMonthly)
  //     return const Center(child: CircularProgressIndicator());
  //   if (_monthlyGoals.isEmpty) {
  //     return Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Container(
  //           width: double.infinity,
  //           padding: const EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //             border: Border.all(color: MainColors.mainLight),
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Center(
  //             child: Text(
  //               "월별 목표가 없습니다. \n목표를 설정해보세요!",
  //               style: TextStyle(fontSize: 16, color: MainColors.mainDark),
  //             ),
  //           ),
  //         ),
  //       ],
  //     );
  //   }
  //   return Column(
  //     children: _monthlyGoals.map((g) {
  //       return MonthlyGoals(goalTitle: _formatGoalTitle(g), subtitle: g.title);
  //     }).toList(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: MainColors.mainDark),
          title: const ShopAppbar(),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: 0,
              left: 12.wClamp,
              right: 12.wClamp,
              bottom: 12.hClamp,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.wClamp,
                    vertical: 18.hClamp,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: MainColors.mainLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      QuestTitle(title: "일일 미션"),
                      SizedBox(height: 6.hClamp),
                      QuestStar(
                        claimedCount: _todayQuests
                            .where((q) => q.isCompleted && q.rewardGiven)
                            .length,
                      ),
                      SizedBox(height: 12.hClamp),
                      _buildDailyQuests(),

                      // const SizedBox(height: 12),
                      // QuestTitle(title: "월별 미션"),
                      // const SizedBox(height: 12),
                      // _buildMonthlyGoals(MediaQuery.of(context).size.width),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SizedBox(
          height: 80.hClamp,
          width: _bannerAd?.size.width.toDouble() ?? 0,
          child: _bannerAd != null
              ? AdWidget(ad: _bannerAd!)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
