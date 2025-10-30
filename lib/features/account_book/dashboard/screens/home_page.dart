import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/screens/home_page_detailv2.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/build_total.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/floating_menu_button.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/monthly_header.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/stat_future_builder.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/table_header.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/table_list.dart';
import 'package:lets_grow_wallet/features/account_book/model/category_model.dart';
import 'package:lets_grow_wallet/features/account_book/services/stat_service.dart';
import 'package:lets_grow_wallet/features/account_book/services/transaction_service.dart';
import 'package:lets_grow_wallet/features/account_book/shop/screens/item_shop_page.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/transaction_model.dart';
import '../../model/montyle_stat_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _homePageState();
}

class _homePageState extends State<HomePage> {
  List<TransactionModel> todayTransactions = [];
  List<Category> categories = [];
  final statService = StatService();
  final transactionService = TransactionService();
  late final Future stat;

  late DateTime start;
  late DateTime end;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    start = DateTime(now.year, now.month, 1);
    end = DateTime(now.year, now.month + 1, 1);
    stat = statService.fetchMonthlyStat(start, end);
    loadTodayTransactions();
  }

  //이번달의 데이터만 불러옴 + 내림차순
  Future<void> loadTodayTransactions() async {
    final supabase = Supabase.instance.client;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);

    final response = await supabase
        .from('transactions')
        .select('*, categories(name)')
        .gte('date', start.toIso8601String()) // 시작 날짜 조건
        .lt('date', end.toIso8601String()) // 끝 날짜 조건
        .order('date', ascending: false); // 내림차순 정렬

    setState(() {
      todayTransactions = (response as List)
          .map((e) => TransactionModel.fromMap(e))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    final screenWidth = MediaQuery.of(context).size.width; // 반응형 너비
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: MainColors.mainLight,
            titleSpacing: 0,
          ),
        ),
        //메인 목표
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              SizedBox(height: 10),
              MonthlyHeader(),
              //년도, 일
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "$year년  $month월",
                    style: TextStyle(
                      fontSize: 15,
                      color: MainColors.mainDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // 고정된 테이블 헤더
              TableHeader(),
              //테이블 리스트
              Expanded(child: TableList(transactions: todayTransactions)),
              //여백
              Container(
                height: 5,
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
                      future: statService.fetchMonthlyStat(start, end),
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
                      future: statService.fetchMonthlyStat(start, end),
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
                future: statService.fetchMonthlyStat(start, end),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    // 에러 상태
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("데이터를 불러오는 중 오류가 발생했습니다."),
                    );
                  }
                  final stat = snapshot.data!;
                  final totalSum = stat.totalIncome - stat.totalExpense;

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
                          text:
                              "+${NumberFormat('#,###').format(stat.totalIncome) ?? "0"}",
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
                          text:
                              "-${NumberFormat('#,###').format(stat.totalExpense) ?? "0"}",
                          textColor: MainColors.expense,
                        ),
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 5),
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
                      future: statService.fetchMonthlyStat(start, end),
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
              const SizedBox(height: 50),
            ],
          ),
        ),

        // fab버튼
        floatingActionButton: FloatingMenuButton(),
      ),
    );
  }
}
