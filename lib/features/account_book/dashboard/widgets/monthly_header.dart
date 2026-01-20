import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/goals_dialog.dart';
import 'package:lets_grow_wallet/features/account_book/services/goal_service.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MonthlyHeader extends StatefulWidget {
  const MonthlyHeader({super.key, required this.month});

  final DateTime month;

  @override
  State<MonthlyHeader> createState() => _MonthlyHeaderState();
}

class _MonthlyHeaderState extends State<MonthlyHeader> {
  var goalController = TextEditingController();
  var expenseController = TextEditingController();
  var incomeController = TextEditingController();
  int selectedButton = 0; //기본 0, 눌리면 1
  String? goalTitle; // 목표 제목 저장
  late GoalService _goalService;

  @override
  void initState() {
    super.initState();
    _goalService = GoalService(Supabase.instance.client);
    _loadGoalTitle(); // 목표 제목 로드
  }

  @override
  void didUpdateWidget(covariant MonthlyHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month.year != widget.month.year ||
        oldWidget.month.month != widget.month.month) {
      _loadGoalTitle();
    }
  }

  Future<void> _loadGoalTitle() async {
    final month =
        "${widget.month.year}-${widget.month.month.toString().padLeft(2, '0')}";
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      showAppSnackBar('사용자 인증이 필요합니다.');
      return;
    }

    try {
      final title = await _goalService.getGoalTitle(userId, month);
      print('불러온 목표 제목: $title');

      setState(() {
        goalTitle = title; // 목표 제목 설정
      });
    } catch (e) {
      print('오류 발생: $e');
      showAppSnackBar('목표를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  @override
  void dispose() {
    goalController.dispose();
    expenseController.dispose();
    incomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // 반응형 너비
    final monthString =
        "${widget.month.year}-${widget.month.month.toString().padLeft(2, '0')}";
    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),

          Text(
            goalTitle ?? "이번달의 목표는?",
            style: TextStyle(
              color: MainColors.mainDark,
              fontSize: screenWidth * 0.06, // 반응형 폰트
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => GoalDialog(
                  goalController: goalController,
                  expenseController: expenseController,
                  incomeController: incomeController,
                  selectedButton: selectedButton,
                  month: monthString,
                  onButtonSelected: (int index) {
                    setState(() {
                      selectedButton = index;
                    });
                  },
                ),
              ).then((_) => _loadGoalTitle()); // 다이얼로그 닫힌 후 목표 제목 다시 로드
            },
            child: Icon(Icons.edit_square, size: 30, color: MainColors.point),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
