import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/heroes/hero_manager.dart';

class HeroScreen extends StatelessWidget {
  const HeroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Heroes')),
      body: Consumer<HeroManager>(
        builder: (context, heroManager, child) {
          final heroes = heroManager.ownedHeroes;

          if (heroes.isEmpty) {
            return const Center(child: Text('No heroes recruited yet!'));
          }

          return ListView.builder(
            itemCount: heroes.length,
            itemBuilder: (context, index) {
              final instance = heroes[index];
              final hero = instance.hero;
              if (hero == null) return const SizedBox.shrink();

              final stats = instance.currentStats!;
              final cost = instance.getLevelUpCost();

              return Card(
                margin: const EdgeInsets.all(8),
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Icon / Rarity
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: hero.rarityColor.withOpacity(0.2),
                          border: Border.all(color: hero.rarityColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            hero.classIcon,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hero.name,
                              style: TextStyle(
                                color: hero.rarityColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Lv.${instance.level} Power: ${stats.power.toInt()}',
                            ),
                            Text(
                              'ATK: ${stats.attack} / HP: ${stats.hp}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Actions
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (!instance.isInTeam) {
                                heroManager.addToTeam(instance.heroId);
                              } else {
                                heroManager.removeFromTeam(instance.heroId);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: instance.isInTeam
                                  ? Colors.red
                                  : Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            child: Text(instance.isInTeam ? 'Remove' : 'Equip'),
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: () {
                              heroManager.levelUpHero(instance.heroId);
                            },
                            child: Text('Up ($cost G)'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
