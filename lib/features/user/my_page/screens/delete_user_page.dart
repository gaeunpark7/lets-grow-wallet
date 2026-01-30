import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/features/user/widgets/delete_user_dialog.dart';
import 'package:lets_grow_wallet/features/user/widgets/delete_user_page_text.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/friendly_error_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteUserPage extends StatefulWidget {
  const DeleteUserPage({super.key});

  @override
  State<DeleteUserPage> createState() => _DeleteUserPageState();
}

class _DeleteUserPageState extends State<DeleteUserPage> {
  bool _agreedToDelete = false;
  bool _isDeleting = false;

  void _toggleAgree([bool? value]) {
    setState(() {
      _agreedToDelete = value ?? !_agreedToDelete;
    });
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return DeleteUserDialog();
      },
    );

    if (shouldDelete == true && context.mounted) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    if (_isDeleting) return;
    final supabase = Supabase.instance.client;
    try {
      setState(() {
        _isDeleting = true;
      });
      await supabase.rpc('delete_user_account');
      await supabase.auth.signOut();
      showAppSnackBar('탈퇴가 완료되었습니다.\n그동안 이용해주셔서 감사합니다.');
      if (!mounted) return;
      context.go(Routes.login);
    } catch (e) {
      print('회원탈퇴 오류:$e');
      final friendly = FriendlyErrorMessage.resolve(e);
      showAppSnackBar(friendly.message);

      // 인증 문제가 섞인 경우 로그인으로 복귀
      if (friendly.type == FriendlyErrorType.auth && mounted) {
        context.go(Routes.login);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          '회원탈퇴',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          if (_isDeleting) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: AbsorbPointer(
              absorbing: _isDeleting,
              child: SingleChildScrollView(
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 180),
                  child: DeleteUserPageText(),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              // decoration: const BoxDecoration(
              //   color: Colors.white,
              //   border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
              // ),
              child: AbsorbPointer(
                absorbing: _isDeleting,
                child: _DeleteUserFooter(
                  agreed: _agreedToDelete,
                  onAgreeChanged: _toggleAgree,
                  onCancel: () => Navigator.pop(context, false),
                  onDelete: _confirmDelete,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteUserFooter extends StatelessWidget {
  final bool agreed;
  final ValueChanged<bool?> onAgreeChanged;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const _DeleteUserFooter({
    required this.agreed,
    required this.onAgreeChanged,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: InkWell(
            onTap: () => onAgreeChanged(!agreed),
            child: Row(
              children: [
                Checkbox(
                  value: agreed,
                  activeColor: MainColors.mainLight,
                  onChanged: onAgreeChanged,
                  visualDensity: VisualDensity.compact,
                  // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Expanded(
                  child: Text(
                    "유의사항을 모두 확인하였으며, 회원 탈퇴에 동의합니다.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _ActionButton(
              backColor: const Color.fromARGB(255, 245, 245, 245),
              textColor: Colors.grey,
              text: '취소',
              onTap: onCancel,
            ),
            const SizedBox(width: 12),
            _ActionButton(
              backColor: agreed
                  ? MainColors.mainLight
                  : MainColors.mainLight.withOpacity(0.35),
              textColor: Colors.white,
              text: '회원탈퇴',
              onTap: agreed ? onDelete : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Color backColor;
  final Color textColor;
  final String text;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.backColor,
    required this.textColor,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(45),
          backgroundColor: backColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
