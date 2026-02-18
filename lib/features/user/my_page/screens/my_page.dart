import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/user_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/services/admob_service.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_appbar_premium_dialog.dart';
import 'package:lets_grow_wallet/features/user/widgets/my_page_error.dart';
import 'package:lets_grow_wallet/features/user/widgets/my_page_userprofile.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/friendly_error_message.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  BannerAd? _bannerAd;
  ProviderSubscription<bool>? _premiumSubscription;
  bool _isLoggingOut = false;
  bool _redirectedToLogin = false;

  static final Uri _feedbackFormUri = Uri.parse('https://naver.me/Fz8de8YM');

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

  Future<void> _logout() async {
    try {
      if (mounted) {
        setState(() {
          _isLoggingOut = true;
        });
      }
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        _redirectedToLogin = true;
        context.go(Routes.login);
      }
    } catch (e) {
      print('로그아웃 오류: $e');
      if (mounted) {
        showAppSnackBar(FriendlyErrorMessage.of(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  Future<void> _openFeedbackForm() async {
    try {
      final ok = await launchUrl(
        _feedbackFormUri,
        mode: LaunchMode.externalApplication,
      );
      if (!ok) {
        showAppSnackBar('링크를 열 수 없습니다.');
      }
    } catch (e) {
      showAppSnackBar('링크를 여는 중 오류가 발생했습니다.');
      debugPrint('오류문의 폼 열기 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileNotifierProvider);
    final authUserIdAsync = ref.watch(authUserIdProvider);
    final isPremium = ref.watch(isPremiumProvider);

    // 로그아웃 상태면(혹은 로그아웃 완료 직후) 에러 UI 대신 로그인으로 이동
    authUserIdAsync.whenData((userId) {
      if (_redirectedToLogin) return;
      if (userId != null) return;
      _redirectedToLogin = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go(Routes.login);
      });
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(6.hClamp),
        child: AppBar(
          backgroundColor: MainColors.mainLight,
          automaticallyImplyLeading: false,
        ),
      ),
      body: Column(
        children: [
          if (_isLoggingOut) LinearProgressIndicator(minHeight: 2.hClamp),
          Expanded(
            child: AbsorbPointer(
              absorbing: _isLoggingOut,
              child: userProfileAsync.when(
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, _) {
                  //로그아웃 중 > 토근 완료로 인한 에러 발생시 에러뷰 대신
                  if (_isLoggingOut || _redirectedToLogin) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: MainColors.mainLight,
                      ),
                    );
                  }
                  return MyPageErrorView(
                    message: FriendlyErrorMessage.of(e),
                    onRetry: () => ref
                        .read(userProfileNotifierProvider.notifier)
                        .refresh(),
                    onLogout: _logout,
                  );
                },
                data: (userProfile) {
                  if (userProfile == null) {
                    // 로그인 정보가 없거나 아직 provider가 갱신 중인 상태
                    return const Center(
                      child: CircularProgressIndicator(
                        color: MainColors.mainLight,
                      ),
                    );
                  }

                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      SizedBox(height: 32.hClamp),
                      MyPageUserProfilePage(userProfile: userProfile),
                      SizedBox(height: 32.hClamp),
                      Divider(color: MainColors.mainDark, thickness: 0.5),
                      buildListTile(
                        icon: Icons.workspace_premium_outlined,
                        text: "프리미엄",
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (ctx) => ShopAppbarPremiumDialog(),
                          );
                        },
                      ),
                      Divider(color: MainColors.mainDark, thickness: 0.5),
                      buildListTile(
                        icon: Icons.privacy_tip_outlined,
                        text: "개인정보",
                        onTap: () {
                          context.push(
                            '${Routes.mypage}/${Routes.myPageUserSetting}',
                          );
                        },
                      ),
                      Divider(color: MainColors.mainDark, thickness: 0.5),
                      buildListTile(
                        icon: Icons.feedback_outlined,
                        text: "오류문의",
                        onTap: _openFeedbackForm,
                      ),
                      Divider(color: MainColors.mainDark, thickness: 0.5),
                      buildListTile(
                        icon: Icons.logout,
                        text: _isLoggingOut ? "로그아웃 중..." : "로그아웃",
                        onTap: _isLoggingOut ? null : _logout,
                      ),
                      Divider(color: MainColors.mainDark, thickness: 0.5),
                      // buildListTile(
                      //   icon: Icons.delete_forever_outlined,
                      //   text: "회원탈퇴",
                      //   onTap: _isLoggingOut
                      //       ? null
                      //       : () {
                      //           context.push(Routes.deleteUser);
                      //         },
                      // ),
                      // Divider(color: MainColors.mainDark, thickness: 0.5),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     showDialog(
                      //       context: context,
                      //       builder: (ctx) => MonthlyAllClearDialog(),
                      //     );
                      //   },
                      //   child: Text('테스트 다이얼로그'),
                      // ),
                    ],
                  );
                },
              ),
            ),
          ),

          if (!isPremium)
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                height: 60.hClamp,
                alignment: Alignment.center,
                child: _bannerAd != null
                    ? AdWidget(ad: _bannerAd!)
                    : const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }
}

class buildListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;

  const buildListTile({
    super.key,
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
