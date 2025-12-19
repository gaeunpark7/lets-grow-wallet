import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/features/account_book/character/screens/character_book_page.dart';
import 'package:lets_grow_wallet/features/account_book/character/screens/character_page.dart';
import 'package:lets_grow_wallet/features/account_book/quest/screens/quest_page.dart';
import 'package:lets_grow_wallet/features/account_book/shop/screens/item_shop_page.dart';

List<GoRoute> buildFeatureRoutes() => [
  GoRoute(
    path: Routes.character,
    builder: (_, __) => CharacterPage(),
    routes: [
      GoRoute(
        path: Routes.characterDetail,
        builder: (_, __) => CharacterBookPage(),
      ),
    ],
  ),
  GoRoute(path: Routes.quest, builder: (_, __) => QuestPage()),
  GoRoute(path: Routes.shop, builder: (_, __) => ItemShopPage()),
];
