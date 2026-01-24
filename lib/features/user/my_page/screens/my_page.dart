import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/user_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/services/admob_service.dart';
import 'package:lets_grow_wallet/features/user/widgets/my_page_userprofile.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _createBannerAd();
  }

  void _createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdmobService.BannerAdUnitId!,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: AdmobService.bannerAdListener,
    )..load();
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        context.go(Routes.login);
      }
    } catch (e) {
      print('로그아웃 오류: $e');
      if (mounted) {
        showAppSnackBar('로그아웃 실패: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileNotifierProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: AppBar(
            backgroundColor: MainColors.mainLight,
            automaticallyImplyLeading: false,
          ),
        ),
        body: userProfileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('유저 정보를 불러올 수 없습니다. ($e)')),
          data: (userProfile) {
            if (userProfile == null) {
              return const Center(child: Text("유저 정보를 불러올 수 없습니다."));
            }

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 32),
                MyPageUserProfilePage(userProfile: userProfile),
                const SizedBox(height: 32),
                const Divider(color: MainColors.mainDark, thickness: 0.5),
                _buildListTile(
                  icon: Icons.workspace_premium_outlined,
                  text: "프리미엄",
                ),
                const Divider(color: MainColors.mainDark, thickness: 0.5),
                _buildListTile(icon: Icons.feedback_outlined, text: "오류문의"),
                const Divider(color: MainColors.mainDark, thickness: 0.5),
                _buildListTile(
                  icon: Icons.info_outline,
                  text: "앱 정보",
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "레츠고 가계부",
                      applicationVersion: "1.0.0",
                      applicationLegalese: "© 2025 LetsGrow",
                    );
                  },
                ),
                const Divider(color: MainColors.mainDark, thickness: 0.5),
                _buildListTile(
                  icon: Icons.logout,
                  text: "로그아웃",
                  onTap: _logout,
                ),
                const Divider(color: MainColors.mainDark, thickness: 0.5),
              ],
            );
          },
        ),
        bottomNavigationBar: Container(
          width: double.infinity,
          height: 60,
          alignment: Alignment.center,
          child: _bannerAd != null
              ? AdWidget(ad: _bannerAd!)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _buildListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;

  const _buildListTile({required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: MainColors.point, size: 28),
      trailing: Text(
        text,
        style: const TextStyle(color: MainColors.mainDark, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}
