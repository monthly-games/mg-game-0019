import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/player/player_manager.dart';
import 'package:game/features/heroes/hero_manager.dart';
import 'package:game/features/guild/guild_manager.dart';
import 'package:game/features/raid/raid_manager.dart';

void main() {
  group('Persistence & Offline Tests', () {
    late PlayerManager playerManager;
    late HeroManager heroManager;
    late GuildManager guildManager;
    late RaidManager raidManager;

    setUp(() {
      playerManager = PlayerManager();
      guildManager = GuildManager(playerManager: playerManager);
      heroManager = HeroManager(
        playerManager: playerManager,
        guildManager: guildManager,
      );
      raidManager = RaidManager(
        playerManager: playerManager,
        heroManager: heroManager,
      );
    });

    test('RaidManager Persistence', () {
      // Simulate progress
      raidManager.dealDamage(100);
      // Note: dealDamage might not change stage unless boss dies.

      final json = raidManager.toJson();
      expect(json['currentStage'], 1);

      // Simulate Load
      final newRaidManager = RaidManager(
        playerManager: playerManager,
        heroManager: heroManager,
      );
      newRaidManager.loadFromSave(json);

      expect(newRaidManager.currentStage, 1);
      // Boss HP might be diff if we damaged it.
      // If we did 100 dmg, hp should be lower.
    });

    test('Offline Gold Calculation', () {
      // Setup team power
      heroManager.addHero('rookie');
      heroManager.addToTeam('rookie');
      // Rookie base stats apply.

      final dps = raidManager.teamDps;
      expect(dps, greaterThan(0));

      // 1 hour offline
      final duration = const Duration(hours: 1);
      final gold = raidManager.calculateOfflineGold(duration);

      // Expected: DPS * 0.1 * 3600
      final expected = (dps * 0.1 * 3600).round();
      expect(gold, expected);
    });
  });
}
