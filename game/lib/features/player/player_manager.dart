import 'package:flutter/foundation.dart';

/// Player progression and currency management
class PlayerManager extends ChangeNotifier {
  // Currencies
  int _gold = 10000;        // Soft currency - hero upgrades, equipment
  int _gems = 500;          // Hard currency - gacha, energy refill
  int _guildCoins = 100;    // Guild currency - guild shop
  int _energy = 120;        // Stamina - stage entry

  // Energy regeneration
  DateTime _lastEnergyUpdate = DateTime.now();
  static const int energyRegenPerMinute = 1; // 1 energy per 6 minutes (10 per hour)
  static const int maxEnergy = 120;

  // Player info
  int _playerLevel = 1;
  int _playerExp = 0;

  // Getters
  int get gold => _gold;
  int get gems => _gems;
  int get guildCoins => _guildCoins;
  int get playerLevel => _playerLevel;
  int get playerExp => _playerExp;

  /// Get energy with regeneration applied
  int get energy {
    _updateEnergyRegeneration();
    return _energy;
  }

  /// Update energy regeneration based on time passed
  void _updateEnergyRegeneration() {
    if (_energy >= maxEnergy) {
      _lastEnergyUpdate = DateTime.now();
      return;
    }

    final now = DateTime.now();
    final minutesPassed = now.difference(_lastEnergyUpdate).inMinutes;

    if (minutesPassed > 0) {
      // 1 energy per 6 minutes
      final energyToAdd = (minutesPassed / 6).floor();
      if (energyToAdd > 0) {
        _energy = (_energy + energyToAdd).clamp(0, maxEnergy);
        _lastEnergyUpdate = now.subtract(Duration(
          minutes: minutesPassed % 6,
        ));
      }
    }
  }

  /// Add gold
  void addGold(int amount) {
    _gold += amount;
    notifyListeners();
  }

  /// Spend gold
  bool spendGold(int amount) {
    if (_gold < amount) return false;
    _gold -= amount;
    notifyListeners();
    return true;
  }

  /// Add gems
  void addGems(int amount) {
    _gems += amount;
    notifyListeners();
  }

  /// Spend gems
  bool spendGems(int amount) {
    if (_gems < amount) return false;
    _gems -= amount;
    notifyListeners();
    return true;
  }

  /// Add guild coins
  void addGuildCoins(int amount) {
    _guildCoins += amount;
    notifyListeners();
  }

  /// Spend guild coins
  bool spendGuildCoins(int amount) {
    if (_guildCoins < amount) return false;
    _guildCoins -= amount;
    notifyListeners();
    return true;
  }

  /// Add energy
  void addEnergy(int amount) {
    _updateEnergyRegeneration();
    _energy = (_energy + amount).clamp(0, maxEnergy);
    notifyListeners();
  }

  /// Spend energy
  bool spendEnergy(int amount) {
    _updateEnergyRegeneration();
    if (_energy < amount) return false;
    _energy -= amount;
    notifyListeners();
    return true;
  }

  /// Add player experience
  void addExp(int amount) {
    _playerExp += amount;

    // Level up check
    while (_playerExp >= _getExpForNextLevel()) {
      _playerExp -= _getExpForNextLevel();
      _playerLevel++;
      _onLevelUp();
    }

    notifyListeners();
  }

  /// Calculate experience needed for next level
  int _getExpForNextLevel() {
    return 100 * _playerLevel; // 100, 200, 300, 400...
  }

  /// Handle level up
  void _onLevelUp() {
    // Reward on level up
    addGems(10); // 10 gems per level
    addEnergy(maxEnergy); // Full energy refill
  }

  /// Get progress to next level (0.0 - 1.0)
  double get expProgress {
    final needed = _getExpForNextLevel();
    return _playerExp / needed;
  }

  /// Get last energy update time for saving
  DateTime getLastEnergyUpdate() {
    return _lastEnergyUpdate;
  }

  /// Load from save data
  void loadFromSave({
    required int gold,
    required int gems,
    required int guildCoins,
    required int energy,
    required DateTime lastEnergyUpdate,
    required int playerLevel,
    required int playerExp,
  }) {
    _gold = gold;
    _gems = gems;
    _guildCoins = guildCoins;
    _energy = energy;
    _lastEnergyUpdate = lastEnergyUpdate;
    _playerLevel = playerLevel;
    _playerExp = playerExp;
    notifyListeners();
  }
}
