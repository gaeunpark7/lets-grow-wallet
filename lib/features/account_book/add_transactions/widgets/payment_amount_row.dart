import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/widgets/single_button.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class PaymentAmountRow extends StatelessWidget {
  final int selectedPayType;
  final void Function(int) onPayTypeChanged;
  final TextEditingController amountController;
  final String Function(String) formatAmount;

  const PaymentAmountRow({
    super.key,
    required this.selectedPayType,
    required this.onPayTypeChanged,
    required this.amountController,
    required this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SingleButton(
          text: "카드",
          selected: selectedPayType == 0,
          onTap: () => onPayTypeChanged(0),
        ),
        SizedBox(width: 5.w),
        SingleButton(
          text: "현금",
          selected: selectedPayType == 1,
          onTap: () => onPayTypeChanged(1),
        ),
        SizedBox(width: 10.w),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 38.h,
            child: TextFormField(
              style: TextStyle(color: MainColors.mainDark),
              controller: amountController,
              keyboardType: TextInputType.number,
              maxLength: 12,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                hintText: "금액",
                hintStyle: TextStyle(
                  color: MainColors.mainDark.withOpacity(0.6),
                ),
                isDense: true,
                counterText: "",
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8.h,
                  horizontal: 12.w,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: MainColors.mainDark, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: MainColors.mainDark, width: 2),
                ),
              ),
              onChanged: (value) {
                final formatted = formatAmount(value.replaceAll(',', ''));
                if (formatted != value) {
                  amountController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
