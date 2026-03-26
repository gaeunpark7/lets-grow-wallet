import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class FirstCharacterDialog extends StatelessWidget {
  const FirstCharacterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Padding(
          padding: EdgeInsets.all(12.wClamp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  "캐릭터 획득",
                  style: TextStyle(
                    fontSize: 18.spClamp,
                    color: MainColors.mainDark,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ScoreMedium',
                  ),
                ),
              ),
              SizedBox(height: 5.hClamp),
              Divider(color: MainColors.mainLight, thickness: 1.5, height: 0),
              SizedBox(height: 12.hClamp),

              Image.asset(
                'assets/ad/flower_dog1_happy.png',
                fit: BoxFit.contain,
                width: 120.wClamp,
              ),
              SizedBox(height: 12.hClamp),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: MainColors.mainLight,
                    foregroundColor: Colors.white,
                    minimumSize: Size.fromHeight(45.hClamp),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "확인",
                    style: TextStyle(
                      fontSize: 16.spClamp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ScoreMedium',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
