import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/guild/guild_manager.dart';import 'package:mg_common_game/l10n/localization.dart';


class GuildScreen extends StatelessWidget {
  const GuildScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GuildManager>(
      builder: (context, guildManager, child) {
        final guild = guildManager.guild;

        if (guild == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ui_general_you_are_not_in_a'.tr),
                const SizedBox(height: MGSpacing.mdLg),
                ElevatedButton(
                  onPressed: () {
                    // Logic to show dialog? Or just quick create
                    _showCreateGuildDialog(context, guildManager);
                  },
                  child: Text('ui_general_create_guild_1000_gold'.tr),
                ),
                const SizedBox(height: MGSpacing.xsMd),
                ElevatedButton(
                  onPressed: () {
                    guildManager.joinRandomGuild();
                  },
                  child: Text('ui_general_join_random_guild'.tr),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(guild.name)),
          body: Padding(
            padding: const EdgeInsets.all(MGSpacing.md),
            child: Column(
              children: [
                // Guild Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(MGSpacing.md),
                    child: Column(
                      children: [
                        Text(
                          'Level ${guild.level}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('ui_general_exp_guildexp_guildmaxexp'.tr),
                        const SizedBox(height: MGSpacing.xsMd),
                        const Text(
                          'Buffs Active:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Attack +${(guildManager.getAttackBuff() * 100).toInt()}%',
                        ),
                        Text(
                          'Defense +${(guildManager.getDefenseBuff() * 100).toInt()}%',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: MGSpacing.mdLg),

                // Actions
                ElevatedButton.icon(
                  onPressed: () {
                    guildManager.donateToGuild();
                  },
                  icon: const Icon(Icons.monetization_on),
                  label: Text('ui_general_donate_100_gold_10_exp'.tr),
                ),

                const SizedBox(height: MGSpacing.mdLg),

                // Members List
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Members:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: guild.members.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(guild.members[index]),
                              subtitle: const Text('Online'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateGuildDialog(BuildContext context, GuildManager manager) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ui_general_create_guild'.tr),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Guild Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (manager.createGuild(controller.text)) {
                Navigator.pop(context);
              } else {
                // Show error (not enough gold)
              }
            },
            child: Text('ui_general_create_better_items'.tr),
          ),
        ],
      ),
    );
  }
}
