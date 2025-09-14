import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/user/widgets/my_page_userprofile.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lets_grow_wallet/features/user/auth/screens/login_page.dart';
import 'package:lets_grow_wallet/features/user/auth/screens/profile_setting_page.dart';
import 'package:lets_grow_wallet/features/user/services/user_profile_service.dart';
import 'package:lets_grow_wallet/features/user/model/user_profile_model.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  UserProfileModel? userProfile;
  bool isLoading = true;
  final _userProfileService = UserProfileService();

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final profile = await _userProfileService.getUserProfile(user.id);
    setState(() {
      userProfile = profile;
      isLoading = false;
    });
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (ctx) => LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: MainColors.mainLight),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : userProfile == null
            ? const Center(child: Text("유저 정보를 불러올 수 없습니다."))
            : Column(
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                  ),
                  const SizedBox(height: 32),
                  MyPageUserProfilePage(userProfile: userProfile),
                  const SizedBox(height: 32),
                  Divider(color: MainColors.mainDark, thickness: 0.5),
                  _buildListTile(
                    icon: Icons.workspace_premium_outlined,
                    text: "프리미엄",
                  ),
                  const Divider(color: MainColors.mainDark, thickness: 0.5),
                  _buildListTile(icon: Icons.notifications, text: "공지사항"),
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
              ),
      ),
    );
  }
}

class _buildListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;

  const _buildListTile({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

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
