import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSettingPage extends StatefulWidget {
  const ProfileSettingPage({super.key});

  @override
  State<ProfileSettingPage> createState() => _ProfileSettingPageState();
}

class _ProfileSettingPageState extends State<ProfileSettingPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const _mainColor = Color.fromARGB(255, 201, 138, 223);

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveUserProfile() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) {
        showAppSnackBar('유저 정보가 없습니다. 다시 로그인 해주세요.');
        context.go(Routes.login);
      }
      return;
    }
    try {
      await supabase
          .from('user')
          .update({'nickname': _nicknameController.text})
          .eq('id', user.id);

      if (mounted) {
        context.go(Routes.home);
      }
    } catch (e) {
      print('닉네임 저장 오류: $e');
      if (mounted) {
        showAppSnackBar('닉네임 저장에 실패하였습니다.\n다시 시도해주세요.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    "닉네임 설정",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "나중에 언제든지 변경할 수 있습니다.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.account_circle,
                    size: 120,
                    color: MainColors.mainLight,
                  ),
                  const SizedBox(height: 12),
                  _buildNicknameField(),
                  const SizedBox(height: 12),
                  _buildConfirmButton(context),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNicknameField() {
    return TextFormField(
      controller: _nicknameController,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: MainColors.mainDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: MainColors.mainDark, width: 2),
        ),
        hintText: '닉네임을 입력해주세요.',
        hintStyle: TextStyle(color: MainColors.mainDark.withOpacity(0.5)),
      ),

      maxLength: 7,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "닉네임을 입력해주세요.";
        } else if (value.length < 2) {
          return "닉네임은 2자 이상이어야 합니다.";
        } else if (value.length > 7) {
          return "닉네임은 7자 이하이어야 합니다.";
        } else if (!RegExp(r'^[a-zA-Z0-9가-힣]+$').hasMatch(value)) {
          return "닉네임은 한글, 영어, 숫자만 사용할 수 있습니다.";
        }
        return null;
      },
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          backgroundColor: MainColors.mainLight,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            showAppSnackBar('${_nicknameController.text}님 만나서 반가워요!');
            _saveUserProfile();
          }
        },
        child: const Text(
          "확인",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
