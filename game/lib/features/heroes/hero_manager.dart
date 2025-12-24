import 'package:flutter/foundation.dart';
import 'hero_data.dart';
import '../player/player_manager.dart';
import '../guild/guild_manager.dart';

/// Player's hero instance with level and equipment
class HeroInstance {
  final String heroId;
  int level;
  int exp;
  bool isInTeam;

  HeroInstance({
    required this.heroId,
    this.level = 1,
    this.exp = 0,
    this.isInTeam = false,
  });

  /// Get hero definition
  Hero? get hero => Heroes.getById(heroId);

  /// Get stats with level applied
  HeroStats? get currentStats => hero?.baseStats.applyLevel(level);

  /// Experience needed for next level
  int get expForNextLevel => 100 * level;

  /// Progress to next level (0.0 - 1.0)
  double get expProgress => exp / expForNextLevel;

  /// Calculate level up cost (gold)
  int getLevelUpCost() {
    return 100 * level * level; // 100, 400, 900, 1600...
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {'heroId': heroId, 'level': level, 'exp': exp, 'isInTeam': isInTeam};
  }

  /// Deserialize from JSON
  factory HeroInstance.fromJson(Map<String, dynamic> json) {
    return HeroInstance(
      heroId: json['heroId'] as String,
      level: json['level'] as int,
      exp: json['exp'] as int,
      isInTeam: json['isInTeam'] as bool? ?? false,
    );
  }
}

/// Hero collection and team management
/// Hero collection and team management
class HeroManager extends ChangeNotifier {
  final PlayerManager _playerManager;
  final GuildManager? _guildManager; // Optional dependency

  // Hero collection (heroId -> HeroInstance)
  final Map<String, HeroInstance> _ownedHeroes = {};

  // Team composition (max 5 heroes)
  final List<String> _teamHeroIds = [];
  static const int maxTeamSize = 5;

  HeroManager({
    required PlayerManager playerManager,
    GuildManager? guildManager,
  }) : _playerManager = playerManager,
       _guildManager = guildManager {
    // Give starter heroes
    _giveStarterHeroes();
  }

  /// Getters
  List<HeroInstance> get ownedHeroes => _ownedHeroes.values.toList();
  List<String> get teamHeroIds => List.unmodifiable(_teamHeroIds);
  List<HeroInstance> get teamHeroes =>
      _teamHeroIds.map((id) => _ownedHeroes[id]!).toList();

  /// Give starter heroes (common rarity)
  void _giveStarterHeroes() {
    addHero(Heroes.rookie.id);
    addHero(Heroes.apprentice.id);
    _addToTeam(Heroes.rookie.id);
    _addToTeam(Heroes.apprentice.id);
  }

  /// Check if player owns a hero
  bool ownsHero(String heroId) {
    return _ownedHeroes.containsKey(heroId);
  }

  /// Get hero instance
  HeroInstance? getHeroInstance(String heroId) {
    return _ownedHeroes[heroId];
  }

  /// Add hero to collection
  bool addHero(String heroId) {
    if (_ownedHeroes.containsKey(heroId)) {
      return false; // Already owned
    }

    final hero = Heroes.getById(heroId);
    if (hero == null) return false;

    _ownedHeroes[heroId] = HeroInstance(heroId: heroId);
    notifyListeners();
    return true;
  }

  /// Level up hero
  bool levelUpHero(String heroId) {
    final instance = _ownedHeroes[heroId];
    if (instance == null) return false;

    final cost = instance.getLevelUpCost();
    if (!_playerManager.spendGold(cost)) return false;

    instance.level++;
    instance.exp = 0;
    notifyListeners();
    return true;
  }

  /// Add experience to hero
  void addHeroExp(String heroId, int amount) {
    final instance = _ownedHeroes[heroId];
    if (instance == null) return;

    instance.exp += amount;

    // Auto level up if enough exp
    while (instance.exp >= instance.expForNextLevel) {
      instance.exp -= instance.expForNextLevel;
      instance.level++;
    }

    notifyListeners();
  }

  /// Get effective stats including guild buffs
  HeroStats? getHeroStats(String heroId) {
    final instance = _ownedHeroes[heroId];
    if (instance == null) return null;

    var stats = instance.currentStats;
    if (stats == null) return null;

    if (_guildManager != null) {
      stats = stats.applyGuildBuffs(
        attackBonus: _guildManager.getAttackBuff(),
        defenseBonus: _guildManager.getDefenseBuff(),
      );
    }
    return stats;
  }

  /// Add hero to team
  bool addToTeam(String heroId) {
    if (!_ownedHeroes.containsKey(heroId)) return false;
    if (_teamHeroIds.contains(heroId)) return false;
    if (_teamHeroIds.length >= maxTeamSize) return false;

    return _addToTeam(heroId);
  }

  bool _addToTeam(String heroId) {
    _teamHeroIds.add(heroId);
    _ownedHeroes[heroId]!.isInTeam = true;
    notifyListeners();
    return true;
  }

  /// Remove hero from team
  bool removeFromTeam(String heroId) {
    if (!_teamHeroIds.contains(heroId)) return false;

    _teamHeroIds.remove(heroId);
    _ownedHeroes[heroId]!.isInTeam = false;
    notifyListeners();
    return true;
  }

  int getTeamPower() {
    int totalPower = 0;
    for (final heroId in _teamHeroIds) {
      final stats = getHeroStats(heroId);
      if (stats != null) {
        totalPower += stats.power.round();
      }
    }
    return totalPower;
  }

  /// Get owned heroes by rarity
  List<HeroInstance> getHeroesByRarity(HeroRarity rarity) {
    return _ownedHeroes.values
        .where((instance) => instance.hero?.rarity == rarity)
        .toList();
  }

  /// Get owned heroes count by rarity
  int getHeroCountByRarity(HeroRarity rarity) {
    return getHeroesByRarity(rarity).length;
  }

  /// Serialize for saving
  Map<String, dynamic> toJson() {
    return {
      'ownedHeroes': _ownedHeroes.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'teamHeroIds': _teamHeroIds,
    };
  }

  /// Load from save data
  void loadFromSave(Map<String, dynamic> data) {
    _ownedHeroes.clear();
    _teamHeroIds.clear();

    final ownedData = data['ownedHeroes'] as Map<String, dynamic>?;
    if (ownedData != null) {
      ownedData.forEach((key, value) {
        _ownedHeroes[key] = HeroInstance.fromJson(
          value as Map<String, dynamic>,
        );
      });
    }

    final teamData = data['teamHeroIds'] as List?;
    if (teamData != null) {
      _teamHeroIds.addAll(teamData.cast<String>());
    }

    // Ensure starter heroes if empty
    if (_ownedHeroes.isEmpty) {
      _giveStarterHeroes();
    }

    notifyListeners();
  }
}
