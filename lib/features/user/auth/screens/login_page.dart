import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _googleColor = Color.fromARGB(255, 247, 252, 255);
  static const _kakaoColor = Color.fromARGB(255, 243, 223, 47);

  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen(_handleAuthChange);
  }

  Future<void> _handleAuthChange(AuthState data) async {
    final event = data.event;
    final session = data.session;

    if (event == AuthChangeEvent.signedIn && session != null) {
      final user = session.user;

      try {
        //user 테이블에 존재하는지 확인
        final existingUser = await Supabase.instance.client
            .from('user')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (existingUser == null) {
          // 없으면 user 테이블에 등록
          await Supabase.instance.client.from('user').insert({
            'id': user.id,
            'email': user.email,
          });

          // 신규 사용자는 프로필 설정 페이지로
          if (mounted) {
            context.go(Routes.profileSetting);
          }
        }
        // 기존 사용자는 라우터의 redirect가 자동으로 홈으로 이동
      } catch (e) {
        print('로그인 오류: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("구글 로그인실패")));
        }
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.example.letsgrowwallet://login-callback',
      );
    } catch (e) {
      print('구글 로그인 시작 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("구글 로그인실패")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 100,
                color: Color.fromARGB(255, 84, 142, 152),
              ),
              const Text(
                "레츠고 가계부",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const Text("설명 설명 설명 설명"),
              const SizedBox(height: 30),
              LoginButton(
                color: _googleColor,
                text: "구글 계정으로 로그인",
                onPressed: _signInWithGoogle,
              ),
              const SizedBox(height: 10),
              LoginButton(
                color: _kakaoColor,
                text: "카카오톡 계정으로 로그인",
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final Color color;
  final String text;
  final VoidCallback onPressed;

  const LoginButton({
    super.key,
    required this.color,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
