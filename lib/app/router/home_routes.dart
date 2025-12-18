import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/screens/add_expense_page.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/screens/add_income_page.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/screens/edit_expense_page.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/screens/edit_income_page.dart';
import 'package:lets_grow_wallet/features/account_book/character/screens/character_book_page.dart';
import 'package:lets_grow_wallet/features/account_book/character/screens/character_page.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/screens/home_page.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/screens/home_page_detail.dart';
import 'package:lets_grow_wallet/features/account_book/model/transaction_model.dart';
import 'package:lets_grow_wallet/features/account_book/quest/screens/quest_page.dart';
import 'package:lets_grow_wallet/features/account_book/shop/screens/item_shop_page.dart';

GoRoute buildHomeRoutes() => GoRoute(
  path: Routes.home,
  builder: (_, __) => HomePage(),
  routes: [
    //소비/수입 추가
    GoRoute(path: Routes.addExpense, builder: (_, __) => AddExpensePage()),
    GoRoute(path: Routes.addIncome, builder: (_, __) => AddIncomePage()),

    //소비/수입 수정
    GoRoute(
      path: Routes.editExpense,
      builder: (_, state) {
        final tx = state.extra as TransactionModel;
        return EditExpensePage(transaction: tx);
      },
    ),
    GoRoute(
      path: Routes.editIncome,
      builder: (_, state) {
        final tx = state.extra as TransactionModel;
        return EditIncomePage(transaction: tx);
      },
    ),
    //캐릭터 페이지
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
    //퀘스트
    GoRoute(path: Routes.quest, builder: (_, __) => QuestPage()),

    //상점
    GoRoute(path: Routes.shop, builder: (_, __) => ItemShopPage()),
  ],
);
