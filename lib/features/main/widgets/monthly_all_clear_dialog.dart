import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class MonthlyAllClearDialog extends StatelessWidget {
  final List<dynamic> logs;
  const MonthlyAllClearDialog({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final firstGoal = logs.isNotEmpty ? logs[0]['goals'] : null;
    final String goalTitle = firstGoal != null
        ? (firstGoal['title'] ?? '월간 목표')
        : '월간 목표';

    String formatWon(dynamic value) {
      num? number;
      if (value is num) {
        number = value;
      } else {
        final digits = value?.toString().replaceAll(RegExp(r'[^0-9-]'), '');
        if (digits != null && digits.isNotEmpty) {
          number = num.tryParse(digits);
        }
      }
      return NumberFormat.decimalPattern('ko_KR').format((number ?? 0).round());
    }

    // 수입/지출
    final incomeLog = logs.any((e) => e['reward_type'] == 'income')
        ? logs.firstWhere((e) => e['reward_type'] == 'income')
        : null;

    final expenseLog = logs.any((e) => e['reward_type'] == 'expense')
        ? logs.firstWhere((e) => e['reward_type'] == 'expense')
        : null;
    // 목표 금액 추출
    String getAmount(dynamic log) {
      if (log == null || log['goals'] == null) return "0";

      final goalData = log['goals'];
      if (goalData is List && goalData.isNotEmpty) {
        return "${goalData[0]['target_amount'] ?? 0}";
      }

      if (goalData is Map) {
        return "${goalData['target_amount'] ?? 0}";
      }
      return "0";
    }

    final String incomeAmount = getAmount(incomeLog);
    final String expenseAmount = getAmount(expenseLog);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.rClamp),
      ),

      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Padding(
          padding: EdgeInsets.all(14.rClamp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '목표 달성 성공!',
                style: TextStyle(
                  fontSize: 18.spClamp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ScoreMedium',
                  color: MainColors.mainDark,
                ),
              ),
              Text(
                goalTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.spClamp,
                  color: Colors.grey[600],
                  fontFamily: 'ScoreMedium',
                ),
              ),
              SizedBox(height: 8.hClamp),

              Divider(
                color: const Color.fromRGBO(209, 216, 236, 1),
                height: 0,
                thickness: 1,
              ),
              SizedBox(height: 12.hClamp),
              if (incomeLog != null) ...[
                _buildDialogTile("수입목표", "${formatWon(incomeAmount)}원"),
                _buildDialogDivider(context),
              ],
              if (expenseLog != null) ...[
                _buildDialogTile("지출목표", "${formatWon(expenseAmount)}원"),
                _buildDialogDivider(context),
              ],
              _buildDialogTile("XP", "+300"),
              _buildDialogDivider(context),
              SizedBox(height: 6.hClamp),
              // SizedBox(height: 8.hClamp),
              _buildDialogTile("Coin", "+300"),
              _buildDialogDivider(context),
              SizedBox(height: 12.hClamp),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Bonus Reward!',
                    style: TextStyle(
                      fontSize: 16.spClamp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ScoreMedium',
                      color: MainColors.mainDark,
                    ),
                  ),
                ],
              ),

              Divider(color: MainColors.mainLight, height: 2),
              SizedBox(height: 8.hClamp),
              _buildDialogTile("XP", "+50"),
              _buildDialogDivider(context),
              SizedBox(height: 6.hClamp),

              _buildDialogTile("Coin", "+50"),
              _buildDialogDivider(context),

              SizedBox(height: 14.hClamp),
              // 5. 확인 버튼
              FilledButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MainColors.mainLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.rClamp),
                  ),
                  minimumSize: Size(double.infinity, 45.hClamp),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  '확인',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.spClamp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ScoreMedium',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Divider _buildDialogDivider(BuildContext context) {
    return Divider(color: MainColors.mainLight, thickness: 0.5, height: 2);
  }

  Row _buildDialogTile(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.spClamp,
            color: MainColors.mainDark,
            fontFamily: 'ScoreMedium',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.spClamp,
            color: MainColors.mainDark,
            fontFamily: 'ScoreMedium',
          ),
        ),
      ],
    );
  }
}
