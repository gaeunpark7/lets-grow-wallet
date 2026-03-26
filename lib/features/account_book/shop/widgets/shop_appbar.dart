import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/shop_notifier.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class ShopAppbar extends ConsumerWidget {
  const ShopAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final coinAsync = ref.watch(coinNotifierProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // GestureDetector(
        //   onTap: () async {
        //     await showDialog(
        //       context: context,
        //       builder: (ctx) => ShopAppbarPremiumDialog(),
        //     );
        //   },
        //   child: Container(
        //     height: 40.hClamp,
        //     width: 40.wClamp,
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       shape: BoxShape.circle,
        //       border: Border.all(color: MainColors.mainLight, width: 1),
        //     ),
        //     child: Icon(
        //       Icons.workspace_premium_outlined,
        //       color: MainColors.mainLight,
        //       size: 24.hClamp,
        //     ),
        //   ),
        // ),
        SizedBox(width: 10.wClamp),
        Container(
          height: 40.hClamp,
          width: mediaQuery.size.width * 0.3,
          decoration: BoxDecoration(
            border: Border.all(color: MainColors.mainLight, width: 1),
            borderRadius: BorderRadius.circular(20.rClamp),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 15.wClamp),
              coinAsync.when(
                data: (coin) => Row(
                  children: [
                    Text(
                      'C $coin',
                      style: TextStyle(
                        fontSize: 18.spClamp,
                        color: MainColors.mainLight,
                      ),
                    ),
                  ],
                ),

                loading: () => Text(
                  'C ...',
                  style: TextStyle(
                    fontSize: 18.spClamp,
                    color: MainColors.mainLight,
                  ),
                ),
                error: (e, st) => Text(
                  'C 0',
                  style: TextStyle(
                    fontSize: 18.spClamp,
                    color: MainColors.mainLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
