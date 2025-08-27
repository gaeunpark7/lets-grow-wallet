import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lets_grow_wallet/features/auth/screens/login_page.dart';
import 'package:lets_grow_wallet/features/auth/screens/profile_setting_page.dart';
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProfile!.nickname,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userProfile!.email,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text("프로필 수정"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => ProfileSettingPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("로그아웃"),
                    onTap: _logout,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text("앱 정보"),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: "레츠고 가계부",
                        applicationVersion: "1.0.0",
                        applicationLegalese: "© 2024 LetsGrow",
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
