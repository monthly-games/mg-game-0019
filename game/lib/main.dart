import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';

import 'features/player/player_manager.dart';
import 'features/heroes/hero_manager.dart';
import 'features/guild/guild_manager.dart';
import 'features/shop/shop_manager.dart'; // Import
import 'features/save/save_manager.dart';
import 'features/raid/raid_manager.dart';
import 'screens/home_screen.dart';
import 'game/ui/offline_reward_dialog.dart'; // Import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupDI();
  await GetIt.I<AudioManager>().initialize();

  runApp(const GuildWanderersApp());
}

void _setupDI() {
  if (!GetIt.I.isRegistered<AudioManager>()) {
    GetIt.I.registerSingleton<AudioManager>(AudioManager());
  }
}

class GuildWanderersApp extends StatefulWidget {
  const GuildWanderersApp({super.key});

  @override
  State<GuildWanderersApp> createState() => _GuildWanderersAppState();
}

class _GuildWanderersAppState extends State<GuildWanderersApp>
    with WidgetsBindingObserver {
  late PlayerManager _playerManager;
  late GuildManager _guildManager;
  late HeroManager _heroManager;
  late RaidManager _raidManager;
  late ShopManager _shopManager;
  late SaveManager _saveManager;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auto-save when app goes to background
    if (state == AppLifecycleState.paused) {
      _saveManager.saveGame();
    }
  }

  Future<void> _initializeApp() async {
    _playerManager = PlayerManager();
    _guildManager = GuildManager(playerManager: _playerManager);

    _heroManager = HeroManager(
      playerManager: _playerManager,
      guildManager: _guildManager,
    );

    _raidManager = RaidManager(
      playerManager: _playerManager,
      heroManager: _heroManager,
    );

    _shopManager = ShopManager(
      playerManager: _playerManager,
      heroManager: _heroManager,
    );

    _saveManager = SaveManager(
      playerManager: _playerManager,
      heroManager: _heroManager,
      guildManager: _guildManager,
      raidManager: _raidManager,
    );

    // Try to load save data
    final loaded = await _saveManager.loadGame();
    if (loaded) {
      debugPrint('Save data loaded successfully');
    } else {
      debugPrint('Starting new game');
    }

    setState(() {
      _isLoading = false;
    });

    // Check offline progress
    final offlineDuration = _saveManager.offlineDuration;
    if (offlineDuration != null && mounted) {
      final gold = _raidManager.calculateOfflineGold(offlineDuration);
      if (gold > 0) {
        // We need context to show dialog. But we are in _initializeApp called from initState.
        // We can't show dialog yet.
        // Wait for first frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (_) => OfflineRewardDialog(
              duration: offlineDuration,
              goldReward: gold,
              onClaim: () {
                _playerManager.addGold(gold);
                _saveManager.clearOfflineDuration();
              },
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _playerManager),
        ChangeNotifierProvider.value(value: _guildManager), // Provide
        ChangeNotifierProvider.value(value: _heroManager),
        ChangeNotifierProvider.value(value: _raidManager),
        ChangeNotifierProvider.value(value: _shopManager),
        ChangeNotifierProvider.value(value: _saveManager),
      ],
      child: MaterialApp(
        title: 'Guild of Wanderers',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
