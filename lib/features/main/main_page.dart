import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/features/account_book/services/daily_quest_service.dart';
import 'package:lets_grow_wallet/features/main/widgets/custom_bottom_bar.dart';
import 'package:lets_grow_wallet/features/main/widgets/first_character_dialog.dart';
import 'package:lets_grow_wallet/features/main/widgets/monthly_all_clear_dialog.dart';
import 'package:lets_grow_wallet/features/main/widgets/monthly_clear_dialog.dart';
import 'package:lets_grow_wallet/features/main/widgets/monthly_fail_dialog.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainPage extends StatefulWidget {
  final Widget child;
  const MainPage({super.key, required this.child});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          // 기본 캐릭터 지급
          await checkAndGiveDefaultCharacter(user.id);
          // 일일 퀘스트 초기화
          await _initializeDailyQuests();
          // 월간 목표 보상 확인 다이얼로그
          await _checkMonthlyGoalRewards(user.id);
        } catch (e, st) {
          print('MainPage init error: $e\n$st');
        }
      });
    }
  }

  Future<void> _initializeDailyQuests() async {
    try {
      final service = DailyQuestService();
      print('MainPage: initializing daily quests...');
      await service.createTodayQuestsIfNeeded();
      print('MainPage: daily quests initialized');
    } catch (e, st) {
      print('MainPage: failed to initialize daily quests: $e\n$st');
    }
  }

  Future<void> checkAndGiveDefaultCharacter(String userId) async {
    final supabase = Supabase.instance.client;

    // 유저 캐릭터 여부 확인
    final existing = await supabase
        .from('user_characters')
        .select()
        .eq('user_id', userId);

    // 기본 캐릭터 정보
    const defaultCharacterId = '589c96d4-64cc-419c-8125-1e27dfb0d44b';

    if (existing.isEmpty) {
      // 캐릭터 지급
      await supabase.from('user_characters').insert({
        'user_id': userId,
        'character_id': defaultCharacterId,
        'experience': 0,
        'stage': 'egg',
        'is_active': true,
        //character_images테이블의 is_default가 true인 이미지로 설정
      });
      // 캐릭터 다이얼로그
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return FirstCharacterDialog();
          },
        );
      }
    }
  }

  Future<void> _checkMonthlyGoalRewards(String userId) async {
    final supabase = Supabase.instance.client;

    try {
      final List<dynamic> pendingLogs = await supabase
          .from('reward_logs')
          .select('''
      *,
      goals:goals!inner(title, target_amount)
    ''')
          .eq('user_id', userId)
          .eq('is_notified', false)
          .order('month');

      if (pendingLogs.isEmpty) return;

      final successLogs = pendingLogs
          .where((log) => log['is_success'] == true)
          .toList();

      if (!mounted) return;

      // 1. 같은 달내에 성공 2개 > 올 클리어 다이얼로그
      if (successLogs.length >= 2) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => MonthlyAllClearDialog(logs: successLogs),
        );
        print(pendingLogs);
      }
      // 2. 개별 다이얼로그
      else {
        for (var log in pendingLogs) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => log['is_success'] == true
                ? MonthlyClearDialog(log: log)
                : MonthlyFailDialog(log: log),
          );
        }
      }

      // 완료 처리
      final List<String> logIds = pendingLogs
          .map((log) => log['id'].toString())
          .toList();

      await supabase
          .from('reward_logs')
          .update({'is_notified': true})
          .inFilter('id', logIds);
    } catch (e) {
      debugPrint('Reward Check Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: widget.child,
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _selectedIndex,
        onTabSelected: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              context.go(Routes.home);
              break;
            case 1:
              context.go(Routes.statistics);
              break;
            case 2:
              context.go(Routes.calendar);
              break;
            case 3:
              context.go(Routes.mypage);
              break;
          }
        },
      ),
      floatingActionButton: isKeyboardOpen
          ? null
          : SizedBox(
              width: 72,
              height: 72,
              child: FloatingActionButton(
                heroTag: 'main-add-fab',
                backgroundColor: Colors.white,
                foregroundColor: MainColors.mainLight,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: BorderSide(color: MainColors.mainLight, width: 3),
                ),
                onPressed: () =>
                    context.push('${Routes.home}/${Routes.addExpense}'),
                child: const Icon(Icons.add, size: 70),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
