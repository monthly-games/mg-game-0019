import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../player/player_manager.dart';
import '../heroes/hero_manager.dart';

/// Save/Load game data
class SaveManager extends ChangeNotifier {
  final PlayerManager _playerManager;
  final HeroManager _heroManager;
  final GuildManager?
  _guildManager; // Optional for now if not passed, but better to enforce
  final RaidManager? _raidManager;

  static const String _saveKey = 'guild_wanderers_save';

  SaveManager({
    required PlayerManager playerManager,
    required HeroManager heroManager,
    GuildManager? guildManager,
    RaidManager? raidManager,
  }) : _playerManager = playerManager,
       _heroManager = heroManager,
       _guildManager = guildManager,
       _raidManager = raidManager;

  Duration? _offlineDuration;
  Duration? get offlineDuration => _offlineDuration;

  void clearOfflineDuration() => _offlineDuration = null;

  /// Save game data
  Future<bool> saveGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final saveData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'player': {
          'gold': _playerManager.gold,
          'gems': _playerManager.gems,
          'guildCoins': _playerManager.guildCoins,
          'energy': _playerManager.energy,
          'lastEnergyUpdate': _playerManager
              .getLastEnergyUpdate()
              .toIso8601String(),
          'playerLevel': _playerManager.playerLevel,
          'playerExp': _playerManager.playerExp,
        },
        'heroes': _heroManager.toJson(),
        'guild': _guildManager?.toJson(),
        'raid': _raidManager?.toJson(),
      };

      final saveString = jsonEncode(saveData);
      await prefs.setString(_saveKey, saveString);

      debugPrint('Game saved successfully');
      return true;
    } catch (e) {
      debugPrint('Save failed: $e');
      return false;
    }
  }

  /// Load game data
  Future<bool> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saveString = prefs.getString(_saveKey);

      if (saveString == null) {
        debugPrint('No save data found');
        return false;
      }

      final saveData = jsonDecode(saveString) as Map<String, dynamic>;
      final playerData = saveData['player'] as Map<String, dynamic>;
      final heroesData = saveData['heroes'] as Map<String, dynamic>;

      // Restore player data
      _playerManager.loadFromSave(
        gold: playerData['gold'] as int,
        gems: playerData['gems'] as int,
        guildCoins: playerData['guildCoins'] as int,
        energy: playerData['energy'] as int,
        lastEnergyUpdate: DateTime.parse(
          playerData['lastEnergyUpdate'] as String,
        ),
        playerLevel: playerData['playerLevel'] as int,
        playerExp: playerData['playerExp'] as int,
      );

      // Restore hero data
      _heroManager.loadFromSave(heroesData);

      // Restore guild data
      if (saveData.containsKey('guild') && _guildManager != null) {
        _guildManager!.loadFromSave(saveData['guild'] as Map<String, dynamic>);
      }

      // Restore raid data
      if (saveData.containsKey('raid') && _raidManager != null) {
        _raidManager!.loadFromSave(saveData['raid'] as Map<String, dynamic>);
      }

      debugPrint('Game loaded successfully');

      // Calculate offline time
      if (saveData.containsKey('timestamp')) {
        final savedTime = DateTime.parse(saveData['timestamp'] as String);
        final now = DateTime.now();
        final diff = now.difference(savedTime);
        if (diff.inMinutes > 5) {
          // Minimum 5 mins to count
          _offlineDuration = diff;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Load failed: $e');
      return false;
    }
  }

  /// Check if save data exists
  Future<bool> hasSaveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_saveKey);
    } catch (e) {
      return false;
    }
  }

  /// Delete save data
  Future<bool> deleteSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_saveKey);
      debugPrint('Save data deleted');
      return true;
    } catch (e) {
      debugPrint('Delete save failed: $e');
      return false;
    }
  }
}
