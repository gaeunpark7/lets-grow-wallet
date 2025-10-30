import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/character/widgets/character_action_bottom_bar.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CharacterPage extends StatefulWidget {
  const CharacterPage({super.key});

  @override
  State<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> {
  double currentExp = 45;
  double maxExp = 100;
  int level = 3;

  @override
  Widget build(BuildContext context) {
    final progress = currentExp / maxExp;
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "캐릭터 이름",
                  style: TextStyle(
                    color: MainColors.mainDark,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 16,
                    backgroundColor: MainColors.main,
                    valueColor: AlwaysStoppedAnimation(
                      progress > 0.7
                          ? Colors.orangeAccent
                          : progress > 0.4
                          ? MainColors.mainLight
                          : Colors.lightBlueAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Container(
                  height: size.width * 1,
                  width: size.width * 1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(120),
                    border: Border.all(color: Colors.black, width: 0.8),
                  ),
                  child: Center(
                    child: Text(
                      "캐릭터 이미지",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: MainColors.mainDark,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CharacterActionBottomBar(),
      ),
    );
  }
}
