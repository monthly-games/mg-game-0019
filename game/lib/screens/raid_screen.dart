import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/raid/raid_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import '../game/components/floating_text_widget.dart'; // Import
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:get_it/get_it.dart';

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
          color: Colors.white,
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
            return const Center(child: Text('Waiting for Next Boss...'));
          }

          return SafeArea(
            child: Column(
              children: [
                // Top Info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Stage ${boss.stage}'),
                      Text('Level ${boss.stage}'),
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
                              const SizedBox(height: 20),
                              // Boss Image Placeholder
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.bug_report,
                                  size: 100,
                                  color: Colors.red,
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: boss.hpPercentage,
                        minHeight: 20,
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.red,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text('${boss.currentHp} / ${boss.maxHp} HP'),
                      const SizedBox(height: 10),
                      Text('Team DPS: ${raid.teamDps.toInt()}'),
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
                          backgroundColor: Colors.grey, // Simple style
                        ),
                        // Note: RaidManager doesn't expose isAutoBattleActive getter publicy in interface seen?
                        // Ah, line 82 of RaidManager has toggleAutoBattle but line 13 _isAutoBattleActive is private.
                        // I might need to verify if there is a getter.
                        // Looking at previous view_file of raid_manager.dart, it didn't seem to have a public getter for that bool.
                        // I'll assume for now just text toggle or check if I need to add getter.
                        child: const Text('Toggle Auto'),
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
