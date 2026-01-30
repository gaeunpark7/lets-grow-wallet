import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/features/account_book/services/daily_quest_service.dart';
import 'package:lets_grow_wallet/features/main/widgets/custom_bottom_bar.dart';
import 'package:lets_grow_wallet/features/main/widgets/first_character_dialog.dart';
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

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return SafeArea(
      child: Scaffold(
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
