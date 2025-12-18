import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/auth_routes.dart';
import 'package:lets_grow_wallet/app/router/calendar_routes.dart';
import 'package:lets_grow_wallet/app/router/home_routes.dart';
import 'package:lets_grow_wallet/app/router/mypage_routes.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/app/router/stats_routes.dart';
import 'package:lets_grow_wallet/features/main/main_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final router = GoRouter(
  initialLocation: Routes.home,
  redirect: (context, state) {
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    final isLoginPage = state.matchedLocation == Routes.login;
    final isProfileSettingPage = state.matchedLocation == Routes.profileSetting;

    // 유저 최초 로그인 > 로그인 페이지
    if (!isLoggedIn && !isLoginPage && !isProfileSettingPage) {
      return Routes.login;
    }

    // 로그인 > 홈
    if (isLoggedIn && isLoginPage && !isProfileSettingPage) {
      return Routes.home;
    }
    return null;
  },
  routes: [
    ...buildAuthRoutes(),

    ShellRoute(
      builder: (_, __, child) => MainPage(child: child),
      routes: [
        buildHomeRoutes(),
        buildStatsRoutes(),
        buildCalendarRoutes(),
        buildMypageRoutes(),
      ],
    ),
  ],
);
