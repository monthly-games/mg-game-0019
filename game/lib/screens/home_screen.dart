import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/player/player_manager.dart';
import 'raid_screen.dart';
import 'hero_screen.dart';
import 'guild_screen.dart';
import 'shop_screen.dart'; // Import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 0 = Battle, 1 = Heroes, 2 = Guild (Placeholder)

  static const List<Widget> _screens = [
    RaidScreen(),
    HeroScreen(),
    GuildScreen(),
    ShopScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<PlayerManager>(
          builder: (context, player, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Guild of Wanderers'),
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text('${player.gold}'),
                    const SizedBox(width: 16),
                    const Icon(Icons.diamond, color: Colors.blue, size: 20),
                    const SizedBox(width: 4),
                    Text('${player.gems}'),
                    const SizedBox(width: 16),
                    const Icon(Icons.flash_on, color: Colors.yellow, size: 20),
                    const SizedBox(width: 4),
                    Text('${player.energy}'),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_kabaddi),
            label: 'Battle',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Heroes'),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Guild'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shop',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // To show 4+ items correctly
      ),
    );
  }
}
