import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';

import '../features/player/player_manager.dart';
import '../features/heroes/hero_manager.dart';
import '../features/save/save_manager.dart';
import 'heroes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guild of Wanderers'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final saveManager = Provider.of<SaveManager>(context, listen: false);
              final success = await saveManager.saveGame();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '게임이 저장되었습니다' : '저장 실패'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
            tooltip: '게임 저장',
          ),
        ],
      ),
      body: Consumer2<PlayerManager, HeroManager>(
        builder: (context, player, heroes, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Player info
                Card(
                  color: AppColors.panel,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('길드 오브 방랑자들', style: AppTextStyles.header1),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.account_circle, size: 32, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('레벨 ${player.playerLevel}', style: AppTextStyles.body),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: player.expProgress,
                                    backgroundColor: Colors.grey[800],
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Currencies
                Card(
                  color: AppColors.panel,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('보유 자원', style: AppTextStyles.header2),
                        const SizedBox(height: 12),
                        _buildCurrencyRow(Icons.monetization_on, '골드', player.gold, Colors.yellow),
                        const SizedBox(height: 8),
                        _buildCurrencyRow(Icons.diamond, '보석', player.gems, Colors.cyan),
                        const SizedBox(height: 8),
                        _buildCurrencyRow(Icons.shield, '길드 코인', player.guildCoins, Colors.purple),
                        const SizedBox(height: 8),
                        _buildCurrencyRow(Icons.flash_on, '에너지', player.energy, Colors.orange),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Team info
                Card(
                  color: AppColors.panel,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('나의 팀', style: AppTextStyles.header2),
                            Text(
                              '전투력: ${heroes.getTeamPower()}',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (heroes.teamHeroes.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                '팀에 영웅이 없습니다',
                                style: AppTextStyles.caption.copyWith(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: heroes.teamHeroes.map((instance) {
                              final hero = instance.hero;
                              if (hero == null) return const SizedBox.shrink();

                              return Container(
                                width: 80,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: hero.rarityColor, width: 2),
                                ),
                                child: Column(
                                  children: [
                                    Text(hero.classIcon, style: const TextStyle(fontSize: 32)),
                                    const SizedBox(height: 4),
                                    Text(
                                      hero.nameKo,
                                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Lv.${instance.level}',
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 10,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Hero stats
                Card(
                  color: AppColors.panel,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('영웅 수집', style: AppTextStyles.header2),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('전체 영웅:', style: AppTextStyles.body),
                            Text(
                              '${heroes.ownedHeroes.length}/10',
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
                ),

                const SizedBox(height: 24),

                // Menu buttons
                _buildMenuButton(
                  context,
                  icon: Icons.people,
                  label: '영웅',
                  description: '영웅 관리 및 강화',
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HeroesScreen()),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _buildMenuButton(
                  context,
                  icon: Icons.shield,
                  label: '길드',
                  description: '길드 보스 레이드',
                  color: Colors.purple,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('준비 중입니다')),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _buildMenuButton(
                  context,
                  icon: Icons.castle,
                  label: '스테이지',
                  description: '모험 진행',
                  color: Colors.green,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('준비 중입니다')),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _buildMenuButton(
                  context,
                  icon: Icons.store,
                  label: '상점',
                  description: '아이템 구매',
                  color: Colors.orange,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('준비 중입니다')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrencyRow(IconData icon, String label, int amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.body),
          ],
        ),
        Text(
          '$amount',
          style: AppTextStyles.body.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      color: AppColors.panel,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.header2.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.caption.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
