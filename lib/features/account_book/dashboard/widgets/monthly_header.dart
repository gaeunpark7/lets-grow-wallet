import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/features/account_book/dashboard/widgets/goals_dialog.dart';
import 'package:lets_grow_wallet/features/account_book/services/goal_service.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/kst_time.dart';
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
      if (mounted) {
        showAppSnackBar('사용자 인증이 필요합니다. 다시 로그인 해주세요.');
      }
      return;
    }

    try {
      final title = await _goalService.getGoalTitle(userId, month);
      print('불러온 목표 제목: $title');

      if (!mounted) return;
      setState(() {
        goalTitle = title; // 목표 제목 설정
      });
    } catch (e) {
      print('오류 발생: $e');
      if (mounted) {
        showAppSnackBar('목표를 불러오는 중 오류가 발생했습니다.');
      }
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

    final now = nowKst();
    final currentMonth = DateTime(now.year, now.month, 1);
    final selectedMonth = DateTime(widget.month.year, widget.month.month, 1);
    final isCurrentMonth = selectedMonth == currentMonth;
    final hasGoalTitle = (goalTitle?.trim().isNotEmpty ?? false);

    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            goalTitle ?? "이번달의 목표는?",
            style: TextStyle(
              color: MainColors.mainDark,
              fontSize: screenWidth * 0.06, // 반응형 폰트
              fontWeight: FontWeight.w900,
            ),
          ),

          Align(
            alignment: AlignmentGeometry.xy(0.8, 0),
            child: GestureDetector(
              onTap: () {
                if (!isCurrentMonth) {
                  showAppSnackBar('이번 달의 목표만 설정 가능합니다.');
                  return;
                }
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
                ).then((_) {
                  if (!mounted) return;
                  _loadGoalTitle();
                }); // 다이얼로그 닫힌 후 목표 제목 다시 로드
              },
              child: Image.asset(
                hasGoalTitle
                    ? 'assets/icons/edit2_icon.png'
                    : 'assets/icons/edit1_icon.png',
                width: screenWidth * 0.07,
                height: screenWidth * 0.07,
                // color: isCurrentMonth
                //     ? MainColors.point
                //     : MainColors.mainDark.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
