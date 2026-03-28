import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/features/user/auth/auth_gate_page.dart';
import 'package:lets_grow_wallet/features/user/auth/screens/login_page.dart';
import 'package:lets_grow_wallet/features/user/auth/screens/privacy_policy_page.dart';
import 'package:lets_grow_wallet/features/user/auth/screens/profile_setting_page.dart';

List<GoRoute> buildAuthRoutes() {
  return [
    GoRoute(path: Routes.login, builder: (_, __) => const LoginPage()),
    GoRoute(
      path: Routes.loginCallback,
      builder: (_, __) => const AuthGatePage(),
    ),
    GoRoute(
      path: Routes.profileSetting,
      builder: (_, __) => ProfileSettingPage(),
    ),
    GoRoute(path: Routes.privacyPolicy, builder: (_, __) => PrivacyPolicy()),
  ];
}
