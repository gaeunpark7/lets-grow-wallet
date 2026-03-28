import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/stats_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/month_picker_dialog.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/kst_time.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

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

    final minMonth = DateTime(2026, 1, 1);
    final now = nowKst();
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
              firstYear: 2026,
            );

            if (picked == null) return;
            if (picked.isAfter(maxMonth)) return;
            if (picked.isBefore(minMonth)) return;

            ref.read(selectedMonthProvider.notifier).state = picked;
          },
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18.spClamp,
              color: MainColors.mainDark,
              fontWeight: FontWeight.bold,
              fontFamily: 'ScoreMedium',
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
