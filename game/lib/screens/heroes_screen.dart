import 'package:flutter/material.dart' hide Hero;
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';

import '../features/player/player_manager.dart';
import '../features/heroes/hero_manager.dart';
import '../features/heroes/hero_data.dart' show Hero, HeroRarity;

class HeroesScreen extends StatelessWidget {
  const HeroesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('영웅'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer2<PlayerManager, HeroManager>(
        builder: (context, player, heroes, child) {
          final ownedHeroes = heroes.ownedHeroes;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ownedHeroes.length,
            itemBuilder: (context, index) {
              final instance = ownedHeroes[index];
              final hero = instance.hero;
              if (hero == null) return const SizedBox.shrink();

              return _buildHeroCard(context, player, heroes, instance, hero);
            },
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    PlayerManager player,
    HeroManager heroes,
    HeroInstance instance,
    Hero hero,
  ) {
    final stats = instance.currentStats;
    if (stats == null) return const SizedBox.shrink();

    return Card(
      color: AppColors.panel,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero header
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: hero.rarityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: hero.rarityColor, width: 2),
                  ),
                  child: Text(hero.classIcon, style: const TextStyle(fontSize: 40)),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(hero.nameKo, style: AppTextStyles.header2),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: hero.rarityColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: hero.rarityColor),
                            ),
                            child: Text(
                              _getRarityName(hero.rarity),
                              style: AppTextStyles.caption.copyWith(
                                color: hero.rarityColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hero.description,
                        style: AppTextStyles.caption.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('레벨: ${instance.level}', style: AppTextStyles.body),
                          const SizedBox(width: 16),
                          Text(
                            '전투력: ${stats.power.round()}',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats
            Row(
              children: [
                Expanded(child: _buildStatItem('HP', stats.hp, Icons.favorite, Colors.red)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatItem('공격', stats.attack, Icons.flash_on, Colors.orange)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildStatItem('방어', stats.defense, Icons.shield, Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatItem('속도', stats.speed, Icons.speed, Colors.green)),
              ],
            ),

            const SizedBox(height: 16),

            // Skill
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.purple, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        hero.skillName,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hero.skillDescription,
                    style: AppTextStyles.caption.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Level progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('경험치', style: AppTextStyles.caption),
                    Text(
                      '${instance.exp}/${instance.expForNextLevel}',
                      style: AppTextStyles.caption.copyWith(color: Colors.amber),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: instance.expProgress,
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                // Team toggle
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (instance.isInTeam) {
                        heroes.removeFromTeam(hero.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${hero.nameKo}을(를) 팀에서 제외했습니다')),
                        );
                      } else {
                        if (heroes.addToTeam(hero.id)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${hero.nameKo}을(를) 팀에 추가했습니다')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('팀이 가득 찼습니다 (최대 5명)')),
                          );
                        }
                      }
                    },
                    icon: Icon(instance.isInTeam ? Icons.remove_circle : Icons.add_circle),
                    label: Text(instance.isInTeam ? '팀에서 제외' : '팀에 추가'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: instance.isInTeam ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Level up
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: player.gold >= instance.getLevelUpCost()
                        ? () => _levelUpHero(context, player, heroes, instance, hero)
                        : null,
                    icon: const Icon(Icons.arrow_upward),
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('레벨업'),
                        Text(
                          '${instance.getLevelUpCost()} 골드',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text('$label:', style: AppTextStyles.caption.copyWith(fontSize: 11)),
          const Spacer(),
          Text(
            '$value',
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getRarityName(HeroRarity rarity) {
    switch (rarity) {
      case HeroRarity.common:
        return '일반';
      case HeroRarity.rare:
        return '레어';
      case HeroRarity.epic:
        return '에픽';
      case HeroRarity.legendary:
        return '전설';
      case HeroRarity.mythic:
        return '신화';
    }
  }

  void _levelUpHero(
    BuildContext context,
    PlayerManager player,
    HeroManager heroes,
    HeroInstance instance,
    Hero hero,
  ) {
    final cost = instance.getLevelUpCost();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('영웅 레벨업'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(hero.nameKo, style: AppTextStyles.header2),
            const SizedBox(height: 16),
            Text('레벨: ${instance.level} → ${instance.level + 1}'),
            const SizedBox(height: 8),
            Text('모든 스탯 +10%'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: Colors.yellow),
                const SizedBox(width: 4),
                Text(
                  '$cost 골드',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (player.gold < cost)
              const Text(
                '골드가 부족합니다!',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: player.gold >= cost
                ? () {
                    if (heroes.levelUpHero(hero.id)) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${hero.nameKo} 레벨업 완료! (Lv.${instance.level})'),
                        ),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: const Text('레벨업'),
          ),
        ],
      ),
    );
  }
}
