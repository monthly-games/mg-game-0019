import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/shop/shop_manager.dart';
import '../features/heroes/hero_data.dart'
    as hero_data; // Alias to avoid clash if any

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopManager>(
      builder: (context, shopManager, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Shop')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner / Gacha Info
                Container(
                  padding: const EdgeInsets.all(20),
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
                      SizedBox(height: 10),
                      Text(
                        'Mythic Rate: 1% | Legendary Rate: 4%',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

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
                              const SnackBar(content: Text('Not enough Gems!')),
                            );
                          }
                        },
                        child: const Column(
                          children: [
                            Text('Summon x1'),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.diamond, size: 16),
                                Text(' 100'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
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
                              const SnackBar(content: Text('Not enough Gems!')),
                            );
                          }
                        },
                        child: const Column(
                          children: [
                            Text('Summon x10'),
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
                const SizedBox(height: 20),

                // Currency Exchange
                ListTile(
                  title: const Text('Buy 5000 Gold'),
                  subtitle: const Text('Convert Gems to Gold'),
                  trailing: ElevatedButton.icon(
                    icon: const Icon(Icons.diamond, size: 16),
                    label: const Text('50'),
                    onPressed: () {
                      if (shopManager.buyGold()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Purchased 5000 Gold!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Not enough Gems!')),
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
        title: Text('Summon Result (${heroes.length})'),
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
                color: hero.rarityColor.withOpacity(0.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(hero.classIcon, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 4),
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
