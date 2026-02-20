import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String redrectUrl = 'com.example.letsgrowwallet://login-callback';

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && mounted) {
        context.go(Routes.loginCallback);
      }
    });
  }

  //구글 로그인
  Future<void> _signInWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redrectUrl,
      );
    } catch (e) {
      print('구글 로그인 시작 오류: $e');
      if (mounted) {
        showAppSnackBar('구글 로그인에 실패하였습니다.\n다시 시도해주세요.');
        print("구글 로그인 실패: $e");
      }
    }
  }

  //카카오 로그인
  Future<void> _signInWithKakao() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.kakao,
        redirectTo: redrectUrl,
      );
    } catch (e) {
      if (mounted) {
        showAppSnackBar('카카오 로그인에 실패하였습니다.\n다시 시도해주세요.');
        print("카카오 로그인 실패: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(18.wClamp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/app_icon2.png',
                  color: MainColors.mainLight,
                  width: 120.wClamp,
                  height: 130.hClamp,
                ),

                SizedBox(height: 10.hClamp),
                Text(
                  "레츠고 가계부",
                  style: TextStyle(
                    color: MainColors.mainDark,
                    fontSize: 30.spClamp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ScoreBold',
                  ),
                ),
                SizedBox(height: 30.hClamp),
                LoginButton(
                  backcolor: Color(0xFF7da8ff),
                  text: "구글 계정으로 로그인",
                  onPressed: _signInWithGoogle,
                ),
                SizedBox(height: 10.hClamp),
                LoginButton(
                  backcolor: Color(0xFFf6e762),
                  text: "카카오톡 계정으로 로그인",
                  onPressed: _signInWithKakao,
                ),
                SizedBox(height: 5.hClamp),
                GestureDetector(
                  onTap: () {
                    context.push(Routes.privacyPolicy);
                  },
                  child: Text(
                    "개인정보 처리방침",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.spClamp,

                      fontFamily: 'ScoreMedium',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final Color backcolor;
  final String text;
  final VoidCallback onPressed;

  const LoginButton({
    super.key,
    required this.backcolor,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55.hClamp,
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backcolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.rClamp),
          ),
          shadowColor: Colors.transparent,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.spClamp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'ScoreMedium',
          ),
        ),
      ),
    );
  }
}
