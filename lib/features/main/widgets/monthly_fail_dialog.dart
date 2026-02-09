import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class MonthlyFailDialog extends StatelessWidget {
  final dynamic log;
  const MonthlyFailDialog({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final String goalTitle = log['goals']['title'] ?? '월간 목표';
    final String typeName = log['reward_type'] == 'income' ? '수입' : '지출';

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
      final formatted = NumberFormat.decimalPattern(
        'ko_KR',
      ).format((number ?? 0).round());
      return formatted;
    }

    final String targetAmount = '${formatWon(log['goals']['target_amount'])}원';
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
                '목표 달성 실패..',
                style: TextStyle(
                  fontSize: 18.spClamp,
                  fontWeight: FontWeight.bold,
                  color: MainColors.mainDark,
                ),
              ),
              Text(
                goalTitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.spClamp, color: Colors.grey[600]),
              ),
              SizedBox(height: 8.hClamp),

              Divider(color: MainColors.mainLight, height: 0, thickness: 1),
              SizedBox(height: 12.hClamp),
              _buildDialogTile(typeName, targetAmount), //소비 OR 수입, 금액
              _buildDialogDivider(context),
              SizedBox(height: 14.hClamp),
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
          style: TextStyle(fontSize: 14.spClamp, color: MainColors.mainDark),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14.spClamp, color: MainColors.mainDark),
        ),
      ],
    );
  }
}
