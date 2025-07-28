import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/widgets/single_button.dart';

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
        SingleButton(
          text: "현금",
          selected: selectedPayType == 1,
          onTap: () => onPayTypeChanged(1),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 38,
            child: TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              maxLength: 12,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "금액",
                isDense: true,
                counterText: "",
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
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
