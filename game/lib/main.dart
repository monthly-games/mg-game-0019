import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'game/gem_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupDI();
  await GetIt.I<AudioManager>().initialize();
  runApp(const GemApp());
}

void _setupDI() {
  if (!GetIt.I.isRegistered<AudioManager>()) {
    GetIt.I.registerSingleton<AudioManager>(AudioManager());
  }
}

class GemApp extends StatelessWidget {
  const GemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Gems',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
      ),
      home: GameWidget(game: GemGame()),
    );
  }
}
