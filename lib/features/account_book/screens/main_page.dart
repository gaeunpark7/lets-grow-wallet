import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/screens/add_expense_page.dart';
import 'package:lets_grow_wallet/features/auth/screens/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // 비동기 함수는 이렇게 따로 실행
      WidgetsBinding.instance.addPostFrameCallback((_) {
        checkAndGiveDefaultCharacter(user.id);
      });
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
    const defaultCharacterId = '2bbfdb93-383f-467a-a1d9-3b05f46db9a4';
    const defaultCharacter =
        'https://aoufmcnnuigefetizxav.supabase.co/storage/v1/object/public/character-images//gomi2.jpeg';

    if (existing.isEmpty) {
      // 캐릭터 지급
      await supabase.from('user_characters').insert({
        'user_id': userId,
        'character_id': defaultCharacterId,
        'experience': 0,
        // 'created_at': DateTime.now().toIso8601String(),
        'is_active': true,
      });

      // 3. 캐릭터 다이얼로그
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
                  ), // 예시 이미지
                  const SizedBox(height: 16),
                  const Text("말랑말랑한 아기곰 담곰이를 얻었어요!"),
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
        backgroundColor: Colors.white,
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Supabase.instance.client.auth
                    .signOut()
                    .then((_) {
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (ctx) => LoginPage()),
                        );
                      }
                    })
                    .catchError((error) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("로그아웃 실패: $error")),
                        );
                      }
                    });
              },
              child: Text("로그아웃"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => AddExpensePage()),
                );
              },
              child: Text("추가"),
            ),
          ],
        ),
      ),
    );
  }
}
