import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class GoalsDialogConfirm extends StatelessWidget {
  // final VoidCallback onTap;

  const GoalsDialogConfirm({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Padding(
          padding: EdgeInsets.all(12.wClamp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30.hClamp),
              Text(
                "목표는 월 1회 지정할수 있으며,\n수정이 불가능합니다. 저장하시겠습니까?",
                style: TextStyle(
                  fontSize: 15.spClamp,
                  color: MainColors.mainDark,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ScoreMedium',
                ),
              ),
              SizedBox(height: 30.hClamp),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: MainColors.mainDark,
                        backgroundColor: MainColors.main,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        "취소",
                        style: TextStyle(
                          fontSize: 16.spClamp,
                          color: const Color.fromARGB(255, 115, 138, 180),
                          fontFamily: 'ScoreMedium',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.wClamp),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: MainColors.mainLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        "저장",
                        style: TextStyle(
                          fontFamily: 'ScoreMedium',
                          fontSize: 16.spClamp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
