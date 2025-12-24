import 'package:flutter/foundation.dart';
import '../player/player_manager.dart';

class Guild {
  final String name;
  int level;
  int exp;
  final List<String> members; // Mock list of member names
  final Map<String, int> buffLevels; // Buff Type -> Level

  Guild({
    required this.name,
    this.level = 1,
    this.exp = 0,
    List<String>? members,
    Map<String, int>? buffLevels,
  }) : members = members ?? ['Player'],
       buffLevels = buffLevels ?? {'attack': 0, 'defense': 0, 'gold': 0};

  int get maxExp => level * 1000;

  void addExp(int amount) {
    exp += amount;
    while (exp >= maxExp) {
      exp -= maxExp;
      level++;
    }
  }
}

class GuildManager extends ChangeNotifier {
  final PlayerManager _playerManager;

  Guild? _guild;
  Guild? get guild => _guild;

  GuildManager({required PlayerManager playerManager})
    : _playerManager = playerManager;

  // Mock: Create Guild
  bool createGuild(String name) {
    if (_guild != null) return false;

    // Cost 1000 Gold
    if (_playerManager.spendGold(1000)) {
      _guild = Guild(name: name);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Mock: Join Random Guild
  void joinRandomGuild() {
    if (_guild != null) return;
    _guild = Guild(
      name: 'Wanderers #${DateTime.now().millisecond}',
      members: ['Alice', 'Bob', 'Player'],
      level: 5, // Join a leveled guild for fun
    );
    notifyListeners();
  }

  // Donate to Guild
  bool donateToGuild() {
    if (_guild == null) return false;

    // Donate 100 Gold -> 10 Guild Exp
    if (_playerManager.spendGold(100)) {
      _guild!.addExp(10);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Get Buffs
  double getAttackBuff() {
    if (_guild == null) return 0.0;
    // 1% per guild level as a simple base buff
    return _guild!.level * 0.01;
  }

  double getDefenseBuff() {
    if (_guild == null) return 0.0;
    return _guild!.level * 0.01;
  }

  // Persistence
  Map<String, dynamic> toJson() {
    return {
      'hasGuild': _guild != null,
      'guildName': _guild?.name,
      'guildLevel': _guild?.level,
      'guildExp': _guild?.exp,
    };
  }

  void loadFromSave(Map<String, dynamic> json) {
    if (json['hasGuild'] == true) {
      _guild = Guild(
        name: json['guildName'],
        level: json['guildLevel'] ?? 1,
        exp: json['guildExp'] ?? 0,
        members: ['Player', 'Bot1', 'Bot2'], // Mock restore
      );
      notifyListeners();
    }
  }
}
