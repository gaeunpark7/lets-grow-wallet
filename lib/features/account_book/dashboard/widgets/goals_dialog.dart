import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class GoalsDialog extends StatelessWidget {
  const GoalsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    var goalController = TextEditingController();
    var incomeController = TextEditingController();
    var expenseController = TextEditingController();
    return  Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: goalController,
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: MainColors.mainLight,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: MainColors.mainLight,
                                    width: 2,
                                  ),
                                ),
                                labelText: " 이번달의 목표는?",
                                labelStyle: TextStyle(
                                  color: MainColors.mainDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                suffixIcon: Icon(
                                  Icons.mood_outlined,
                                  color: MainColors.mainLight,
                                  size: 30,
                                ),
                                contentPadding: EdgeInsets.only(bottom: 4),
                              ),
                            ),

                            SizedBox(height: 12),
                            _buildGoalsAmount(
                              textController: expenseController,
                              text: "지출",
                              hintText: "목표 금액을 입력하세요.",
                              isSelected: selectedButton == 1,
                              onPressed: () {
                                setState(() {
                                  selectedButton = 1;
                                });
                              },
                            ),
                            SizedBox(height: 12),
                            _buildGoalsAmount(
                              textController: incomeController,
                              text: "수입",
                              hintText: "목표 금액을 입력하세요",
                              isSelected: selectedButton == 0, // 상태 전달
                              onPressed: () {
                                setState(() {
                                  selectedButton = 0; // 버튼 상태 변경
                                });
                              },
                            ),
                            SizedBox(height: 12),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: MainColors.mainLight,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                fixedSize: Size(
                                  MediaQuery.of(context).size.width * 1,
                                  50,
                                ),
                              ),
                              onPressed: () {},
                              child: Text(
                                "목표 설정",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
}
}