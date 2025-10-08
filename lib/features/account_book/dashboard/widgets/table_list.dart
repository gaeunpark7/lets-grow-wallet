import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/screens/home_page_detail.dart';
import 'package:lets_grow_wallet/features/account_book/model/category_model.dart';
import 'package:lets_grow_wallet/features/account_book/model/transaction_model.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class TableList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final List<Category> categories;
  // int transactionIndex;

  const TableList({
    super.key,
    required this.transactions,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length + 15,
      itemBuilder: (context, index) {
        if (index < transactions.length) {
          // 데이터가 있는 경우
          final tx = transactions[index];
          final isExpense = tx.type == 'expense';
          final isCash = tx.paymentMethod == 1;
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
                  _buildCell(DateFormat('d').format(tx.date)),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => HomePageDetail(transaction: tx),
                        ),
                      );
                    },
                    child: _buildCell(tx.title),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      isExpense
                          ? "-${NumberFormat('#,###').format(tx.amount)}"
                          : "+${NumberFormat('#,###').format(tx.amount)}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isExpense
                            ? MainColors.expense
                            : MainColors.income,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildCell(tx.paymentMethod == 0 ? "O" : " "),
                  _buildCell(tx.paymentMethod == 1 ? "O" : " "),
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
                  _buildCell(""),
                  _buildCell(""),
                  _buildCell(""),
                  _buildCell(""),
                  _buildCell(""),
                ],
              ),
            ],
          );
        }
      },
    );
  }
}

Widget _buildCell(String text) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1, // 텍스트 줄 제한
      overflow: TextOverflow.ellipsis, // 줄바꿈 방지
      style: TextStyle(color: MainColors.mainDark),
    ),
  );
}
