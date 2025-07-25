import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/transaction_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TransactionModel> todayTransactions = [];

  @override
  void initState() {
    super.initState();
    loadTodayTransactions();
  }

  Future<void> loadTodayTransactions() async {
    final supabase = Supabase.instance.client;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final response = await supabase
        .from('transactions')
        .select()
        .gte('date', start.toIso8601String())
        .lt('date', end.toIso8601String())
        .order('date', ascending: true);

    setState(() {
      todayTransactions = (response as List)
          .map((e) => TransactionModel.fromMap(e))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 22, 117, 189),
        title: const Text(
          '오늘의 소비',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: todayTransactions.length,
        itemBuilder: (context, idx) {
          final tx = todayTransactions[idx];
          final isExpense = tx.type == 'expense';
          final isCash = tx.paymentMethod == 1;
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("날짜: ${DateFormat('yyyy.MM.dd').format(tx.date)}"),
                        Text("내역: ${tx.title}"),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "수입: ${!isExpense ? NumberFormat('#,###').format(tx.amount) : '0'}원",
                        ),
                        Text(
                          "지출: ${isExpense ? NumberFormat('#,###').format(tx.amount) : '0'}원",
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("카드:"),
                            if (tx.paymentMethod == 0)
                              const Icon(
                                Icons.credit_card,
                                color: Colors.blue,
                                size: 20,
                              ),
                            Text("  현금:"),
                            if (tx.paymentMethod == 1)
                              const Icon(
                                Icons.check,
                                color: Colors.green,
                                size: 20,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 22, 117, 189),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: () {},
        child: const Icon(Icons.emoji_emotions, size: 30, color: Colors.white),
      ),
    );
  }
}
