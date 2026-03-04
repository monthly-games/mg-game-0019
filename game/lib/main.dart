import 'package:flutter/material.dart';
import 'package:mg_common_game/systems/progression/achievement_manager.dart';
import 'package:mg_common_game/systems/quests/daily_quest.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/systems/systems.dart' as mg_systems;

import 'features/player/player_manager.dart';
import 'features/heroes/hero_manager.dart';
import 'features/heroes/hero_data.dart';
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
  // DailyQuest 시스템
  GetIt.I.registerSingleton(DailyQuestManager());
  // Achievement 시스템
  GetIt.I.registerSingleton(AchievementManager());
  _registerAchievements();
  _registerDailyQuests();
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
  late mg_systems.CollectionManager _collectionManager;
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

    // Collection Manager
    _collectionManager = mg_systems.CollectionManager();
    if (!GetIt.I.isRegistered<mg_systems.CollectionManager>()) {
      GetIt.I.registerSingleton<mg_systems.CollectionManager>(_collectionManager);
    }
    _registerCollections();

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

  void _registerCollections() {
    // Hero Collection — 10 heroes mapped from Heroes.all
    _collectionManager.registerCollection(mg_systems.Collection(
      id: 'hero_collection',
      name: '영웅 컬렉션',
      description: '길드의 모든 영웅을 모아보세요!',
      items: Heroes.all.map((hero) {
        // HeroRarity maps 1:1 to CollectionRarity
        String rarity;
        switch (hero.rarity) {
          case HeroRarity.common:
            rarity = mg_systems.CollectionRarity.common;
          case HeroRarity.rare:
            rarity = mg_systems.CollectionRarity.rare;
          case HeroRarity.epic:
            rarity = mg_systems.CollectionRarity.epic;
          case HeroRarity.legendary:
            rarity = mg_systems.CollectionRarity.legendary;
          case HeroRarity.mythic:
            rarity = mg_systems.CollectionRarity.mythic;
        }
        return mg_systems.CollectionItem(
          id: hero.id,
          name: hero.nameKo,
          description: '${hero.classIcon} ${hero.description}',
          rarity: rarity,
          category: hero.heroClass.name,
        );
      }).toList(),
      completionReward: const mg_systems.CollectionReward(
        gold: 50000,
        gems: 1000,
        experience: 5000,
      ),
      milestoneRewards: const {
        25: mg_systems.CollectionReward(gold: 5000, gems: 100, experience: 500),
        50: mg_systems.CollectionReward(gold: 15000, gems: 300, experience: 1500),
        75: mg_systems.CollectionReward(gold: 30000, gems: 600, experience: 3000),
      },
    ));

    // Haptic feedback callbacks (no SettingsManager — use HapticFeedback directly)
    _collectionManager.onItemUnlocked = (collectionId, itemId) {
      HapticFeedback.mediumImpact();
    };

    _collectionManager.onCollectionCompleted = (collectionId, reward) {
      HapticFeedback.heavyImpact();
    };
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
        ChangeNotifierProvider<mg_systems.CollectionManager>.value(value: _collectionManager),
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


void _registerDailyQuests() {
  final dailyQuest = GetIt.I<DailyQuestManager>();
  
  dailyQuest.registerQuest(DailyQuest(
    id: 'collect_gold',
    title: '골드 모으기',
    description: '골드 1000 획득',
    targetValue: 1000,
    goldReward: 500,
    xpReward: 10,
  ));
  
  dailyQuest.registerQuest(DailyQuest(
    id: 'play_games',
    title: '게임 플레이',
    description: '게임 5판 플레이',
    targetValue: 5,
    goldReward: 300,
    xpReward: 5,
  ));
  
  dailyQuest.registerQuest(DailyQuest(
    id: 'level_up',
    title: '레벨업',
    description: '레벨 1 상승',
    targetValue: 1,
    goldReward: 200,
    xpReward: 3,
  ));
}


void _registerAchievements() {
  final achievement = GetIt.I<AchievementManager>();
  
  achievement.registerAchievement(Achievement(
    id: 'gold_1000',
    title: '골드 1000 달성',
    description: '총 골드 1000을 모으세요',
    iconAsset: 'assets/achievements/gold_1000.png',
  ));
  
  achievement.registerAchievement(Achievement(
    id: 'level_10',
    title: '레벨 10 달성',
    description: '레벨 10에 도달하세요',
    iconAsset: 'assets/achievements/level_10.png',
  ));
  
  achievement.registerAchievement(Achievement(
    id: 'play_100',
    title: '100판 플레이',
    description: '게임을 100판 플레이하세요',
    iconAsset: 'assets/achievements/play_100.png',
  ));
}
