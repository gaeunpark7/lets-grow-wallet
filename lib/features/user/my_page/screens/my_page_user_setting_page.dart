import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class MyPageUserSettingPage extends StatelessWidget {
  const MyPageUserSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.hClamp),
        child: AppBar(
          backgroundColor: MainColors.mainLight,
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 32.hClamp),
          Divider(color: MainColors.mainDark, thickness: 0.5),
          _MyPageSettingListTile(
            icon: Icons.privacy_tip_outlined,
            text: "개인정보 처리방침",
            onTap: () {
              context.push(Routes.privacyPolicy);
            },
          ),
          Divider(color: MainColors.mainDark, thickness: 0.5),
          _MyPageSettingListTile(
            icon: Icons.delete_forever_outlined,
            text: "회원탈퇴",
            onTap: () {
              context.push(Routes.deleteUser);
            },
          ),
          Divider(color: MainColors.mainDark, thickness: 0.5),
        ],
      ),
    );
  }
}

class _MyPageSettingListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;

  const _MyPageSettingListTile({
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -4),
      minVerticalPadding: 0,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.wClamp, vertical: 8),
      leading: Icon(icon, color: MainColors.point, size: 28.hClamp),
      trailing: Text(
        text,
        style: TextStyle(color: MainColors.mainDark, fontSize: 16.spClamp),
      ),
      onTap: onTap,
    );
  }
}
