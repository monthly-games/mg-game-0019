import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/player/player_manager.dart';
import 'package:game/features/heroes/hero_manager.dart';
import 'package:game/features/guild/guild_manager.dart';

void main() {
  group('Guild System Tests', () {
    late PlayerManager playerManager;
    late GuildManager guildManager;
    late HeroManager heroManager;

    setUp(() {
      playerManager = PlayerManager();
      guildManager = GuildManager(playerManager: playerManager);
      heroManager = HeroManager(
        playerManager: playerManager,
        guildManager: guildManager,
      );
    });

    test('Create Guild succeeds with enough gold', () {
      playerManager.addGold(1000); // Ensure enough gold
      expect(guildManager.createGuild('Test Guild'), true);
      expect(guildManager.guild, isNotNull);
      expect(guildManager.guild!.name, 'Test Guild');
    });

    test('Create Guild fails without gold', () {
      playerManager.spendGold(playerManager.gold); // Bankrupt
      expect(guildManager.createGuild('Test Guild'), false);
      expect(guildManager.guild, isNull);
    });

    test('Donation adds Guild Exp', () {
      playerManager.addGold(1000);
      guildManager.createGuild('Test Guild');

      final initialExp = guildManager.guild!.exp;
      playerManager.addGold(100);

      expect(guildManager.donateToGuild(), true);
      expect(guildManager.guild!.exp, initialExp + 10);
    });

    test('Guild Buffs applied to Hero Stats', () {
      guildManager.joinRandomGuild(); // Level 5 guild
      // Level 5 = +5% buff

      final hero = heroManager.ownedHeroes.first;
      final baseStats = hero.currentStats!;

      final effectiveStats = heroManager.getHeroStats(hero.heroId)!;

      // We expect effective stats to be higher than base stats
      expect(effectiveStats.attack, greaterThan(baseStats.attack));

      // Calculate expected: Base * 1.05
      final expectedAttack = (baseStats.attack * 1.05).round();
      expect(effectiveStats.attack, expectedAttack);
    });
  });
}
