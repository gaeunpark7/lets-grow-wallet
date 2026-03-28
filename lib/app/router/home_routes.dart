import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/screens/add_expense_page.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/screens/add_income_page.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/screens/edit_expense_page.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/screens/edit_income_page.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/screens/home_page.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/screens/home_page_detail.dart';
import 'package:lets_grow_wallet/features/account_book/model/transaction_model.dart';

GoRoute buildHomeRoutes() => GoRoute(
  path: Routes.home,
  builder: (_, __) => HomePage(),
  routes: [
    // 거래 내역 추가/수정
    GoRoute(path: Routes.addExpense, builder: (_, __) => AddExpensePage()),
    GoRoute(path: Routes.addIncome, builder: (_, __) => AddIncomePage()),
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
    // 거래 상세
    GoRoute(
      path: Routes.detail,
      builder: (_, state) {
        final tx = state.extra as TransactionModel;
        return HomePageDetail(transaction: tx);
      },
    ),
  ],
);
