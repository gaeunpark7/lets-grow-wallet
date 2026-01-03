import 'package:flutter/material.dart';

class StatsAIMessage extends StatefulWidget {
  const StatsAIMessage({super.key});

  @override
  State<StatsAIMessage> createState() => _State();
}

class _State extends State<StatsAIMessage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey[200]),
      child: Center(
        child: Text(
          'AI가 분석한 통계 데이터입니다.',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
