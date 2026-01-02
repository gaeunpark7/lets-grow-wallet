import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/features/account_book/calendar/widgets/calendar_detail_emotion.dart';
import 'package:lets_grow_wallet/features/account_book/model/daily_category_stat_model.dart';
import 'package:lets_grow_wallet/features/account_book/services/daily_category_stat_service.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CalendartDetail extends StatefulWidget {
  final DateTime? selectedDate;

  const CalendartDetail({super.key, required this.selectedDate});

  @override
  State<CalendartDetail> createState() => _CalendartDetailState();
}

class _CalendartDetailState extends State<CalendartDetail> {
  late Future<List<DailyCategoryStatModel>> _dailyStatsFuture;

  @override
  void initState() {
    super.initState();
    _dailyStatsFuture = DailyCategoryStatService().fetchDailyCategoryStat(
      date: widget.selectedDate ?? DateTime.now(),
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
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            //헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  DateFormat(
                    'dd',
                  ).format(widget.selectedDate ?? DateTime.now()),
                  style: TextStyle(
                    fontSize: 24,
                    color: MainColors.mainDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  "${_getWeekday(widget.selectedDate ?? DateTime.now())}요일",
                  style: TextStyle(
                    fontSize: 18,
                    color: MainColors.mainDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                CalendarDetailEmotion(
                  selectedDate: widget.selectedDate ?? DateTime.now(),
                ),
              ],
            ),
            Divider(color: MainColors.mainLight, thickness: 2),

            SizedBox(height: 12),

            // 데이터 표시
            FutureBuilder<List<DailyCategoryStatModel>>(
              future: _dailyStatsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: CircularProgressIndicator(
                      color: MainColors.mainLight,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      '데이터를 불러올 수 없습니다.',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                final stats = snapshot.data ?? [];

                // 데이터가 없는 경우
                if (stats.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      '오늘의 데이터가 없습니다.',
                      style: TextStyle(
                        color: MainColors.mainDark,
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                // 수입 / 지출 분류
                final incomeStats = stats
                    .where((s) => s.type == 'income')
                    .toList();
                final expenseStats = stats
                    .where((s) => s.type == 'expense')
                    .toList();

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 수입
                      if (incomeStats.isNotEmpty) ...[
                        Text(
                          '수입',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: MainColors.income,
                          ),
                        ),
                        SizedBox(height: 8),
                        ...incomeStats.map(
                          (stat) => _buildCategoryRow(
                            stat.categoryName,
                            stat.totalAmount,
                            isIncome: true,
                          ),
                        ),
                        SizedBox(height: 12),
                      ],

                      // 지출
                      if (expenseStats.isNotEmpty) ...[
                        Text(
                          '지출',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: MainColors.expense,
                          ),
                        ),
                        SizedBox(height: 8),
                        ...expenseStats.map(
                          (stat) => _buildCategoryRow(
                            stat.categoryName,
                            stat.totalAmount,
                            isIncome: false,
                          ),
                        ),
                        SizedBox(height: 12),
                      ],
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 12),

            //닫기 버튼
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
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
