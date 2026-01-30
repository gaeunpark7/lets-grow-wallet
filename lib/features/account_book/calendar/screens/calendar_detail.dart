import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/features/account_book/calendar/widgets/calendar_detail_emotion.dart';
import 'package:lets_grow_wallet/features/account_book/model/daily_category_stat_model.dart';
import 'package:lets_grow_wallet/features/account_book/services/daily_category_stat_service.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/kst_time.dart';

class CalendartDetail extends StatefulWidget {
  final DateTime? selectedDate;

  const CalendartDetail({super.key, required this.selectedDate});

  @override
  State<CalendartDetail> createState() => _CalendartDetailState();
}

class _CalendartDetailState extends State<CalendartDetail> {
  late Future<List<DailyCategoryStatModel>> _dailyStatsFuture;
  late final DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = widget.selectedDate ?? todayKst();
    _dailyStatsFuture = DailyCategoryStatService().fetchDailyCategoryStat(
      date: _date,
    );
  }

  String _getWeekday(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

  //Divider
  Widget _separator() => Container(height: 1, color: MainColors.mainLight);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // final dialogWidth = media.size.width.clamp(0, 360.0) * 0.92;
    final dialogHeight = media.size.height * 0.4;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: dialogHeight,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              //헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd').format(_date),
                    style: TextStyle(
                      fontSize: 24,
                      color: MainColors.mainDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    "${_getWeekday(_date)}요일",
                    style: TextStyle(
                      fontSize: 18,
                      color: MainColors.mainDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  CalendarDetailEmotion(selectedDate: _date),
                ],
              ),
              Divider(color: MainColors.mainLight, thickness: 2),
              SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<DailyCategoryStatModel>>(
                  future: _dailyStatsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: MainColors.mainLight,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          '데이터를 불러올 수 없습니다.',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final stats = snapshot.data ?? [];

                    if (stats.isEmpty) {
                      return Center(
                        child: Text(
                          '오늘의 데이터가 없습니다.',
                          style: TextStyle(
                            color: MainColors.mainDark,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }

                    final incomeStats = stats
                        .where((s) => s.type == 'income')
                        .toList();
                    final expenseStats = stats
                        .where((s) => s.type == 'expense')
                        .toList();

                    final children = <Widget>[];

                    if (incomeStats.isNotEmpty) {
                      children.add(
                        Text(
                          '수입',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: MainColors.income,
                          ),
                        ),
                      );
                      children.add(SizedBox(height: 8));
                      children.addAll(
                        incomeStats.map(
                          (stat) => _buildCategoryRow(
                            stat.categoryName,
                            stat.totalAmount,
                            isIncome: true,
                          ),
                        ),
                      );
                      children.add(SizedBox(height: 12));
                    }

                    if (expenseStats.isNotEmpty) {
                      children.add(
                        Text(
                          '지출',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: MainColors.expense,
                          ),
                        ),
                      );
                      children.add(SizedBox(height: 8));
                      children.addAll(
                        expenseStats.map(
                          (stat) => _buildCategoryRow(
                            stat.categoryName,
                            stat.totalAmount,
                            isIncome: false,
                          ),
                        ),
                      );
                      children.add(SizedBox(height: 12));
                    }

                    return ListView(children: children);
                  },
                ),
              ),

              SizedBox(height: 12),

              //닫기 버튼
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: MainColors.mainLight,
                  ),
                  child: Center(
                    child: Text(
                      "닫기",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(
    String categoryName,
    int amount, {
    required bool isIncome,
  }) {
    final formatter = NumberFormat('#,##0');
    final formattedAmount = formatter.format(amount);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: TextStyle(fontSize: 14, color: MainColors.mainDark),
              ),
              Text(
                isIncome ? '+$formattedAmount원' : '-$formattedAmount원',
                style: TextStyle(fontSize: 14, color: MainColors.mainDark),
              ),
            ],
          ),
          SizedBox(height: 2),
          _separator(),
        ],
      ),
    );
  }
}
