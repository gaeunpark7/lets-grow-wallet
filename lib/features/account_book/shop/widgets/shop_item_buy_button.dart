import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

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
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.06,
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
