import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/user_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/services/admob_service.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class MyPageUserSettingPage extends ConsumerStatefulWidget {
  const MyPageUserSettingPage({super.key});

  @override
  ConsumerState<MyPageUserSettingPage> createState() =>
      _MyPageUserSettingPageState();
}

class _MyPageUserSettingPageState extends ConsumerState<MyPageUserSettingPage> {
  BannerAd? _bannerAd;
  ProviderSubscription<bool>? _premiumSubscription;

  @override
  void initState() {
    super.initState();

    _premiumSubscription = ref.listenManual<bool>(isPremiumProvider, (
      prev,
      next,
    ) {
      if (!mounted) return;

      if (next) {
        setState(() {
          _bannerAd?.dispose();
          _bannerAd = null;
        });
        return;
      }

      if (_bannerAd == null) {
        setState(_createBannerAd);
      }
    });

    if (!ref.read(isPremiumProvider)) {
      _createBannerAd();
    }
  }

  @override
  void dispose() {
    _premiumSubscription?.close();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _createBannerAd() {
    final adUnitId = AdmobService.BannerAdUnitId;
    if (adUnitId == null) return;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: AdmobService.bannerAdListener,
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.hClamp),
        child: AppBar(
          backgroundColor: MainColors.mainLight,
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.wClamp),
        child: Column(
          children: [
            SizedBox(height: 32.hClamp),
            Divider(color: MainColors.mainDark, thickness: 0.5),
            _MyPageSettingListTile(
              icon: Icons.privacy_tip_outlined,
              text: '개인정보 처리방침',
              onTap: () {
                context.push(Routes.privacyPolicy);
              },
            ),
            Divider(color: MainColors.mainDark, thickness: 0.5),
            _MyPageSettingListTile(
              icon: Icons.delete_forever_outlined,
              text: '회원탈퇴',
              onTap: () {
                context.push(Routes.deleteUser);
              },
            ),
            Divider(color: MainColors.mainDark, thickness: 0.5),
          ],
        ),
      ),
      bottomNavigationBar: !isPremium
          ? SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                height: 60.hClamp,
                alignment: Alignment.center,
                child: _bannerAd != null
                    ? AdWidget(ad: _bannerAd!)
                    : const SizedBox.shrink(),
              ),
            )
          : null,
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
        style: TextStyle(
          color: MainColors.mainDark,
          fontSize: 16.spClamp,

          fontFamily: 'ScoreMedium',
        ),
      ),
      onTap: onTap,
    );
  }
}
