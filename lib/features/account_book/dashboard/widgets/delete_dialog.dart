import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class DeleteDialog extends StatelessWidget {
  final VoidCallback onTap;
  const DeleteDialog({super.key, required this.onTap});

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
                "정말로 이 내역을 삭제하시겠습니까?",
                style: TextStyle(
                  fontSize: 16.spClamp,
                  color: const Color.fromARGB(255, 82, 98, 128),
                  fontWeight: FontWeight.bold,
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
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "취소",
                        style: TextStyle(
                          fontSize: 16.spClamp,
                          color: MainColors.mainDark,
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
                      onPressed: () {
                        onTap();
                      },
                      child: Text(
                        "삭제",
                        style: TextStyle(
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
