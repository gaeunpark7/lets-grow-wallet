import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CategoryStatList extends StatelessWidget {
  final List<({String id, String name, int amount})> data;

  const CategoryStatList({super.key, required this.data});

  static const _palette = <Color>[
    Color(0xFF7986CB),
    Color(0xFF9FA8DA),
    Color(0xFFC5CAE9),
    Color(0xFFE8EAF6),
    Color(0xFFF5F5FA),
    Color(0xFFB3E5FC),
    Color(0xFFB2DFDB),
    Color(0xFFC8E6C9),
    Color(0xFFFFF9C4),
    Color(0xFFFFE4B5),
  ];

  Color _colorFor(String id) {
    final h = id.codeUnits.fold<int>(0, (p, c) => p + c);
    return _palette[h % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (p, e) => p + e.amount);
    final f = NumberFormat.decimalPattern('ko');

    //내림차순 정렬
    final sorted = [...data];
    sorted.sort(
      (a, b) => (b.amount / (total == 0 ? 1 : total)).compareTo(
        a.amount / (total == 0 ? 1 : total),
      ),
    );

    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sorted.length,
        separatorBuilder: (_, __) => const SizedBox(height: 0),
        itemBuilder: (context, idx) {
          final e = sorted[idx];
          final percent = total == 0 ? 0 : (e.amount / total * 100).round();
          final color = _palette[idx % _palette.length]; // 내림차순 순서대로 색상 적용
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                // 퍼센트와 색상 박스
                Container(
                  width: 40,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "$percent%",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 아이콘/이모지
                // Text(
                //   _emojiForCategory(e.name),
                //   style: const TextStyle(fontSize: 22),
                // ),
                // const SizedBox(width: 8),
                // 카테고리
                Expanded(
                  child: Text(
                    e.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: MainColors.mainDark,
                      // fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // 금액
                Text(
                  "${f.format(e.amount)}원",
                  style: const TextStyle(
                    color: MainColors.mainDark,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 카테고리 이모지
  String _emojiForCategory(String name) {
    if (name.contains("카페")) return "☕";
    if (name.contains("교육")) return "📚";
    if (name.contains("문화")) return "🖼️";
    // 기본값
    return "💸";
  }
}
