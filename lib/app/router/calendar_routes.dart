import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/features/account_book/calendar/screens/calendar.dart';

GoRoute buildCalendarRoutes() =>
    GoRoute(path: Routes.calendar, builder: (_, __) => Calendar());
