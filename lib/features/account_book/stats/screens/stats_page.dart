import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/provider/stat_provider.dart';
import 'package:lets_grow_wallet/features/account_book/stats/screens/stats_expense_view.dart';
import 'package:lets_grow_wallet/features/account_book/stats/screens/stats_income_view.dart';
import 'package:lets_grow_wallet/features/account_book/stats/widgets/montly_header.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: MonthHeader(onKindChanged: (_) {}, current: StatsKind.income),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          labelStyle: TextStyle(fontSize: 18),

          tabs: [
            Tab(text: "수입"),
            Tab(text: "지출"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [StatsIncomeView(), StatsExpenseView()],
      ),
    );
  }
}
