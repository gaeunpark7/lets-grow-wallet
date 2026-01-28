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
import 'package:lets_grow_wallet/utils/friendly_error_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  BannerAd? _bannerAd;
  bool _isLoggingOut = false;
  bool _redirectedToLogin = false;

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

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileNotifierProvider);
    final authUserIdAsync = ref.watch(authUserIdProvider);

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
        body: Column(
          children: [
            if (_isLoggingOut) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: AbsorbPointer(
                absorbing: _isLoggingOut,
                child: userProfileAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) {
                    // 로그아웃 중에는(토큰 만료 등으로) 에러가 잠깐 뜰 수 있어서 UI를 숨김
                    if (_isLoggingOut || _redirectedToLogin) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _MyPageErrorView(
                      message: FriendlyErrorMessage.of(e),
                      onRetry: () => ref
                          .read(userProfileNotifierProvider.notifier)
                          .refresh(),
                      onLogout: _logout,
                    );
                  },
                  data: (userProfile) {
                    if (userProfile == null) {
                      // 로그인 정보가 없거나, 아직 provider가 갱신 중인 상태
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        const SizedBox(height: 32),
                        MyPageUserProfilePage(userProfile: userProfile),
                        const SizedBox(height: 32),
                        const Divider(
                          color: MainColors.mainDark,
                          thickness: 0.5,
                        ),
                        _buildListTile(
                          icon: Icons.workspace_premium_outlined,
                          text: "프리미엄",
                        ),
                        const Divider(
                          color: MainColors.mainDark,
                          thickness: 0.5,
                        ),
                        _buildListTile(
                          icon: Icons.privacy_tip_outlined,
                          text: "개인정보 처리방침",
                          onTap: () {
                            context.push(Routes.privacyPolicy);
                          },
                        ),
                        const Divider(
                          color: MainColors.mainDark,
                          thickness: 0.5,
                        ),
                        _buildListTile(
                          icon: Icons.feedback_outlined,
                          text: "오류문의",
                        ),
                        const Divider(
                          color: MainColors.mainDark,
                          thickness: 0.5,
                        ),
                        _buildListTile(
                          icon: Icons.logout,
                          text: _isLoggingOut ? "로그아웃 중..." : "로그아웃",
                          onTap: _isLoggingOut ? null : _logout,
                        ),
                        const Divider(
                          color: MainColors.mainDark,
                          thickness: 0.5,
                        ),
                        _buildListTile(
                          icon: Icons.delete_forever_outlined,
                          text: "회원탈퇴",
                          onTap: _isLoggingOut
                              ? null
                              : () {
                                  context.push(Routes.deleteUser);
                                },
                        ),
                        const Divider(
                          color: MainColors.mainDark,
                          thickness: 0.5,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
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

class _MyPageErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onLogout;

  const _MyPageErrorView({
    required this.message,
    required this.onRetry,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: MainColors.point, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: MainColors.mainDark),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MainColors.mainLight,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('다시 시도'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: onLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MainColors.mainDark,
                    side: const BorderSide(color: MainColors.mainDark),
                  ),
                  child: const Text('로그아웃'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
