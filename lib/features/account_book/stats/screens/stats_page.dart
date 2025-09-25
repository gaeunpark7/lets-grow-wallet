import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/provider/stat_provider.dart';
import 'package:lets_grow_wallet/features/account_book/stats/screens/stats_expense_view.dart';
import 'package:lets_grow_wallet/features/account_book/stats/screens/stats_income_view.dart';
import 'package:lets_grow_wallet/features/account_book/stats/widgets/montly_header.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: MonthHeader(onKindChanged: (_) {}, current: StatsKind.income),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSelectButton(context, 0, "수입"),
                const SizedBox(width: 12),
                _buildSelectButton(context, 1, "지출"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [StatsIncomeView(), StatsExpenseView()],
      ),
    );
  }

  _buildSelectButton(BuildContext context, int index, String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _tabController.index == index
            ? MainColors.mainLight
            : MainColors.main,
        foregroundColor: _tabController.index == index
            ? Colors.white
            : MainColors.mainDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        minimumSize: Size(MediaQuery.of(context).size.width * 0.4, 45),
        elevation: 0,
        shadowColor: Colors.transparent, // 그림자 제거
      ),
      onPressed: () {
        setState(() => _tabController.index = index);
      },
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}
