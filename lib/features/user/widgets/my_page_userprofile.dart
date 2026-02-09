import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/active_character_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/user_notifier.dart';
import 'package:lets_grow_wallet/features/user/model/user_profile_model.dart';
import 'package:lets_grow_wallet/utils/character_interation_enum.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/friendly_error_message.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class MyPageUserProfilePage extends ConsumerStatefulWidget {
  const MyPageUserProfilePage({super.key, required this.userProfile});

  final UserProfileModel userProfile;

  @override
  ConsumerState<MyPageUserProfilePage> createState() =>
      _MyPageUserProfileState();
}

class _MyPageUserProfileState extends ConsumerState<MyPageUserProfilePage> {
  final nicknameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Widget _buildProfileAvatarContainer({required Widget child}) {
    final size = 80.rClamp;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: Center(child: child),
    );
  }

  Widget _buildProfileAvatarFallbackIcon() {
    return _buildProfileAvatarContainer(
      child: Icon(Icons.person, size: 52.rClamp, color: MainColors.mainLight),
    );
  }

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveNickname(BuildContext dialogContext) async {
    try {
      await ref
          .read(userProfileNotifierProvider.notifier)
          .updateNickname(nicknameController.text);
      if (!mounted) return;
      Navigator.of(dialogContext).pop();
      showAppSnackBar('닉네임이 변경되었습니다.');
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(FriendlyErrorMessage.of(e));
      print('닉네임 저장 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCharacterAsync = ref.watch(activeCharacterNotifierProvider);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.wClamp, vertical: 16.hClamp),
      padding: EdgeInsets.all(16.h),
      color: MainColors.main,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () async {
                nicknameController.text = widget.userProfile.nickname;
                await showDialog(
                  context: context,
                  builder: (ctx) => _buildDialog(ctx),
                );
              },
              child: CircleAvatar(
                radius: 15.rClamp,
                backgroundColor: MainColors.mainLight,
                child: Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  activeCharacterAsync.when(
                    loading: () => _buildProfileAvatarContainer(
                      child: SizedBox(
                        width: 20.rClamp,
                        height: 20.rClamp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: MainColors.mainLight,
                        ),
                      ),
                    ),
                    error: (_, __) => _buildProfileAvatarFallbackIcon(),
                    data: (activeCharacter) {
                      final imageUrl =
                          activeCharacter?.imageUrlForEmotion(Emotion.basic) ??
                          '';

                      final isBanHam =
                          (activeCharacter?.characterName.trim() ?? '') == '반햄';
                      final shouldShift =
                          isBanHam && (activeCharacter?.stage != Stage.egg);

                      if (imageUrl.isEmpty)
                        return _buildProfileAvatarFallbackIcon();

                      final image = Image.network(
                        imageUrl,
                        width: 80.rClamp,
                        height: 80.rClamp,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 52.rClamp,
                            color: MainColors.mainLight,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            width: 20.rClamp,
                            height: 20.rClamp,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: MainColors.mainLight,
                            ),
                          );
                        },
                      );

                      return _buildProfileAvatarContainer(
                        child: ClipOval(
                          child: Padding(
                            padding: EdgeInsets.all(6.rClamp),
                            child: shouldShift
                                ? Transform.translate(
                                    offset: Offset(-2.wClamp, 0),
                                    child: image,
                                  )
                                : image,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 15.wClamp),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userProfile.nickname,
                          style: TextStyle(
                            fontSize: 22.spClamp,
                            color: MainColors.mainDark,
                          ),
                        ),
                        SizedBox(height: 8.hClamp),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(8.hClamp),
                          color: Colors.white,
                          child: Center(
                            child: Text(
                              widget.userProfile.email,
                              style: TextStyle(
                                fontSize: 16.spClamp,
                                color: MainColors.mainDark,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDialog(BuildContext dialogContext) {
    final media = MediaQuery.of(context);
    final dialogWidth = media.size.width * 0.75;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.rClamp),
      ),
      child: SizedBox(
        width: dialogWidth,
        child: Padding(
          padding: EdgeInsets.all(12.rClamp),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "닉네임 변경",
                  style: TextStyle(
                    fontSize: 23.spClamp,
                    fontWeight: FontWeight.bold,
                    color: MainColors.mainDark,
                  ),
                ),
                SizedBox(height: 16.hClamp),
                TextFormField(
                  controller: nicknameController,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 70, 81, 100),
                  ),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 0.1),
                    ),
                    hintText: "새로운 닉네임을 입력하세요.",
                    hintStyle: TextStyle(
                      color: MainColors.mainDark.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 251, 251, 251),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MainColors.mainDark,
                        width: 2,
                      ),
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
                Text(
                  "(닉네임은 7자 이하 입력 가능)",
                  style: TextStyle(color: MainColors.mainDark),
                ),
                Text(
                  "변경 후 7일 후에 재변경 가능합니다.",
                  style: TextStyle(color: MainColors.mainDark),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton(
                      backColor: MainColors.main,
                      textColor: MainColors.mainDark,
                      ontap: () => Navigator.of(dialogContext).pop(),
                      text: "취소",
                    ),
                    _buildButton(
                      backColor: MainColors.mainLight,
                      textColor: Colors.white,
                      ontap: () {
                        if (formKey.currentState!.validate()) {
                          _saveNickname(dialogContext);
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
      ),
    );
  }
}

class _buildButton extends StatelessWidget {
  const _buildButton({
    required this.backColor,
    required this.textColor,
    required this.ontap,
    required this.text,
  });

  final Color backColor;
  final Color textColor;
  final VoidCallback ontap;
  final String text;

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
        fixedSize: Size(MediaQuery.of(context).size.width * 0.3, 20.hClamp),
        elevation: 0,
      ),
      onPressed: ontap,
      child: Text(text),
    );
  }
}
