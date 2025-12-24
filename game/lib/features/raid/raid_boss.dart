import 'dart:math';

/// Raid Boss definition
class RaidBoss {
  final String id;
  final String name;
  final int stage;
  final int maxHp;
  int currentHp;
  final int rewardGold;

  // Element/Type could be added here for strategy

  RaidBoss({
    required this.id,
    required this.name,
    required this.stage,
    required this.maxHp,
    required this.currentHp,
    required this.rewardGold,
  });

  bool get isDead => currentHp <= 0;
  double get hpPercentage => max(0, currentHp) / maxHp;

  /// Generate a boss for a specific stage
  factory RaidBoss.generate(int stage) {
    // Scaling logic
    // HP scales exponentially: Base * 1.5^stage
    final scale = pow(1.5, stage - 1); // Stage 1 = 1.0
    final hp = (1000 * scale).round();
    final gold = (50 * scale).round(); // Gold scales with difficulty

    String bossName = 'Stage $stage Boss';
    if (stage == 1)
      bossName = 'Slime King';
    else if (stage == 2)
      bossName = 'Goblin Warlord';
    else if (stage == 3)
      bossName = 'Giant Golem';
    else if (stage == 4)
      bossName = 'Dark Sorcerer';
    else if (stage == 5)
      bossName = 'Infernal Dragon';

    return RaidBoss(
      id: 'boss_stage_$stage',
      name: bossName,
      stage: stage,
      maxHp: hp,
      currentHp: hp,
      rewardGold: gold,
    );
  }
}
