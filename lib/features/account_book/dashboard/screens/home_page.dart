import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/month_selection_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/transaction_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/build_total.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/floating_menu_button.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/monthly_header.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/stat_future_builder.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/table_header.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/table_list.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/month_picker_dialog.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/user_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/services/stat_service.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';
import '../../model/monthly_stat_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _homePageState();
}

class _homePageState extends ConsumerState<HomePage> {
  final statService = StatService();
  late Future<MonthlyStat?> _statFuture;

  late DateTime start;
  late DateTime end;

  @override
  void initState() {
    super.initState();
    final selectedMonth = ref.read(selectedMonthProvider);
    start = DateTime(selectedMonth.year, selectedMonth.month, 1);
    end = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);

    _statFuture = statService.fetchMonthlyStat(start, end);
  }

  void _setSelectedMonth({required int year, required int month}) {
    final selected = DateTime(year, month, 1);
    ref.read(selectedMonthProvider.notifier).state = selected;

    // 선택 월이 바뀌면 거래 목록도 즉시 재조회
    ref.invalidate(transactionNotifierProvider);

    setState(() {
      start = DateTime(selected.year, selected.month, 1);
      end = DateTime(selected.year, selected.month + 1, 1);
      _statFuture = statService.fetchMonthlyStat(start, end);
    });
  }

  //달 선택
  Future<void> _pickMonth() async {
    final selectedMonth = ref.read(selectedMonthProvider);
    final picked = await showMonthPickerDialog(
      context: context,
      initialMonth: selectedMonth,
      firstYear: 2025,
    );

    if (picked == null) return;
    _setSelectedMonth(year: picked.year, month: picked.month);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final year = selectedMonth.year;
    final month = selectedMonth.month;

    ref.listen<AsyncValue<String?>>(authUserIdProvider, (prev, next) {
      if (next.isLoading) return;
      final prevId = prev?.value;
      final nextId = next.value;
      if (prevId == nextId) return;

      ref.invalidate(transactionNotifierProvider);
      if (!mounted) return;
      setState(() {
        _statFuture = statService.fetchMonthlyStat(start, end);
      });
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(6.hClamp),
        child: AppBar(
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: MainColors.mainLight,
          titleSpacing: 0,
        ),
      ),
      //메인 목표
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.wClamp),
        child: Column(
          children: [
            SizedBox(height: 10.hClamp),
            MonthlyHeader(month: selectedMonth),
            //년도, 월
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: _pickMonth,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 6.hClamp,
                      horizontal: 4.wClamp,
                    ),
                    child: Text(
                      "$year년  $month월",
                      style: TextStyle(
                        fontSize: 15.spClamp,
                        color: MainColors.mainDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 고정된 테이블 헤더
            TableHeader(),
            //테이블 리스트
            Expanded(
              child: ref
                  .watch(transactionNotifierProvider)
                  .when(
                    data: (transactions) => TableList(
                      key: ValueKey('table-$year-$month'),
                      transactions: transactions,
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('오류: $err')),
                  ),
            ),
            //여백
            Container(
              height: 5.hClamp,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: MainColors.point, width: 1),
                ),
              ),
            ),
            //결과
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: BuildTotal(
                    text: "카드",
                    textColor: MainColors.mainDark,
                    topBorder: 1,
                    rightBorder: 1,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: StatFutureBuilder(
                    future: _statFuture,
                    valueBuilder: (stat) =>
                        NumberFormat('#,###').format(stat.cardBalance),
                    textColor: MainColors.mainDark,
                    topBorder: 1,
                    rightBorder: 1,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: BuildTotal(
                    text: "현금",
                    textColor: MainColors.mainDark,
                    topBorder: 1,
                    rightBorder: 1,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: StatFutureBuilder(
                    future: _statFuture,
                    valueBuilder: (stat) =>
                        NumberFormat('#,###').format(stat.cashBalance),
                    textColor: MainColors.mainDark,
                    topBorder: 1,
                  ),
                ),
              ],
            ),
            // 결과
            FutureBuilder<MonthlyStat?>(
              future: _statFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  // 에러 상태
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("데이터를 불러오는 중 오류가 발생했습니다."),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.connectionState == ConnectionState.active) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  );
                }

                final stat = snapshot.data;
                final totalIncome = stat?.totalIncome ?? 0;
                final totalExpense = stat?.totalExpense ?? 0;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: BuildTotal(
                        text: "수익",
                        textColor: MainColors.income,
                        rightBorder: 1,
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: BuildTotal(
                        text: "+${NumberFormat('#,###').format(totalIncome)}",
                        textColor: MainColors.income,
                        rightBorder: 1,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: BuildTotal(
                        text: "지출",
                        textColor: MainColors.expense,
                        rightBorder: 1,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: BuildTotal(
                        text: "-${NumberFormat('#,###').format(totalExpense)}",
                        textColor: MainColors.expense,
                      ),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: 5.hClamp),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: BuildTotal(
                    text: "잔액",
                    textColor: const Color.fromARGB(255, 119, 98, 169),
                    topBorder: 1,
                    rightBorder: 1,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: StatFutureBuilder(
                    future: _statFuture,
                    valueBuilder: (stat) {
                      final totalSum = stat.totalIncome - stat.totalExpense;
                      return NumberFormat('#,###').format(totalSum);
                    },
                    textColor: const Color.fromARGB(255, 119, 98, 169),
                    topBorder: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 50.hClamp),
          ],
        ),
      ),

      // fab버튼
      floatingActionButton: FloatingMenuButton(),
    );
  }
}
