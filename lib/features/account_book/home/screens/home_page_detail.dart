import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/screens/edit_expense_page.dart';
import 'package:lets_grow_wallet/features/account_book/add_transactions/screens/edit_income_page.dart';
import 'package:lets_grow_wallet/features/account_book/main/main_page.dart';
import 'package:lets_grow_wallet/features/account_book/model/transaction_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePageDetail extends StatefulWidget {
  final TransactionModel transaction;

  const HomePageDetail({super.key, required this.transaction});

  @override
  State<HomePageDetail> createState() => _HomePageDetailState();
}

class _HomePageDetailState extends State<HomePageDetail> {
  //내역 삭제
  Future<void> deleteTransaction() async {
    final supabase = Supabase.instance.client;
    await supabase
        .from('transactions')
        .delete()
        .eq('id', widget.transaction.id);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("삭제 되었습니다.")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (ctx) => MainPage()),
      );
    }
  }

  //수정 페이지 이동
  Future<void> goToEditPage() async {
    if (widget.transaction.type == 'expense') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EditExpensePage(transaction: widget.transaction),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditIncomePage(transaction: widget.transaction),
        ),
      );
    }
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("삭제 확인"),
          content: Text("정말로 이 내역을 삭제하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                deleteTransaction();
                Navigator.pop(context);
              },
              child: Text("삭제"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 22, 117, 189),
        title: Text(
          '상세내역',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) {
              if (value == 'edit') {
                goToEditPage();
              } else if (value == 'delete') {
                showDeleteDialog();
              } else {}
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text('수정')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'delete', child: Text('삭제')),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("날짜: ${DateFormat('yyyy-MM-dd').format(tx.date)}"),
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
      ),
    );
  }
}
