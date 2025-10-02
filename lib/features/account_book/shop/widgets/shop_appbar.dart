import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class ShopAppbar extends StatelessWidget {
  const ShopAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,

      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: MainColors.mainDark, width: 1),
          ),
          child: Icon(
            Icons.workspace_premium_outlined,
            color: MainColors.mainLight,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 40,
          width: mediaQuery.size.width * 0.35,
          decoration: BoxDecoration(
            border: Border.all(color: MainColors.mainDark, width: 1),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 15),
              Text(
                "₩",
                style: TextStyle(fontSize: 18, color: MainColors.mainLight),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
