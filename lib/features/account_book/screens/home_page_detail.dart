import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/features/account_book/model/transaction_model.dart';

class HomePageDetail extends StatefulWidget {
  final TransactionModel transaction;

  const HomePageDetail({super.key, required this.transaction});

  @override
  State<HomePageDetail> createState() => _HomePageDetailState();
}

class _HomePageDetailState extends State<HomePageDetail> {
  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 22, 117, 189),
        title: const Text(
          '상세내역',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text("수정")),
              PopupMenuItem(value: 'delete', child: Text("삭제")),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Text("날짜: ${DateFormat('yyyy-MM-dd HH:mm').format(tx.date)}"),
          Text("내역: ${tx.title}"),
          Text(
            "수입: ${tx.type != 'expense' ? NumberFormat('#,###').format(tx.amount) : '0'}원",
          ),
          Text(
            "지출: ${tx.type == 'expense' ? NumberFormat('#,###').format(tx.amount) : '0'}원",
          ),
          Text("결제수단: ${tx.paymentMethod == 1 ? '현금' : '카드'}"),
          Text("메모: ${tx.memo}"),
        ],
      ),
    );
  }
}
