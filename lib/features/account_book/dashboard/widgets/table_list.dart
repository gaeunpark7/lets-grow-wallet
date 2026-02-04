import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/screens/home_page_detail.dart';
import 'package:lets_grow_wallet/features/account_book/model/transaction_model.dart';
import 'package:lets_grow_wallet/features/account_book/services/transaction_service.dart';
import 'package:lets_grow_wallet/utils/category_utils.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class TableList extends StatelessWidget {
  final transactionService = TransactionService();
  final List<TransactionModel> transactions;

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

          return Table(
            border: TableBorder(
              bottom: BorderSide(color: MainColors.point, width: 1),
              verticalInside: BorderSide(color: MainColors.point, width: 1),
            ),
            columnWidths: const {
              0: FlexColumnWidth(1), // 날짜
              1: FlexColumnWidth(3.5), // 내역
              2: FlexColumnWidth(2.5), // 지출
              3: FlexColumnWidth(1), // 카드
              4: FlexColumnWidth(1), // 현금
            },
            defaultVerticalAlignment:
                TableCellVerticalAlignment.middle, // 셀 높이 중앙 정렬
            children: [
              TableRow(
                children: [
                  //날짜 - 중앙정렬 문제 해결
                  _CellWidget(text: DateFormat('d').format(tx.date)),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => HomePageDetail(transaction: tx),
                      );
                    },
                    child: _CellWidget(
                      text: tx.title,
                      icon: categoryIcon,
                      alignment: MainAxisAlignment.spaceBetween,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 6.0.hClamp,
                      horizontal: 8.0.wClamp,
                    ),
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
                  _PaymentCellWidget(
                    icon: tx.paymentMethod == 0 ? Icons.check : null,
                  ), // 카드일 때 체크 아이콘
                  _PaymentCellWidget(
                    icon: tx.paymentMethod == 1 ? Icons.check : null,
                  ), // 현금일 때 체크 아이콘
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
              1: FlexColumnWidth(3.5), // 내역
              2: FlexColumnWidth(2.5), // 지출
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
      leadingIcon = CircleAvatar(
        radius: 10.0.rClamp,
        backgroundColor: MainColors.mainLight,
        child: Icon(icon, color: MainColors.main, size: 14.0.rClamp),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 6.0.hClamp,
        horizontal: 8.0.wClamp,
      ),
      child: Row(
        mainAxisAlignment: alignment,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leadingIcon != null) leadingIcon,
          if (icon != null) SizedBox(width: 3.wClamp),
          Flexible(
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

//카드, 현금 셀
class _PaymentCellWidget extends StatelessWidget {
  final IconData? icon;

  const _PaymentCellWidget({super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    Widget? leadingIcon;
    if (icon != null) {
      leadingIcon = Icon(icon, color: MainColors.mainDark, size: 14.0.rClamp);
    }
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 6.0.hClamp,
        horizontal: 8.0.wClamp,
      ),
      child: Center(child: leadingIcon),
    );
  }
}
