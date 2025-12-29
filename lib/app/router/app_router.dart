import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/auth_routes.dart';
import 'package:lets_grow_wallet/app/router/calendar_routes.dart';
import 'package:lets_grow_wallet/app/router/feature_routes.dart';
import 'package:lets_grow_wallet/app/router/home_routes.dart';
import 'package:lets_grow_wallet/app/router/mypage_routes.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/app/router/stats_routes.dart';
import 'package:lets_grow_wallet/features/main/main_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final router = GoRouter(
  initialLocation: Routes.login,
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;

    final isLogin = state.matchedLocation == Routes.login;
    final isLoginCallback = state.matchedLocation == Routes.loginCallback;
    // final isProfileSettingPage = state.matchedLocation == Routes.profileSetting;

    // 로그인 안됨 > 로그인 페이지
    if (!isLoggedIn && !isLogin) {
      return Routes.login;
    }

    // 로그인 + 로그인 페이지 > 콜백페이지
    if (isLoggedIn && isLogin) {
      return Routes.loginCallback;
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

    ...buildFeatureRoutes(),
  ],
);
