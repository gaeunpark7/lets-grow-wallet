import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/shop_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_appbar_premium_dialog.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class ShopAppbar extends ConsumerWidget {
  const ShopAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final coinAsync = ref.watch(coinNotifierProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () async {
            await showDialog(
              context: context,
              builder: (ctx) => ShopAppbarPremiumDialog(),
            );
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: MainColors.mainLight, width: 1),
            ),
            child: Icon(
              Icons.workspace_premium_outlined,
              color: MainColors.mainLight,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 40,
          width: mediaQuery.size.width * 0.35,
          decoration: BoxDecoration(
            border: Border.all(color: MainColors.mainLight, width: 1),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 15),
              coinAsync.when(
                data: (coin) => Text(
                  'C $coin',
                  style: TextStyle(fontSize: 18, color: MainColors.mainLight),
                ),
                loading: () => Text(
                  'C ...',
                  style: TextStyle(fontSize: 18, color: MainColors.mainLight),
                ),
                error: (e, st) => Text(
                  'C 0',
                  style: TextStyle(fontSize: 18, color: MainColors.mainLight),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
