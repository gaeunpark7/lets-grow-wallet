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

  double get progress {
    if (maxExp == 0) return 0;
    final raw = currentExp / maxExp;
    if (raw < 0) return 0;
    if (raw > 1) return 1;
    return raw;
  }
}

/// egg: Lv.1, 0~300
/// child: Lv.2, 0~1000
/// adult: Lv.3, max=1000
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
      return CharacterLevelProgress(
        level: 3,
        currentExp: experience,
        maxExp: max,
      );
  }
}
