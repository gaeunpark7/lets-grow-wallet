import 'package:flutter/material.dart';

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
                  const SizedBox(height: 8),
                  const Text(
                    "나중에 언제든지 변경할 수 있습니다.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  const Icon(
                    Icons.account_circle,
                    size: 120,
                    color: _mainColor,
                  ),
                  const SizedBox(height: 24),
                  _buildNicknameField(),
                  const SizedBox(height: 24),
                  _buildConfirmButton(context),
                  const SizedBox(height: 24),
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
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "닉네임",
        // counterText: "",
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
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: _mainColor,
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${_nicknameController.text}님 만나서 반가워요!")),
            );
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
