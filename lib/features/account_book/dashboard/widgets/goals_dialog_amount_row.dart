import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class GoalsDialogAmountRow extends StatelessWidget {
  const GoalsDialogAmountRow({
    super.key,
    required this.textController,
    required this.text,
    required this.hintText,
    this.isSelected = false,
    this.enabled = true,
    required this.onPressed,
  });
  final TextEditingController textController;
  final String text;
  final String hintText;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: isSelected
                ? MainColors.mainLight
                : MainColors.main,
            foregroundColor: isSelected ? Colors.white : MainColors.mainDark,
            disabledBackgroundColor: MainColors.main,
            disabledForegroundColor: MainColors.mainDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            fixedSize: Size(
              MediaQuery.of(context).size.width * 0.20,
              45.hClamp,
            ),
          ),
          onPressed: enabled ? onPressed : null,
          child: Text(
            text,
            style: TextStyle(fontSize: 16.spClamp, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 10.wClamp),
        Expanded(
          child: SizedBox(
            height: 45,
            child: TextField(
              controller: textController,
              enabled: enabled && isSelected,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 가능
                LengthLimitingTextInputFormatter(9), // 최대 9자리 제한
                ThousandsSeparatorInputFormatter(), // 천 단위 구분 추가
              ],
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: MainColors.mainLight),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8.hClamp,
                  horizontal: 12.wClamp,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: MainColors.mainLight, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: MainColors.mainLight, width: 1),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(',', ''); // 기존 , 제거

    // 빈 문자열 처리
    if (text.isEmpty) {
      return TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final number = int.tryParse(text); // 숫자로 변환

    if (number == null) {
      return oldValue; // 숫자가 아니면 기존 값 유지
    }

    final formattedText = NumberFormat('#,###').format(number); // 천 단위 구분
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
