import 'package:flutter/foundation.dart';
import 'dart:async';
import 'raid_boss.dart';
import '../heroes/hero_manager.dart';
import '../player/player_manager.dart';

class RaidManager extends ChangeNotifier {
  final PlayerManager _playerManager;
  final HeroManager _heroManager;

  RaidBoss? _currentBoss;
  Timer? _autoAttackTimer;
  bool _isAutoBattleActive = true;
  bool get isAutoBattleActive => _isAutoBattleActive; // Getter

  RaidManager({
    required PlayerManager playerManager,
    required HeroManager heroManager,
  }) : _playerManager = playerManager,
       _heroManager = heroManager {
    _startRaid(1); // Start at stage 1
    _startAutoAttackLoop();
  }

  RaidBoss? get currentBoss => _currentBoss;
  int _currentStage = 1;
  int get currentStage => _currentStage;

  double get teamDps {
    // Total team power can be used as DPS approximation
    return _heroManager.getTeamPower().toDouble();
  }

  int get clickDamage {
    // Base damage + 10% of team DPS
    return 10 + (teamDps * 0.1).round();
  }

  void _startRaid(int stage) {
    _currentStage = stage;
    _currentBoss = RaidBoss.generate(stage);
    notifyListeners();
  }

  void _startAutoAttackLoop() {
    _autoAttackTimer?.cancel();
    _autoAttackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isAutoBattleActive || _currentBoss == null || _currentBoss!.isDead) {
        return;
      }

      final damage = teamDps.round(); // 1 tick = 1 second DPS
      if (damage > 0) {
        dealDamage(damage);
      }
    });
  }

  /// Deal damage to current boss
  void dealDamage(int amount) {
    if (_currentBoss == null || _currentBoss!.isDead) return;

    _currentBoss!.currentHp -= amount;
    if (_currentBoss!.currentHp < 0) _currentBoss!.currentHp = 0;

    notifyListeners();

    if (_currentBoss!.isDead) {
      _onBossDefeated();
    }
  }

  void _onBossDefeated() {
    if (_currentBoss == null) return;

    // Reward
    final gold = _currentBoss!.rewardGold;
    _playerManager.addGold(gold);
    _playerManager.addExp(10); // Player XP

    // Schedule next boss
    Timer(const Duration(seconds: 2), () {
      _startRaid(_currentStage + 1);
    });

    notifyListeners();
  }

  /// Toggle Auto Battle
  void toggleAutoBattle() {
    _isAutoBattleActive = !_isAutoBattleActive;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoAttackTimer?.cancel();
    super.dispose();
  }

  /// Serialize state
  Map<String, dynamic> toJson() {
    return {
      'currentStage': _currentStage,
      'bossId': _currentBoss?.id,
      'bossHp': _currentBoss?.currentHp ?? 0,
    };
  }

  /// Load state
  void loadFromSave(Map<String, dynamic> json) {
    _currentStage = json['currentStage'] as int? ?? 1;

    // Restore boss
    // If we simply generate, it will have full HP. We need to override HP.
    _currentBoss = RaidBoss.generate(_currentStage);

    final savedHp = json['bossHp'] as int?;
    if (savedHp != null && _currentBoss != null) {
      _currentBoss!.currentHp = savedHp;
    }

    notifyListeners();
  }

  int calculateOfflineGold(Duration duration) {
    // 1 DPS = 1 Gold per second approx?
    // Let's say 10% of DPS per second to be conservative
    final dps = teamDps;
    final seconds = duration.inSeconds;
    // Cap at 24 hours
    final cappedSeconds = seconds > 86400 ? 86400 : seconds;

    return (dps * 0.1 * cappedSeconds).round();
  }
}
