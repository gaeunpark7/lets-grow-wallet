import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/stats_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/month_picker_dialog.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class MonthHeader extends ConsumerWidget {
  final ValueChanged<StatsKind> onKindChanged;
  final StatsKind current;

  const MonthHeader({
    super.key,
    required this.onKindChanged,
    required this.current,
  });

  DateTime _addMonths(DateTime base, int delta) {
    final y = base.year + ((base.month + delta - 1) ~/ 12);
    final m = (base.month + delta - 1) % 12 + 1;
    return DateTime(y, m, 1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final label = '${month.year}년 ${month.month}월';

    final minMonth = DateTime(2025, 1, 1);
    final now = DateTime.now();
    final maxMonth = DateTime(now.year, now.month, 1);

    final canPrev = month.isAfter(minMonth);
    final canNext = month.isBefore(maxMonth);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: canPrev
              ? () => ref.read(selectedMonthProvider.notifier).state =
                    _addMonths(month, -1)
              : null,
          icon: const Icon(Icons.chevron_left),
          color: MainColors.mainDark,
          disabledColor: MainColors.point,
        ),
        GestureDetector(
          onTap: () async {
            final picked = await showMonthPickerDialog(
              context: context,
              initialMonth: month,
              firstYear: 2025,
            );

            if (picked == null) return;
            if (picked.isAfter(maxMonth)) return;
            if (picked.isBefore(minMonth)) return;

            ref.read(selectedMonthProvider.notifier).state = picked;
          },
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: MainColors.mainDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: canNext
              ? () => ref.read(selectedMonthProvider.notifier).state =
                    _addMonths(month, 1)
              : null,
          icon: const Icon(Icons.chevron_right),
          color: MainColors.mainDark,
          disabledColor: MainColors.point,
        ),
      ],
    );
  }
}
