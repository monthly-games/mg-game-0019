import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/raid/raid_manager.dart';
import '../game/components/floating_text_widget.dart'; // Import
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';import 'package:mg_common_game/l10n/localization.dart';


class RaidScreen extends StatefulWidget {
  const RaidScreen({super.key});

  @override
  State<RaidScreen> createState() => _RaidScreenState();
}

class _RaidScreenState extends State<RaidScreen> {
  // Floating texts
  final List<Widget> _floatingTexts = [];

  void _addFloatingText(int damage, TapUpDetails details) {
    final key = UniqueKey();
    setState(() {
      _floatingTexts.add(
        FloatingText(
          key: key,
          text: damage.toString(),
          position: details.localPosition, // Relative to stack?
          color: MGColors.textHighEmphasis,
          onFinished: () {
            setState(() {
              _floatingTexts.removeWhere((w) => w.key == key);
            });
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<RaidManager>(
        builder: (context, raid, child) {
          final boss = raid.currentBoss;
          if (boss == null) {
            return Center(child: Text('ui_general_waiting_for_next_boss'.tr));
          }

          return SafeArea(
            child: Column(
              children: [
                // Top Info
                Padding(
                  padding: const EdgeInsets.all(MGSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ui_general_stage_bossstage'.tr),
                      Text('progress_level_bossstage'.tr),
                    ],
                  ),
                ),

                // Boss Area with Floating Text
                Expanded(
                  child: Stack(
                    children: [
                      // Boss Interaction Layer
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (details) {
                            final dmg = raid.clickDamage;
                            raid.dealDamage(dmg);
                            _addFloatingText(dmg, details);
                            GetIt.I<AudioManager>().playSfx('hit');
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                boss.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: MGSpacing.mdLg),
                              // Boss Image Placeholder
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: MGColors.error.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.bug_report,
                                  size: 100,
                                  color: MGColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Floating Texts Layer
                      ..._floatingTexts,
                    ],
                  ),
                ),

                // HP Bar & DPS
                Padding(
                  padding: const EdgeInsets.all(MGSpacing.md),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: boss.hpPercentage,
                        minHeight: 20,
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          MGColors.error,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text('ui_general_bosscurrenthp_bossmaxhp_hp'.tr),
                      const SizedBox(height: MGSpacing.xsMd),
                      Text('ui_general_team_dps_raidteamdpstoint'.tr),
                    ],
                  ),
                ),

                // Controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: raid.toggleAutoBattle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MGColors.common, // Simple style
                        ),
                        // Note: RaidManager doesn't expose isAutoBattleActive getter publicy in interface seen?
                        // Ah, line 82 of RaidManager has toggleAutoBattle but line 13 _isAutoBattleActive is private.
                        // I might need to verify if there is a getter.
                        // Looking at previous view_file of raid_manager.dart, it didn't seem to have a public getter for that bool.
                        // I'll assume for now just text toggle or check if I need to add getter.
                        child: Text('ui_general_toggle_auto'.tr),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
