import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class CategoryChartWidget extends StatelessWidget {
  final List<({String id, String name, int amount})> data;

  const CategoryChartWidget({super.key, required this.data});

  static const _palette = <Color>[
    Color(0xFFEF5350),
    Color(0xFFFFA726),
    Color(0xFFFFEE58),
    Color(0xFF66BB6A),
    Color(0xFF42A5F5),
    Color(0xFFAB47BC),
    Color(0xFF26C6DA),
    Color(0xFF8D6E63),
    Color(0xFF78909C),
  ];

  Color _colorFor(String id) {
    final h = id.codeUnits.fold<int>(0, (p, c) => p + c);
    return _palette[h % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (p, e) => p + e.amount);
    final f = NumberFormat.decimalPattern('ko');

    if (data.isEmpty || total == 0) {
      return const SizedBox(
        height: 340,
        child: Center(child: Text('데이터가 없어요')),
      );
    }

    //파이 섹션  데이터
    final sections = data.map((e) {
      final ratio = total == 0 ? 0.0 : (e.amount / total) * 100.0;
      final showLabel = ratio >= 8; //8% 이상 카테고리만 표시
      // final moneyText = '₩${f.format(e.amount)}';

      return PieChartSectionData(
        value: e.amount.toDouble(),
        title: showLabel ? '${e.name}\n${ratio.toStringAsFixed(1)}% ' : '',
        titleStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        radius: 100,
        badgeWidget: showLabel
            ? null
            : Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  // '₩${f.format(e.amount)}',
                  "${e.name} ${ratio.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
        badgePositionPercentageOffset: 1.15,
        color: _colorFor(e.id),
      );
    }).toList();

    return SizedBox(
      height: 260,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 2,
          centerSpaceRadius: 0, //여백 x
        ),
      ),
    );
  }
}
