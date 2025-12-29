import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      // 세션 오류났을때 로그인 페이지로 이동
      context.go(Routes.login);
      return;
    }
    try {
      final profile = await supabase
          .from('user')
          .select('nickname')
          .eq('id', user.id)
          .maybeSingle();

      final nickname = profile?['nickname']?.toString() ?? '';

      if (!mounted) return;

      if (nickname.isEmpty) {
        context.go(Routes.profileSetting);
      } else {
        context.go(Routes.home);
      }
    } catch (e) {
      print('로그인 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("로그인 실패: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
