import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/stats_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/stats/widgets/category_chart_widget.dart';
import 'package:lets_grow_wallet/features/account_book/stats/widgets/category_state_tile.dart';
import 'package:lets_grow_wallet/features/account_book/stats/widgets/stats_error_page.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/friendly_error_message.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class StatsIncomeView extends ConsumerWidget {
  const StatsIncomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(selectedMonthProvider);
    final asyncValue = ref.watch(monthlyCategoryStatsNotifierProvider);

    return asyncValue.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: MainColors.mainLight),
      ),
      error: (e, st) {
        final error = FriendlyErrorMessage.resolve(e);
        return StatsErrorPage(
          errorMessage: error.message,
          onRetry: () =>
              ref.read(monthlyCategoryStatsNotifierProvider.notifier).refresh(),
        );
      },
      data: (list) {
        final data = pickAmounts(list, StatsKind.income);
        return Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CategoryChartWidget(data: data),
                Divider(
                  thickness: 1,
                  height: 5.hClamp,
                  color: MainColors.point,
                ),
                CategoryStatList(data: data),
              ],
            ),
          ),
        );
      },
    );
  }
}
