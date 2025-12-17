import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';

import 'features/player/player_manager.dart';
import 'features/heroes/hero_manager.dart';
import 'features/save/save_manager.dart';
import 'screens/home_screen.dart';

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

class _GuildWanderersAppState extends State<GuildWanderersApp> with WidgetsBindingObserver {
  late PlayerManager _playerManager;
  late HeroManager _heroManager;
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
    _heroManager = HeroManager(playerManager: _playerManager);
    _saveManager = SaveManager(
      playerManager: _playerManager,
      heroManager: _heroManager,
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
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _playerManager),
        ChangeNotifierProvider.value(value: _heroManager),
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
