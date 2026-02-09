import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/friendly_error_message.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkProfile();
    });
  }

  //프로필 확인
  Future<void> _checkProfile() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      // 세션 오류났을때 로그인 페이지로 이동
      context.go(Routes.login);
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final profile = await supabase
          .from('user')
          .select('nickname')
          .eq('id', user.id)
          .maybeSingle();

      final nickname = profile?['nickname']?.toString() ?? '';

      if (!mounted) return;

      if (nickname.isEmpty) {
        context.go(Routes.profileSetting);
        return;
      } else {
        context.go(Routes.home);
        return;
      }
    } catch (e) {
      final error = FriendlyErrorMessage.resolve(e);
      print('로그인 오류: $e');
      if (mounted) {
        showAppSnackBar(error.message);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: MainColors.mainLight,
        body: Padding(
          padding: EdgeInsets.all(12.wClamp),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              SizedBox(height: 20.hClamp),
              Image.asset(
                'assets/icons/app_icon2.png',
                width: 120.wClamp,
                height: 120.hClamp,
              ),
              SizedBox(height: 8.hClamp),
              Text(
                "레츠고 가계부",
                style: TextStyle(
                  fontSize: 26.spClamp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24.hClamp),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 80.wClamp),
                child: Visibility(
                  visible: _isLoading,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: LinearProgressIndicator(
                    minHeight: 10.hClamp,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Spacer(),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
