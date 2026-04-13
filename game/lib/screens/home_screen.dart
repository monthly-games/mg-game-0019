import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/player/player_manager.dart';
import 'raid_screen.dart';
import 'hero_screen.dart';
import 'guild_screen.dart';
import 'shop_screen.dart'; // Import
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';import 'package:mg_common_game/l10n/localization.dart';


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
                Text('ui_general_guild_of_wanderers'.tr),
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: MGSpacing.xxs),
                    Text('ui_general_playergold'.tr),
                    const SizedBox(width: MGSpacing.md),
                    const Icon(Icons.diamond, color: MGColors.info, size: 20),
                    const SizedBox(width: MGSpacing.xxs),
                    Text('ui_general_playergems'.tr),
                    const SizedBox(width: MGSpacing.md),
                    const Icon(Icons.flash_on, color: Colors.yellow, size: 20),
                    const SizedBox(width: MGSpacing.xxs),
                    Text('ui_general_playerenergy'.tr),
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
            label: 'ui_general_battle_pass'.tr,
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'ui_general_recruit_heroes'.tr),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'ui_general_guild_war'.tr),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'shop_leave_shop'.tr,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: MGColors.common,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // To show 4+ items correctly
      ),
    );
  }
}
