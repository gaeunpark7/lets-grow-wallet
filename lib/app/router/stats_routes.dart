import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/features/account_book/stats/screens/stats_page.dart';

GoRoute buildStatsRoutes() =>
    GoRoute(path: Routes.statistics, builder: (_, __) => StatsPage());
