import 'dart:math';
import 'package:flutter/foundation.dart';
import '../player/player_manager.dart';
import '../heroes/hero_manager.dart';
import '../heroes/hero_data.dart';

class ShopManager extends ChangeNotifier {
  final PlayerManager _playerManager;
  final HeroManager _heroManager;
  final Random _rng = Random();

  ShopManager({
    required PlayerManager playerManager,
    required HeroManager heroManager,
  }) : _playerManager = playerManager,
       _heroManager = heroManager;

  // Constants
  static const int summonCost = 100;
  static const int summon10Cost = 900;
  static const int goldCost = 50; // Gems
  static const int goldAmount = 5000;

  // Gacha Rates (Percentage)
  static const double rateMythic = 0.01;
  static const double rateLegendary = 0.04;
  static const double rateEpic = 0.15;
  static const double rateRare = 0.30;
  // Common is remaining (0.50)

  /// Summon a single hero
  Hero? summonHero() {
    if (!_playerManager.spendGems(summonCost)) return null;

    final hero = _rollHero();
    if (hero != null) {
      // Add multiple copies if supported? For now just add to collection.
      // If duplicate, maybe give shards/gold?
      // Current HeroManager addHero returns false if owned.
      // Let's modify HeroManager later to support duplicates/upgrades,
      // but for now, we just try to add. If owned, maybe convert to Gold?
      if (!_heroManager.addHero(hero.id)) {
        // Already owned: convert to gold
        _playerManager.addGold(500);
      }
    }
    notifyListeners();
    return hero;
  }

  /// Summon 10 heroes
  List<Hero> summon10Heroes() {
    if (!_playerManager.spendGems(summon10Cost)) return [];

    final List<Hero> results = [];
    for (int i = 0; i < 10; i++) {
      final hero = _rollHero();
      if (hero != null) {
        results.add(hero);
        if (!_heroManager.addHero(hero.id)) {
          _playerManager.addGold(500);
        }
      }
    }
    notifyListeners();
    return results;
  }

  /// Buy Gold with Gems
  bool buyGold() {
    if (!_playerManager.spendGems(goldCost)) return false;
    _playerManager.addGold(goldAmount);
    notifyListeners();
    return true;
  }

  Hero? _rollHero() {
    final roll = _rng.nextDouble();
    HeroRarity rarity;

    if (roll < rateMythic) {
      rarity = HeroRarity.mythic;
    } else if (roll < rateMythic + rateLegendary)
      rarity = HeroRarity.legendary;
    else if (roll < rateMythic + rateLegendary + rateEpic)
      rarity = HeroRarity.epic;
    else if (roll < rateMythic + rateLegendary + rateEpic + rateRare)
      rarity = HeroRarity.rare;
    else
      rarity = HeroRarity.common;

    final pool = Heroes.getByRarity(rarity);
    if (pool.isEmpty) return null; // Should not happen if data is complete

    return pool[_rng.nextInt(pool.length)];
  }
}
