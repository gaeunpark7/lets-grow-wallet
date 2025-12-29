import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/features/account_book/services/daily_quest_service.dart';
import 'package:lets_grow_wallet/features/main/widgets/custom_bottom_bar.dart';
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

          // 데일리 퀘스트 초기화 (인스턴스 메서드로 호출)
          await _initializeDailyQuests();
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
    const defaultCharacter =
        'https://aoufmcnnuigefetizxav.supabase.co/storage/v1/object/public/character-images/flower_dog1.png';

    if (existing.isEmpty) {
      // 캐릭터 지급
      await supabase.from('user_characters').insert({
        'user_id': userId,
        'character_id': defaultCharacterId,
        'experience': 0,
        // 'created_at': DateTime.now().toIso8601String(),
        'is_active': true,
      });
      // 캐릭터 다이얼로그
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Center(child: const Text("캐릭터 획득")),
              backgroundColor: Colors.white,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    defaultCharacter,
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  const Text("귀여운 알을 획득했어요!"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("확인"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
        floatingActionButton: SizedBox(
          width: 72,
          height: 72,
          child: FloatingActionButton(
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
      ),
    );
  }
}
