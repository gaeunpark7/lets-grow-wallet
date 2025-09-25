import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/screens/home_page_detail.dart';
import 'package:lets_grow_wallet/features/account_book/services/stat_service.dart';
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
  final statService = StatService();
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
        .select()
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Spacer(),
                    Spacer(),
                    Spacer(),
                    Text(
                      "이번달의 목표는?",
                      style: TextStyle(
                        color: MainColors.mainDark,
                        fontSize: screenWidth * 0.06, // 반응형 폰트
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.edit_note_outlined,
                      size: 30,
                      color: MainColors.point,
                    ),
                    Spacer(),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("$year년  $month월", style: TextStyle(fontSize: 15)),
                ],
              ),
              // 고정된 테이블 헤더
              Table(
                border: TableBorder(
                  top: BorderSide(color: Colors.black, width: 1),
                  bottom: BorderSide(color: Colors.black, width: 1.2),
                  verticalInside: BorderSide(color: Colors.black, width: 1),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(1), // 날짜
                  1: FlexColumnWidth(3), // 내역
                  2: FlexColumnWidth(3), // 지출
                  3: FlexColumnWidth(1), // 카드
                  4: FlexColumnWidth(1), // 현금
                },
                children: [
                  TableRow(
                    children: [
                      _buildHeaderCell("날짜"),
                      _buildHeaderCell("내역"),
                      _buildHeaderCell("금액"),
                      _buildHeaderCell("카드"),
                      _buildHeaderCell("현금"),
                    ],
                  ),
                ],
              ),
              // 고정된 빈 테이블
              Expanded(
                child: ListView.builder(
                  itemCount: todayTransactions.length + 15,
                  itemBuilder: (context, index) {
                    if (index < todayTransactions.length) {
                      // 데이터가 있는 경우
                      final tx = todayTransactions[index];
                      final isExpense = tx.type == 'expense';
                      final isCash = tx.paymentMethod == 1;
                      return Table(
                        border: TableBorder(
                          bottom: BorderSide(color: Colors.black, width: 1),
                          verticalInside: BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(1), // 날짜
                          1: FlexColumnWidth(3), // 내역
                          2: FlexColumnWidth(3), // 지출
                          3: FlexColumnWidth(1), // 카드
                          4: FlexColumnWidth(1), // 현금
                        },
                        children: [
                          TableRow(
                            children: [
                              _buildCell(DateFormat('d').format(tx.date)),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) =>
                                          HomePageDetail(transaction: tx),
                                    ),
                                  );
                                },
                                child: _buildCell(tx.title),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  isExpense
                                      ? "-${NumberFormat('#,###').format(tx.amount)}"
                                      : "+${NumberFormat('#,###').format(tx.amount)}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isExpense
                                        ? Colors.red
                                        : MainColors.mainDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildCell(tx.paymentMethod == 0 ? "O" : " "),
                              _buildCell(tx.paymentMethod == 1 ? "O" : " "),
                            ],
                          ),
                        ],
                      );
                    } else {
                      // 데이터가 없는 경우 빈 행 렌더링
                      return Table(
                        border: TableBorder(
                          bottom: BorderSide(color: Colors.black, width: 1),
                          verticalInside: BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(1), // 날짜
                          1: FlexColumnWidth(3), // 내역
                          2: FlexColumnWidth(3), // 지출
                          3: FlexColumnWidth(1), // 카드
                          4: FlexColumnWidth(1), // 현금
                        },
                        children: [
                          TableRow(
                            children: [
                              _buildCell(""),
                              _buildCell(""),
                              _buildCell(""),
                              _buildCell(""),
                              _buildCell(""),
                            ],
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),

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
                  final stat = snapshot.data!;
                  final totalSum = stat.totalIncome - stat.totalExpense;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildTotal(
                          text: "수익",
                          textColor: MainColors.mainDark,
                          topBorder: 1,
                          rightBorder: 1,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _buildTotal(
                          text:
                              "+${NumberFormat('#,###').format(stat.totalIncome)}",
                          textColor: MainColors.mainDark,
                          rightBorder: 1,
                          topBorder: 1,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: _buildTotal(
                          text: "지출",
                          textColor: Colors.red,
                          rightBorder: 1,
                          topBorder: 1,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _buildTotal(
                          text:
                              "-${NumberFormat('#,###').format(stat.totalExpense)}",
                          textColor: Colors.red,
                          topBorder: 1,
                        ),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<MonthlyStat?>(
                future: statService.fetchMonthlyStat(start, end),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    );
                  }
                  final stat = snapshot.data!;
                  final totalSum = stat.totalIncome - stat.totalExpense;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildTotal(
                          text: "잔액",
                          textColor: const Color.fromARGB(255, 119, 98, 169),
                          rightBorder: 1,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _buildTotal(
                          text: NumberFormat('#,###').format(totalSum),
                          textColor: const Color.fromARGB(255, 119, 98, 169),
                          rightBorder: 1,
                        ),
                      ),
                      Expanded(flex: 3, child: Container()),
                    ],
                  );
                },
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          backgroundColor: MainColors.mainLight,
          child: Icon(Icons.mood, color: Colors.white, size: 40),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1, // 텍스트 줄 제한
        overflow: TextOverflow.ellipsis, // 줄바꿈 방지
      ),
    );
  }
}

class _buildTotal extends StatelessWidget {
  final String? text;
  final int topBorder;
  final int rightBorder;
  final Color textColor;
  const _buildTotal({
    super.key,
    this.text,
    this.topBorder = 0,
    this.rightBorder = 0,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: topBorder == 0
              ? BorderSide.none
              : BorderSide(color: Colors.black, width: 1),
          bottom: BorderSide(color: Colors.black, width: 1),
          left: BorderSide.none,
          right: rightBorder == 0
              ? BorderSide.none
              : BorderSide(color: Colors.black, width: 1),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text ?? "",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: textColor),
      ),
    );
  }
}
