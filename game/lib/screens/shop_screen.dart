import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/shop/shop_manager.dart';
import '../features/heroes/hero_data.dart' as hero_data;import 'package:mg_common_game/l10n/localization.dart';


class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopManager>(
      builder: (context, shopManager, child) {
        return Scaffold(
          appBar: AppBar(title: Text('shop_leave_shop'.tr)),
          body: Padding(
            padding: const EdgeInsets.all(MGSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner / Gacha Info
                Container(
                  padding: const EdgeInsets.all(MGSpacing.mdLg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade900, Colors.blue.shade900],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Legendary Summon',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      SizedBox(height: MGSpacing.xsMd),
                      Text(
                        'Mythic Rate: 1% | Legendary Rate: 4%',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: MGSpacing.mdLg),

                // Summon Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: Colors.blueAccent,
                        ),
                        onPressed: () {
                          final hero = shopManager.summonHero();
                          if (hero != null) {
                            _showSummonResult(context, [hero]);
                          } else {
                            // Helper to show snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ui_general_not_enough_gems'.tr)),
                            );
                          }
                        },
                        child: const Column(
                          children: [
                            Text('ui_general_summon_x1'.tr),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.diamond, size: 16),
                                Text('ui_general_time_resulttimems_1000tostringasfixed2s'.tr),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: MGSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: Colors.purpleAccent,
                        ),
                        onPressed: () {
                          final heroes = shopManager.summon10Heroes();
                          if (heroes.isNotEmpty) {
                            _showSummonResult(context, heroes);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ui_general_not_enough_gems'.tr)),
                            );
                          }
                        },
                        child: const Column(
                          children: [
                            Text('ui_general_summon_x10'.tr),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.diamond, size: 16),
                                Text(' 900'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: MGSpacing.mdLg),

                // Currency Exchange
                ListTile(
                  title: Text('shop_buy_5000_gold'.tr),
                  subtitle: Text('ui_general_convert_gems_to_gold'.tr),
                  trailing: ElevatedButton.icon(
                    icon: const Icon(Icons.diamond, size: 16),
                    label: Text('ui_general_up_50g'.tr),
                    onPressed: () {
                      if (shopManager.buyGold()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('shop_purchased_5000_gold'.tr)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ui_general_not_enough_gems'.tr)),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSummonResult(BuildContext context, List<hero_data.Hero> heroes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ui_general_summon_result_heroeslength'.tr),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
            ),
            itemCount: heroes.length,
            itemBuilder: (context, index) {
              final hero = heroes[index];
              return Card(
                color: hero.rarityColor.withValues(alpha: 0.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(hero.classIcon, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: MGSpacing.xxs),
                    Text(
                      hero.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
