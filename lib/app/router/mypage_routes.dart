import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/features/user/my_page/screens/my_page.dart';
import 'package:lets_grow_wallet/features/user/my_page/screens/my_page_user_setting_page.dart';

GoRoute buildMypageRoutes() => GoRoute(
  path: Routes.mypage,
  builder: (_, __) => const MyPage(),
  routes: [
    GoRoute(
      path: Routes.myPageUserSetting,
      builder: (_, __) => const MyPageUserSettingPage(),
    ),
  ],
);
