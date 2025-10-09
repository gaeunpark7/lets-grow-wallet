import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/build_total.dart';
import 'package:lets_grow_wallet/features/account_book/model/montyle_stat_model.dart';

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
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text("오류 발생");
        }
        final stat = snapshot.data!;
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
