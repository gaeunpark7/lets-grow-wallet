// ...existing code...
import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/build_total.dart';
import 'package:lets_grow_wallet/features/account_book/model/monthly_stat_model.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class StatFutureBuilder extends StatelessWidget {
  final Future<MonthlyStat?> future;
  final String Function(MonthlyStat stat) valueBuilder;
  final Color textColor;
  final int topBorder;
  final int rightBorder;

  const StatFutureBuilder({
    super.key,
    required this.future,
    required this.valueBuilder,
    this.textColor = Colors.black,
    this.topBorder = 0,
    this.rightBorder = 0,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MonthlyStat?>(
      future: future,
      builder: (context, snapshot) {
        // 네트워크 진행 중 - 로딩 표시
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          return const Center(
            child: CircularProgressIndicator(color: MainColors.mainLight),
          );
        }

        // 에러 발생: 0 or 빈 텍스트
        if (snapshot.hasError) {
          return BuildTotal(
            text: "0",
            textColor: textColor,
            topBorder: topBorder,
            rightBorder: rightBorder,
          );
        }

        // 3) 완료 상태지만 데이터가 null인 경우에도 0으로 표시
        final stat = snapshot.data;
        if (stat == null) {
          return BuildTotal(
            text: "0",
            textColor: textColor,
            topBorder: topBorder,
            rightBorder: rightBorder,
          );
        }

        // 4) 정상 데이터
        return BuildTotal(
          text: valueBuilder(stat),
          textColor: textColor,
          topBorder: topBorder,
          rightBorder: rightBorder,
        );
      },
    );
  }
}
