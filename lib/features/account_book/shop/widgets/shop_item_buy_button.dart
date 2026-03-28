import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class ShopItemBuyButton extends StatelessWidget {
  final bool isPurchased;
  final VoidCallback? onPressed;

  const ShopItemBuyButton({
    super.key,
    required this.isPurchased,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.hClamp,
      child: FilledButton(
        style: FilledButton.styleFrom(
          side: BorderSide.none,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          foregroundColor: Colors.white,
          backgroundColor: MainColors.mainLight,
        ),
        onPressed: isPurchased ? null : onPressed,
        child: Text(
          isPurchased ? "구매 완료" : "구매",
          style: TextStyle(fontSize: 18.spClamp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
