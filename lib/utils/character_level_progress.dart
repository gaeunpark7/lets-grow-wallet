import 'package:lets_grow_wallet/utils/character_interation_enum.dart';

class CharacterLevelProgress {
  final int level;
  final int currentExp;
  final int maxExp;

  const CharacterLevelProgress({
    required this.level,
    required this.currentExp,
    required this.maxExp,
  });

  double get progress => maxExp == 0 ? 0 : currentExp / maxExp;
}

/// - egg: Lv.1, 0~300
/// - child: Lv.2, 0~1000
/// - adult: Lv.3, 항상 1000/1000
CharacterLevelProgress characterLevelProgress({
  required Stage stage,
  required int experience,
}) {
  switch (stage) {
    case Stage.egg:
      const max = 300;
      final current = experience.clamp(0, max);
      return CharacterLevelProgress(level: 1, currentExp: current, maxExp: max);
    case Stage.child:
      const max = 1000;
      final current = experience.clamp(0, max);
      return CharacterLevelProgress(level: 2, currentExp: current, maxExp: max);
    case Stage.adult:
      const max = 1000;
      return const CharacterLevelProgress(
        level: 3,
        currentExp: max,
        maxExp: max,
      );
  }
}
