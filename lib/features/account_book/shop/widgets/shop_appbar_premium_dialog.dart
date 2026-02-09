import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class ShopAppbarPremiumDialog extends StatelessWidget {
  const ShopAppbarPremiumDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.rClamp),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Padding(
          padding: EdgeInsets.all(12.wClamp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "프리미엄 구매",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 99, 119, 157),
                  fontSize: 18.spClamp,
                ),
              ),
              Divider(color: MainColors.mainLight),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset(
                    'assets/premium/premium_ad.png',
                    width: 110.wClamp,
                    height: 110.hClamp,
                  ),
                  Image.asset(
                    'assets/premium/premium_king.png',
                    width: 130.wClamp,
                    height: 130.hClamp,
                  ),
                ],
              ),
              SizedBox(height: 12.hClamp),
              _buildTile(title: "광고 제거", subtitle: "무제한"),
              Divider(color: MainColors.mainLight, height: 0),
              SizedBox(height: 6.hClamp),
              _buildTile(title: "한정 캐릭터 알 지급", subtitle: "영구 소장"),
              Divider(color: MainColors.mainLight, height: 0),
              SizedBox(height: 12.hClamp),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: MainColors.mainLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.rClamp),
                    ),
                    minimumSize: Size.fromHeight(45.hClamp),
                  ),
                  onPressed: () {},
                  child: Text(
                    "₩3,900 구매하기",
                    style: TextStyle(
                      fontSize: 16.spClamp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _buildTile extends StatelessWidget {
  final String title;
  final String subtitle;
  const _buildTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(color: MainColors.mainDark, fontSize: 14.spClamp),
        ),
        Text(
          subtitle,
          style: TextStyle(color: MainColors.mainDark, fontSize: 14.spClamp),
        ),
      ],
    );
  }
}
