import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/user/model/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lets_grow_wallet/features/user/services/user_profile_service.dart';

class MyPageUserProfilePage extends StatefulWidget {
  const MyPageUserProfilePage({super.key, required this.userProfile});

  final UserProfileModel? userProfile;

  @override
  State<MyPageUserProfilePage> createState() => _MyPageUserProfileState();
}

class _MyPageUserProfileState extends State<MyPageUserProfilePage> {
  final nicknameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final _userProfileService = UserProfileService();

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveNickname() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      await _userProfileService.updateNickname(
        user.id,
        nicknameController.text,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("닉네임이 변경되었습니다.")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("닉네임 변경 실패: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[200],
          child: Icon(Icons.person, size: 50),
        ),
        const SizedBox(width: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.userProfile!.nickname,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 5),
                GestureDetector(
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (ctx) => _buildDialog(),
                    );
                  },
                  child: const Icon(Icons.settings),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.userProfile!.email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDialog() => Dialog(
    backgroundColor: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "닉네임 변경",
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Text("새로운 닉네임을 입력하세요", style: TextStyle(fontSize: 15)),
            TextFormField(
              controller: nicknameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 0.1),
                ),
                hintText: "새로운 닉네임을 입력하세요.",
                filled: true,
                fillColor: Color.fromARGB(255, 251, 251, 251),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              maxLength: 7,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "닉네임을 입력하세요";
                } else if (value.length < 2) {
                  return "닉네임은 2자 이상이어야 합니다.";
                } else if (value.length > 7) {
                  return "닉네임은 7자 이하이어야 합니다.";
                } else if (!RegExp(r'^[a-zA-Z0-9가-힣]+$').hasMatch(value)) {
                  return "닉네임은 한글, 영어, 숫자만 사용할 수 있습니다.";
                }

                return null;
              },
            ),
            // const SizedBox(height: 16),
            Text("(닉네임은 7자 이하 입력 가능)"),
            Text("변경 후 7일 후에 재변경 가능합니다."),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  backColor: const Color.fromARGB(255, 219, 219, 219),
                  textColor: Colors.black,
                  ontap: Navigator.of(context).pop,
                  text: "취소",
                ),
                _buildButton(
                  backColor: Colors.black,
                  textColor: Colors.white,
                  ontap: () {
                    if (formKey.currentState!.validate()) {
                      _saveNickname();
                    }
                  },
                  text: "확인",
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _buildButton extends StatelessWidget {
  _buildButton({
    required this.backColor,
    required this.textColor,
    required this.ontap,
    required this.text,
  });

  Color backColor;
  Color textColor;
  VoidCallback ontap;
  String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide.none,
        ),
        backgroundColor: backColor,
        foregroundColor: textColor,
        fixedSize: Size(MediaQuery.of(context).size.width * 0.3, 20),
        // elevation: 0,
      ),
      onPressed: ontap,
      child: Text(text),
    );
  }
}
