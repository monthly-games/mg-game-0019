import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:game/game/level_design_config.dart';
import 'package:game/game/wave_spawn_table.dart';
import 'package:game/game/tutorial_config.dart';

/// E2E Test for MG-0019: Guild of Wanderers (JRPG Series #4)
///
/// Tests the game loop with focus on:
/// - Guild management mechanics
/// - Cooperative gameplay
/// - Exploration elements
/// - Social features
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MG-0019 Guild of Wanderers - Game Loop E2E', () {
    testWidgets('Complete guild progression', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify main menu elements
      expect(find.text('MG-0019'), findsOneWidget);
      expect(find.text('Guild of Wanderers'), findsOneWidget);
      expect(find.text('Core Fun: $kCoreFunLoop'), findsOneWidget);

      // Navigate to tutorial
      await tester.tap(find.text('Tutorial'));
      await tester.pumpAndSettle();

      // Complete tutorial steps
      final tutorialSteps = kOnboardingTutorial.steps;
      for (int i = 0; i < tutorialSteps.length; i++) {
        await tester.pumpAndSettle();
        expect(find.text('${i + 1}/${tutorialSteps.length}'), findsOneWidget);

        await tester.tap(find.text(i == tutorialSteps.length - 1 ? 'Done' : 'Next'));
        await tester.pumpAndSettle();
      }

      // Navigate to game screen
      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Test guild progression
      int questsCompleted = 0;
      int totalGold = 0;
      int totalXP = 0;

      for (int i = 0; i < 8 && i < kLevelDesign.length; i++) {
        await tester.pumpAndSettle();

        final levelDesign = kLevelDesign[i];
        final spawn = kWaveSpawnTable[i];

        expect(find.text('Level ${levelDesign.levelIndex} - ${levelDesign.stage}'), findsOneWidget);

        // Complete guild quest
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();

        // Guild progression
        questsCompleted++;
        totalGold += levelDesign.goldReward;
        totalXP += levelDesign.xpReward;

        expect(find.text('$totalGold gold / $totalXP xp'), findsOneWidget);
      }

      // Verify guild progression
      expect(questsCompleted, greaterThan(0), reason: 'Should complete guild quests');
      expect(totalGold, greaterThan(0), reason: 'Guild should provide rewards');
      expect(totalXP, greaterThan(0), reason: 'Should gain XP');
    });

    testWidgets('Test guild exploration and variety', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Guild should have exploration types
      for (int i = 0; i < 10 && i < kLevelDesign.length; i++) {
        final level = kLevelDesign[i];

        // Guild themes
        expect(level.stage.toLowerCase(), anyOf(
          contains('guild'),
          contains('expedition'),
          contains('exploration'),
          contains('wander'),
          contains('quest'),
          contains('adventure'),
          contains('discover'),
        ), reason: 'Levels should have guild themes');

        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Verify guild theme and visual elements', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Verify guild visual elements
      expect(find.byIcon(Icons.videogame_asset_rounded), findsWidgets);
      expect(find.byIcon(Icons.groups_rounded), findsWidgets);
    });

    testWidgets('Complete full guild adventure session', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      int questsCompleted = 0;
      int maxQuests = 26;

      for (int i = 0; i < maxQuests && i < kLevelDesign.length; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
        questsCompleted++;
      }

      expect(questsCompleted, equals(maxQuests), reason: 'Should complete 26 guild quests');

      // Verify guild rewards
      final finalGold = kLevelDesign.take(maxQuests).map((l) => l.goldReward).fold(0, (a, b) => a + b);
      final finalXP = kLevelDesign.take(maxQuests).map((l) => l.xpReward).fold(0, (a, b) => a + b);

      expect(find.textContaining('$finalGold gold'), findsOneWidget);
      expect(find.textContaining('$finalXP xp'), findsOneWidget);
    });

    testWidgets('Test guild social and cooperative features', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test guild war (social competition)
      await tester.tap(find.text('Guild'));
      await tester.pumpAndSettle();
      expect(find.text('Guild War'), findsOneWidget);
      expect(find.text('Social competition is reachable from the main loop.'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test daily guild activities
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();
      expect(find.text('Daily Quests'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test tournament (guild competitions)
      await tester.tap(find.text('Tournament'));
      await tester.pumpAndSettle();
      expect(find.text('Tournament'), findsOneWidget);
    });

    testWidgets('Verify guild exploration progression', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Level Roadmap'));
      await tester.pumpAndSettle();

      // Guild should have exploration progression
      for (int i = 0; i < kLevelDesign.length && i < 12; i++) {
        final level = kLevelDesign[i];
        expect(find.text('Level ${level.levelIndex} - ${level.stage}'), findsOneWidget);

        // Exploration themes
        expect(level.stage.toLowerCase(), anyOf(
          contains('region'),
          contains('area'),
          contains('zone'),
          contains('territory'),
          contains('land'),
        ));
      }
    });
  });
}
