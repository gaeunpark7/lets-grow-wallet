import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class ShopItemBuyButton extends StatelessWidget {
  const ShopItemBuyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Expanded(
        flex: 1,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.06,
          child: FilledButton(
            style: FilledButton.styleFrom(
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              foregroundColor: Colors.white,
              backgroundColor: MainColors.mainLight,
              // fixedSize: Size(
              //   MediaQuery.of(context).size.width,
              //   // MediaQuery.of(context).size.height * 0.01,
              // ),
            ),
            onPressed: () {},
            child: Text(
              "구매",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
