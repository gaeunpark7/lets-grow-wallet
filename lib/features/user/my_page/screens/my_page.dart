import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/user/my_page/screens/my_page_userprofile.dart';
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
        appBar: AppBar(
          title: const Text(
            "마이페이지",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : userProfile == null
            ? const Center(child: Text("유저 정보를 불러올 수 없습니다."))
            : Column(
                children: [
                  const SizedBox(height: 32),
                  MyPageUserProfilePage(userProfile: userProfile),
                  const SizedBox(height: 32),
                  ListTile(
                    leading: const Icon(Icons.workspace_premium_outlined),
                    title: const Text("프리미엄"),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.notification_important_outlined),
                    title: const Text("공지사항"),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.feedback_outlined),
                    title: const Text("오류문의"),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text("앱 정보"),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: "레츠고 가계부",
                        applicationVersion: "1.0.0",
                        applicationLegalese: "© 2024 LetsGrow",
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("로그아웃"),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
      ),
    );
  }
}
