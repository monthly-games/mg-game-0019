import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/screens/seasonal_event_screen.dart';
import 'package:mg_common_game/core/ui/screens/tournament_screen.dart';
import 'package:mg_common_game/core/ui/screens/guild_war_screen.dart';
import 'package:mg_common_game/systems/events/seasonal_content_manager.dart';
import 'package:mg_common_game/systems/competitive/tournament_manager.dart';
import 'package:mg_common_game/systems/social/guild_war_manager.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/core/ui/screens/daily_hub_screen.dart';
import 'package:mg_common_game/systems/retention/daily_challenge_manager.dart';
import 'package:mg_common_game/systems/retention/streak_manager.dart';
import 'package:mg_common_game/systems/retention/login_rewards_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/systems.dart';
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
import 'screens/daily_quest_screen.dart';
import 'screens/achievement_screen.dart';
import 'game/ui/offline_reward_dialog.dart'; // Import
import 'package:mg_common_game/systems/progression/prestige_manager.dart';
import 'screens/battlepass_screen.dart';
import 'screens/gacha_screen.dart';
import 'screens/collection_screen.dart';

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

  // Prestige 시스템 (mg_common_game)
  if (!GetIt.I.isRegistered<PrestigeManager>()) {
    final prestigeManager = PrestigeManager();
    GetIt.I.registerSingleton(prestigeManager);
  // Collection 시스템
  if (!GetIt.I.isRegistered<CollectionManager>()) {
    GetIt.I.registerSingleton(CollectionManager());
  // ── Retention Systems for DailyHub ────────────────────────
  if (!GetIt.I.isRegistered<LoginRewardsManager>()) {
    GetIt.I.registerSingleton(LoginRewardsManager());
  }
  if (!GetIt.I.isRegistered<StreakManager>()) {
    GetIt.I.registerSingleton(StreakManager());
  }
  if (!GetIt.I.isRegistered<DailyChallengeManager>()) {
    GetIt.I.registerSingleton(DailyChallengeManager());
}
  // ── P3 Engine Systems ─────────────────────────────────────
  if (!GetIt.I.isRegistered<GuildWarManager>()) {
    GetIt.I.registerSingleton(GuildWarManager());
  }
  if (!GetIt.I.isRegistered<TournamentManager>()) {
    GetIt.I.registerSingleton(TournamentManager());
  }
  if (!GetIt.I.isRegistered<SeasonalContentManager>()) {
    GetIt.I.registerSingleton(SeasonalContentManager());
  }
    _registerCollections();
  }
    _setupPrestige(prestigeManager);
  }
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
      completionReward: const mg_systems.CollectionReward(type: RewardType.gold, amount: 50000),
      milestoneRewards: const {
        25: mg_systems.CollectionReward(type: RewardType.gold, amount: 5000),
        50: mg_systems.CollectionReward(type: RewardType.gold, amount: 15000),
        75: mg_systems.CollectionReward(type: RewardType.gold, amount: 30000),
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
      endDrawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                    color: Color(0xFF1A237E)),
                child: Text('Community',
                    style: TextStyle(
                        color: Colors.white, fontSize: 24)),
              ),
              ListTile(
                leading: const Icon(Icons.shield),
                title: const Text('Guild War'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .pushNamed('/guild-war');
                },
              ),
              ListTile(
                leading: const Icon(Icons.emoji_events),
                title: const Text('Tournament'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .pushNamed('/tournament');
                },
              ),
              ListTile(
                leading: const Icon(Icons.celebration),
                title: const Text('Seasonal Event'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .pushNamed('/seasonal-event');
                },
              ),
            ],
          ),
        ),
      ),
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
        routes: {
          '/daily-quests': (_) => const DailyQuestScreen(),
          '/achievements': (_) => const AchievementScreen(),
          '/daily_quest': (_) => const DailyQuestScreen(),
          '/achievement': (_) => const AchievementScreen(),
          '/battlepass': (_) => const BattlePassScreen(),
          '/gacha': (_) => const GachaScreen(),
        '/daily-hub': (context) => DailyHubScreen(
          questManager: GetIt.I<DailyQuestManager>(),
          loginRewardsManager: GetIt.I<LoginRewardsManager>(),
          streakManager: GetIt.I<StreakManager>(),
          challengeManager: GetIt.I<DailyChallengeManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
        ),
        
          '/collection': (context) => CollectionScreen(
            collectionManager: GetIt.I<CollectionManager>(),
          ),
          '/guild-war': (context) => GuildWarScreen(
            guildWarManager: GetIt.I<GuildWarManager>(),
            accentColor: MGColors.primaryAction,
            onClose: () => Navigator.pop(context),
            ),
          '/tournament': (context) => TournamentScreen(
            tournamentManager: GetIt.I<TournamentManager>(),
            accentColor: MGColors.primaryAction,
            onClose: () => Navigator.pop(context),
            ),
          '/seasonal-event': (context) => SeasonalEventScreen(
            seasonalContentManager: GetIt.I<SeasonalContentManager>(),
            accentColor: MGColors.primaryAction,
            onClose: () => Navigator.pop(context),
            ),
},
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

void _setupPrestige(PrestigeManager manager) {
  // ── Prestige Upgrades (idle game defaults) ──────────────────
  // Five core upgrades for idle games
  manager.registerPrestigeUpgrade(PrestigeUpgrade(
    id: 'gold_multiplier',
    name: '골드 배수',
    description: '골드 획득량 +10%',
    maxLevel: 50,
    costPerLevel: 1,
    bonusPerLevel: 0.1,
  ));

  manager.registerPrestigeUpgrade(PrestigeUpgrade(
    id: 'xp_boost',
    name: 'XP 부스트',
    description: 'XP 획득량 +15%',
    maxLevel: 40,
    costPerLevel: 2,
    bonusPerLevel: 0.15,
  ));

  manager.registerPrestigeUpgrade(PrestigeUpgrade(
    id: 'production_speed',
    name: '생산 속도',
    description: '생산 속도 +20%',
    maxLevel: 30,
    costPerLevel: 2,
    bonusPerLevel: 0.2,
  ));

  manager.registerPrestigeUpgrade(PrestigeUpgrade(
    id: 'starting_resources',
    name: '초기 자원',
    description: '초기 자원 +5%',
    maxLevel: 60,
    costPerLevel: 1,
    bonusPerLevel: 0.05,
  ));

  manager.registerPrestigeUpgrade(PrestigeUpgrade(
    id: 'offline_income',
    name: '오프라인 수익',
    description: '오프라인 수익 +20%',
    maxLevel: 30,
    costPerLevel: 3,
    bonusPerLevel: 0.2,
  ));

  // ── Prestige Reset Callbacks ────────────────────────────────
  // TODO: Add game-specific reset callbacks:
  // manager.registerResetCallback(() {
  //   if (GetIt.I.isRegistered<ProgressionManager>()) {
  //     GetIt.I<ProgressionManager>().reset();
  //   }
  //   if (GetIt.I.isRegistered<UpgradeManager>()) {
  //     GetIt.I<UpgradeManager>().reset();
  //   }
  // });
}
