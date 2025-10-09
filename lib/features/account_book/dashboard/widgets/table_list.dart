import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/screens/home_page_detail.dart';
import 'package:lets_grow_wallet/features/account_book/model/category_model.dart';
import 'package:lets_grow_wallet/features/account_book/model/transaction_model.dart';
import 'package:lets_grow_wallet/features/account_book/services/transaction_service.dart';
import 'package:lets_grow_wallet/utils/category_utils.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class TableList extends StatelessWidget {
  final transactionService = TransactionService();
  final List<TransactionModel> transactions;
  // final List<Category> categories;

  TableList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length + 15,
      itemBuilder: (context, index) {
        if (index < transactions.length) {
          // 데이터가 있는 경우
          final tx = transactions[index];
          final isExpense = tx.type == 'expense';
          final categoryIcon = getCategoryIcon(tx.categoryName.toString());
          // final isCash = tx.paymentMethod == 1;

          return Table(
            border: TableBorder(
              bottom: BorderSide(color: MainColors.point, width: 1),
              verticalInside: BorderSide(color: MainColors.point, width: 1),
            ),
            columnWidths: const {
              0: FlexColumnWidth(1), // 날짜
              1: FlexColumnWidth(3), // 내역
              2: FlexColumnWidth(3), // 지출
              3: FlexColumnWidth(1), // 카드
              4: FlexColumnWidth(1), // 현금
            },
            children: [
              TableRow(
                children: [
                  _CellWidget(text: DateFormat('d').format(tx.date)),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => HomePageDetail(transaction: tx),
                        ),
                      );
                    },
                    child: _CellWidget(
                      text: tx.title,
                      icon: categoryIcon,
                      alignment: MainAxisAlignment.spaceBetween,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      isExpense
                          ? "-${NumberFormat('#,###').format(tx.amount)}"
                          : "+${NumberFormat('#,###').format(tx.amount)}",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: isExpense
                            ? MainColors.expense
                            : MainColors.income,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _CellWidget(
                    text: "",
                    icon: tx.paymentMethod == 0
                        ? Icons.check
                        : null, // 카드일 때 체크 아이콘
                  ),
                  _CellWidget(
                    text: "",
                    icon: tx.paymentMethod == 1
                        ? Icons.check
                        : null, // 현금일 때 체크 아이콘
                  ),
                ],
              ),
            ],
          );
        } else {
          // 데이터가 없는 경우 빈 행 렌더링
          return Table(
            border: TableBorder(
              bottom: BorderSide(color: MainColors.point, width: 1),
              verticalInside: BorderSide(color: MainColors.point, width: 1),
            ),
            columnWidths: const {
              0: FlexColumnWidth(1), // 날짜
              1: FlexColumnWidth(3), // 내역
              2: FlexColumnWidth(3), // 지출
              3: FlexColumnWidth(1), // 카드
              4: FlexColumnWidth(1), // 현금
            },
            children: [
              TableRow(
                children: [
                  _CellWidget(text: ""),
                  _CellWidget(text: ""),
                  _CellWidget(text: ""),
                  _CellWidget(text: ""),
                  _CellWidget(text: ""),
                ],
              ),
            ],
          );
        }
      },
    );
  }
}

class _CellWidget extends StatelessWidget {
  final String text;
  final IconData? icon;
  final MainAxisAlignment alignment;

  const _CellWidget({
    super.key,
    required this.text,
    this.icon,
    this.alignment = MainAxisAlignment.center,
  });
  @override
  Widget build(BuildContext context) {
    Widget? leadingIcon;
    if (icon != null) {
      if (icon == Icons.check) {
        leadingIcon = Icon(icon, color: MainColors.mainDark, size: 16);
      } else {
        leadingIcon = CircleAvatar(
          radius: 12,
          backgroundColor: MainColors.mainLight,
          child: Icon(icon, color: MainColors.main, size: 16),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          if (leadingIcon != null) leadingIcon,
          if (icon != null && icon != Icons.check) const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: MainColors.mainDark),
            ),
          ),
        ],
      ),
    );
  }
}
