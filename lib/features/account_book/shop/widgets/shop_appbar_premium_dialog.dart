import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class ShopAppbarPremiumDialog extends StatelessWidget {
  const ShopAppbarPremiumDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "프리미엄 구매",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 99, 119, 157),
                fontSize: 18,
              ),
            ),
            Divider(color: MainColors.mainLight),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/ad/ad_image.png', width: 130, height: 130),
                Image.asset(
                  'assets/ad/king1_basic.png',
                  width: 160,
                  height: 160,
                ),
              ],
            ),
            _buildTile(title: "광고 제거", subtitle: "무제한"),
            Divider(color: MainColors.mainLight, height: 0),
            SizedBox(height: 6),
            _buildTile(title: "한정 캐릭터 알 지급", subtitle: "영구 소장"),
            Divider(color: MainColors.mainLight, height: 0),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: MainColors.mainLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: const Size.fromHeight(45),
                ),
                onPressed: () {},
                child: const Text(
                  "₩3,900 구매하기",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _buildTile extends StatelessWidget {
  String title;
  String subtitle;
  _buildTile({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: MainColors.mainDark)),
        Text(subtitle, style: const TextStyle(color: MainColors.mainDark)),
      ],
    );
  }
}
