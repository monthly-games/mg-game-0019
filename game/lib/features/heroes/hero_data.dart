import 'dart:ui';

/// Hero rarity tiers
enum HeroRarity {
  common,
  rare,
  epic,
  legendary,
  mythic,
}

/// Hero class (role)
enum HeroClass {
  warrior,  // 전사 - High HP, Defense
  mage,     // 마법사 - High Magic Attack
  archer,   // 궁수 - High Physical Attack
  healer,   // 힐러 - Healing abilities
  tank,     // 탱커 - Very high HP, Defense
}

/// Hero statistics
class HeroStats {
  final int hp;
  final int attack;
  final int defense;
  final int speed;
  final int critRate;    // Percent (0-100)
  final int critDamage;  // Percent (100+)

  const HeroStats({
    required this.hp,
    required this.attack,
    required this.defense,
    required this.speed,
    this.critRate = 5,
    this.critDamage = 150,
  });

  /// Calculate overall power rating
  double get power => (hp * 0.3 + attack * 0.4 + defense * 0.2 + speed * 0.1);

  /// Apply level scaling
  HeroStats applyLevel(int level) {
    final multiplier = 1.0 + (level - 1) * 0.1; // +10% per level
    return HeroStats(
      hp: (hp * multiplier).round(),
      attack: (attack * multiplier).round(),
      defense: (defense * multiplier).round(),
      speed: (speed * multiplier).round(),
      critRate: critRate,
      critDamage: critDamage,
    );
  }

  /// Apply guild buffs
  HeroStats applyGuildBuffs({
    double attackBonus = 0.0,
    double defenseBonus = 0.0,
    double hpBonus = 0.0,
  }) {
    return HeroStats(
      hp: (hp * (1 + hpBonus)).round(),
      attack: (attack * (1 + attackBonus)).round(),
      defense: (defense * (1 + defenseBonus)).round(),
      speed: speed,
      critRate: critRate,
      critDamage: critDamage,
    );
  }
}

/// Hero definition
class Hero {
  final String id;
  final String name;
  final String nameKo;
  final HeroRarity rarity;
  final HeroClass heroClass;
  final HeroStats baseStats;
  final String description;
  final String skillName;
  final String skillDescription;

  const Hero({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.rarity,
    required this.heroClass,
    required this.baseStats,
    required this.description,
    required this.skillName,
    required this.skillDescription,
  });

  /// Get rarity color
  Color get rarityColor {
    switch (rarity) {
      case HeroRarity.common:
        return const Color(0xFFAAAAAA);
      case HeroRarity.rare:
        return const Color(0xFF4488FF);
      case HeroRarity.epic:
        return const Color(0xFFAA44FF);
      case HeroRarity.legendary:
        return const Color(0xFFFFAA00);
      case HeroRarity.mythic:
        return const Color(0xFFFF4444);
    }
  }

  /// Get class icon
  String get classIcon {
    switch (heroClass) {
      case HeroClass.warrior:
        return '⚔️';
      case HeroClass.mage:
        return '🔮';
      case HeroClass.archer:
        return '🏹';
      case HeroClass.healer:
        return '💚';
      case HeroClass.tank:
        return '🛡️';
    }
  }
}

/// All available heroes
class Heroes {
  // Common Heroes
  static const rookie = Hero(
    id: 'rookie',
    name: 'Rookie Warrior',
    nameKo: '신참 전사',
    rarity: HeroRarity.common,
    heroClass: HeroClass.warrior,
    baseStats: HeroStats(
      hp: 500,
      attack: 50,
      defense: 30,
      speed: 40,
    ),
    description: '길드의 신참 전사',
    skillName: '베기',
    skillDescription: '적에게 120% 데미지',
  );

  static const apprentice = Hero(
    id: 'apprentice',
    name: 'Apprentice Mage',
    nameKo: '견습 마법사',
    rarity: HeroRarity.common,
    heroClass: HeroClass.mage,
    baseStats: HeroStats(
      hp: 300,
      attack: 80,
      defense: 20,
      speed: 50,
    ),
    description: '마법을 배우는 견습생',
    skillName: '파이어볼',
    skillDescription: '적에게 150% 마법 데미지',
  );

  // Rare Heroes
  static const knight = Hero(
    id: 'knight',
    name: 'Holy Knight',
    nameKo: '성기사',
    rarity: HeroRarity.rare,
    heroClass: HeroClass.warrior,
    baseStats: HeroStats(
      hp: 800,
      attack: 90,
      defense: 60,
      speed: 45,
      critRate: 10,
    ),
    description: '빛의 가호를 받은 기사',
    skillName: '성스러운 일격',
    skillDescription: '적에게 180% 데미지, 자신 HP 10% 회복',
  );

  static const ranger = Hero(
    id: 'ranger',
    name: 'Forest Ranger',
    nameKo: '숲의 레인저',
    rarity: HeroRarity.rare,
    heroClass: HeroClass.archer,
    baseStats: HeroStats(
      hp: 600,
      attack: 110,
      defense: 40,
      speed: 70,
      critRate: 20,
    ),
    description: '숲을 지키는 명궁',
    skillName: '관통 화살',
    skillDescription: '적에게 200% 데미지, 크리티컬 확률 2배',
  );

  // Epic Heroes
  static const archmage = Hero(
    id: 'archmage',
    name: 'Archmage',
    nameKo: '대마법사',
    rarity: HeroRarity.epic,
    heroClass: HeroClass.mage,
    baseStats: HeroStats(
      hp: 500,
      attack: 180,
      defense: 50,
      speed: 60,
      critRate: 15,
      critDamage: 200,
    ),
    description: '마법탑의 최고 마법사',
    skillName: '메테오',
    skillDescription: '모든 적에게 250% 마법 데미지',
  );

  static const paladin = Hero(
    id: 'paladin',
    name: 'Sacred Paladin',
    nameKo: '신성한 성기사',
    rarity: HeroRarity.epic,
    heroClass: HeroClass.tank,
    baseStats: HeroStats(
      hp: 1500,
      attack: 70,
      defense: 120,
      speed: 30,
    ),
    description: '신의 가호를 받은 수호자',
    skillName: '신성한 방패',
    skillDescription: '아군 전체 방어력 50% 증가 (3턴)',
  );

  // Legendary Heroes
  static const dragonSlayer = Hero(
    id: 'dragon_slayer',
    name: 'Dragon Slayer',
    nameKo: '용 사냥꾼',
    rarity: HeroRarity.legendary,
    heroClass: HeroClass.warrior,
    baseStats: HeroStats(
      hp: 1200,
      attack: 250,
      defense: 100,
      speed: 80,
      critRate: 25,
      critDamage: 250,
    ),
    description: '전설의 용을 쓰러뜨린 영웅',
    skillName: '드래곤 슬래쉬',
    skillDescription: '적에게 400% 데미지, 용족에게 800%',
  );

  static const celestialHealer = Hero(
    id: 'celestial_healer',
    name: 'Celestial Healer',
    nameKo: '천상의 치유사',
    rarity: HeroRarity.legendary,
    heroClass: HeroClass.healer,
    baseStats: HeroStats(
      hp: 800,
      attack: 100,
      defense: 80,
      speed: 90,
    ),
    description: '천상계에서 내려온 치유자',
    skillName: '천상의 빛',
    skillDescription: '아군 전체 HP 50% 회복, 상태이상 해제',
  );

  // Mythic Heroes
  static const phoenixLord = Hero(
    id: 'phoenix_lord',
    name: 'Phoenix Lord',
    nameKo: '불사조의 군주',
    rarity: HeroRarity.mythic,
    heroClass: HeroClass.mage,
    baseStats: HeroStats(
      hp: 1000,
      attack: 350,
      defense: 120,
      speed: 100,
      critRate: 30,
      critDamage: 300,
    ),
    description: '불사조의 힘을 지닌 전설의 마법사',
    skillName: '불사조의 부활',
    skillDescription: '모든 적에게 500% 화염 데미지, 사망 시 1회 부활',
  );

  static const voidWalker = Hero(
    id: 'void_walker',
    name: 'Void Walker',
    nameKo: '공허의 방랑자',
    rarity: HeroRarity.mythic,
    heroClass: HeroClass.archer,
    baseStats: HeroStats(
      hp: 900,
      attack: 380,
      defense: 100,
      speed: 120,
      critRate: 40,
      critDamage: 350,
    ),
    description: '공허를 걷는 암살자',
    skillName: '공허의 일격',
    skillDescription: '적 1명에게 800% 데미지, 즉사 확률 10%',
  );

  static const List<Hero> all = [
    // Common (2)
    rookie,
    apprentice,
    // Rare (2)
    knight,
    ranger,
    // Epic (2)
    archmage,
    paladin,
    // Legendary (2)
    dragonSlayer,
    celestialHealer,
    // Mythic (2)
    phoenixLord,
    voidWalker,
  ];

  static Hero? getById(String id) {
    try {
      return all.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get heroes by rarity
  static List<Hero> getByRarity(HeroRarity rarity) {
    return all.where((h) => h.rarity == rarity).toList();
  }

  /// Get heroes by class
  static List<Hero> getByClass(HeroClass heroClass) {
    return all.where((h) => h.heroClass == heroClass).toList();
  }
}
