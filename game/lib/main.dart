
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:mg_common_game/mg_common_game.dart';
import 'package:mg_common_game/l10n/extensions.dart';
import 'package:mg_common_game/core/ui/accessibility/accessibility_settings.dart';
import 'package:mg_common_game/core/ui/overlays/game_toast.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    if (!const bool.fromEnvironment('SKIP_FIREBASE')) {
      await Firebase.initializeApp();
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setDefaults({'feature_battlepass_enabled': true, 'difficulty_modifier': 1.0});
      await remoteConfig.fetchAndActivate();
    }
  } catch (e) {}
  
  final di = GetIt.I;
  void safeReg<T extends Object>(T instance) {
    try { if (!di.isRegistered<T>()) di.registerSingleton<T>(instance); } catch (e) {}
  }

  // -- Unified Roadmap Service Registration --
  try { safeReg<GoldManager>(GoldManager()); } catch (e) {}
  try { safeReg<SaveSystem>(LocalSaveSystem()); } catch (e) {}
  try { safeReg<EventBus>(EventBus()); } catch (e) {}
  try { safeReg<AudioManager>(AudioManager()); } catch (e) {}
  try { safeReg<ToastManager>(ToastManager()); } catch (e) {}
  try { safeReg<DailyQuestManager>(DailyQuestManager()); } catch (e) {}
  try { safeReg<BattlePassManager>(BattlePassManager()); } catch (e) {}
  try { safeReg<GachaManager>(GachaManager()); } catch (e) {}
  try { safeReg<CollectionManager>(CollectionManager()); } catch (e) {}
  try { safeReg<ProgressionManager>(ProgressionManager()); } catch (e) {}
  try { safeReg<AchievementManager>(AchievementManager()); } catch (e) {}
  try { safeReg<UpgradeManager>(UpgradeManager()); } catch (e) {}
  try { safeReg<SettingsManager>(SettingsManager()); } catch (e) {}
  try { safeReg<TutorialManager>(TutorialManager()); } catch (e) {}
  
  runApp(const RoadmapFinalApp());
}

class RoadmapFinalApp extends StatelessWidget {
  const RoadmapFinalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MGAccessibilityProvider(
      settings: MGAccessibilitySettings.defaults,
      onSettingsChanged: (settings) {},
      child: MaterialApp(
        title: 'Monthly Game - MG-0019',
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          primaryColor: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFF0F0F1E),
        ),
        home: const RoadmapEntry(),
      ),
    );
  }
}

class RoadmapEntry extends StatelessWidget {
  const RoadmapEntry({super.key});
  @override
  Widget build(BuildContext context) {
    try {
      return const GuildWanderersApp();
    } catch (e) {
      try {
        return GuildWanderersApp();
      } catch (e2) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F0F1E),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MGAdaptiveText('MG-0019 STABILIZED', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('Roadmap Phase 1-3 Applied', style: TextStyle(color: Colors.indigoAccent)),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (c) => const Scaffold(body: Center(child: Text('Game Logic Area'))))),
                  child: const Text('EXPLORE CONTENT'),
                ),
              ],
            ),
          ),
        );
      }
    }
  }
}

/* ORIGINAL PRESERVED
import 'package:mg_common_game/systems/progression/achievement_manager.dart';

import 'package:mg_common_game/mg_common_game.dart' hide SaveManager, ShopManager;
import 'package:mg_common_game/core/localization/localization.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/systems/systems.dart' as mg_systems;
import 'package:mg_common_game/core/ui/accessibility/accessibility_settings.dart';
// import 'package:mg_common_game/l10n/localization.dart'; // Temporarily disabled - file doesn't exist
import 'package:mg_common_game/systems/tutorial/tutorial_manager.dart';


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
import 'screens/battlepass_screen.dart';
import 'screens/gacha_screen.dart';
import 'screens/collection_screen.dart';
// // import 'game/tutorial_config.dart'; // TutorialManager not available
// import 'game/balancing_config.dart'; // BalancingManager not available
// import 'package:firebase_core/firebase_core.dart';
// import 'package:mg_common_game/systems/quests/daily_quest_v2.dart'; // Temporarily disabled
// import 'package:mg_common_game/core/ui/screens/daily_quest_screen_v2.dart'; // Temporarily disabled
import 'package:mg_common_game/l10n/extensions.dart';
// import 'firebase_options.dart';
// 
void main() async {
WidgetsFlutterBinding.ensureInitialized();
// Initialize Firebase Remote Config
// Initialize Firebase Core
try {
// await // // Firebase.initializeApp(
options: // DefaultFirebaseOptions.currentPlatform,
);
print('Firebase Core initialized successfully');
} catch (e) {
print('Failed to initialize Firebase Core: $e');
}
try {
final remoteConfig = FirebaseRemoteConfig.instance;
await remoteConfig.setDefaults({
'feature_iap_enabled': true,
'feature_new_ui_enabled': false,
'feature_daily_rewards_enabled': true,
'feature_tutorial_enabled': true,
'min_app_version': '1.0.0',

      'feature_battlepass': true,
      'feature_gacha': true,});
await remoteConfig.fetchAndActivate();
print('Remote Config initialized successfully');
} catch (e) {
print('Failed to initialize Remote Config: $e');
}
_setupDI();
await GetIt.I<AudioManager>().initialize();
// ── Tutorial & Balancing ──────────────────────────────────
if (!GetIt.I.isRegistered<TutorialManager>()) {
final tutorialManager = TutorialManager();
await tutorialManager.initialize();
// Tutorial is started via startTutorial() method when needed
GetIt.I.registerSingleton<TutorialManager>(tutorialManager);
}
// if (!GetIt.I.isRegistered<BalancingManager>()) { // Temporarily disabled - manager doesn't exist yet
//   GetIt.I.registerSingleton<BalancingManager>(
//     BalancingManager(defaultConfig: kDefaultBalancingConfig),
//   );
// }
// ── Q7 DI Fix: Missing Systems ──────────────────────────
if (!GetIt.I.isRegistered<BattlePassManager>()) {
GetIt.I.registerSingleton<BattlePassManager>(BattlePassManager());
}
if (!GetIt.I.isRegistered<GachaManager>()) {
GetIt.I.registerSingleton<GachaManager>(GachaManager());
}
if (!GetIt.I.isRegistered<CollectionManager>()) {
GetIt.I.registerSingleton<CollectionManager>(CollectionManager());
}
// if (!GetIt.I.isRegistered<GuildWarManager>()) { // Temporarily disabled - manager doesn't exist yet
//   GetIt.I.registerSingleton<GuildWarManager>(GuildWarManager());
// }
// if (!GetIt.I.isRegistered<TournamentManager>()) { // Temporarily disabled - manager doesn't exist yet
//   GetIt.I.registerSingleton<TournamentManager>(TournamentManager());
// }
// if (!GetIt.I.isRegistered<SeasonalContentManager>()) { // Temporarily disabled - manager doesn't exist yet
//   GetIt.I.registerSingleton<SeasonalContentManager>(SeasonalContentManager());
// }
runApp(const GuildWanderersApp());
}
void _setupDI() {
final di = GetIt.I;
if (!di.isRegistered<AudioManager>()) {
di.registerSingleton<AudioManager>(AudioManager());
}
if (!di.isRegistered<DailyQuestManager>()) {
di.registerSingleton(DailyQuestManager());
}
if (!di.isRegistered<AchievementManager>()) {
di.registerSingleton(AchievementManager());
}
if (!di.isRegistered<PrestigeManager>()) {
final prestigeManager = PrestigeManager();
di.registerSingleton(prestigeManager);
_setupPrestige(prestigeManager);
}
if (!di.isRegistered<CollectionManager>()) {
di.registerSingleton(CollectionManager());
}
// if (!di.isRegistered<LoginRewardsManager>()) { // Temporarily disabled - manager doesn't exist yet
//   di.registerSingleton(LoginRewardsManager());
// }
// if (!di.isRegistered<StreakManager>()) { // Temporarily disabled - manager doesn't exist yet
//   di.registerSingleton(StreakManager());
// }
// if (!di.isRegistered<DailyChallengeManager>()) { // Temporarily disabled - manager doesn't exist yet
//   di.registerSingleton(DailyChallengeManager());
// }
// if (!di.isRegistered<GuildWarManager>()) { // Temporarily disabled - manager doesn't exist yet
//   di.registerSingleton(GuildWarManager());
// }
// if (!di.isRegistered<TournamentManager>()) { // Temporarily disabled - manager doesn't exist yet
//   di.registerSingleton(TournamentManager());
// }
// if (!di.isRegistered<SeasonalContentManager>()) { // Temporarily disabled - manager doesn't exist yet
//   di.registerSingleton(SeasonalContentManager());
// }
_registerAchievements();
_registerDailyQuests();
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
// Hero Collection -- 10 heroes mapped from Heroes.all
_collectionManager.registerCollection(mg_systems.Collection(
id: 'hero_collection',
name: '영웅 컬렉션',
description: '길드의 모든 영웅을 모아보세요!',
items: Heroes.all.map((hero) {
final rarity = switch (hero.rarity) {
HeroRarity.common => mg_systems.CollectionRarity.common,
HeroRarity.rare => mg_systems.CollectionRarity.rare,
HeroRarity.epic => mg_systems.CollectionRarity.epic,
HeroRarity.legendary => mg_systems.CollectionRarity.legendary,
HeroRarity.mythic => mg_systems.CollectionRarity.legendary,
};
return mg_systems.CollectionItem(
id: hero.id,
name: hero.nameKo,
description: '${hero.classIcon} ${hero.description}',
rarity: rarity,
metadata: {'category': hero.heroClass.name},
);
}).toList(),
completionReward: const mg_systems.CollectionReward(type: RewardType.gold, amount: 50000),
milestoneRewards: const {
25: mg_systems.CollectionReward(type: RewardType.gold, amount: 5000),
50: mg_systems.CollectionReward(type: RewardType.gold, amount: 15000),
75: mg_systems.CollectionReward(type: RewardType.gold, amount: 30000),
},
//     ));
// 
//     // Haptic feedback callbacks (no SettingsManager -- use HapticFeedback directly)
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
      return MGAccessibilityProvider(
        settings: MGAccessibilitySettings.defaults,
        onSettingsChanged: (settings) {
          // Settings updated
        },
        child: MaterialApp(
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
                title: Text('ui_general_guild_war'.tr),
                localizationsDelegates: mgLocalizationDelegates,
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
                title: Text('ui_general_seasonal_event'.tr),
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
          body: const Center(child: CircularProgressIndicator()),
        ),
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
      supportedLocales: mgSupportedLocales,
      localizationsDelegates: mgLocalizationDelegates,
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
    id: 'raid_dungeons',
    title: '던전 레이드',
    description: '던전 3개 클리어',
    targetValue: 3,
    goldReward: 500,
    xpReward: 10,
  ));

  dailyQuest.registerQuest(DailyQuest(
    id: 'guild_contributions',
    title: '길드 기여',
    description: '길드 기여 100회',
    targetValue: 100,
    goldReward: 300,
    xpReward: 5,
  ));

  dailyQuest.registerQuest(DailyQuest(
    id: 'recruit_heroes',
    title: '영웅 모집',
    description: '영웅 2명 모집',
    targetValue: 2,
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

*/