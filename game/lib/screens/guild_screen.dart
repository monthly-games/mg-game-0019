import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/guild/guild_manager.dart';

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
                const Text('You are not in a guild.'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Logic to show dialog? Or just quick create
                    _showCreateGuildDialog(context, guildManager);
                  },
                  child: const Text('Create Guild (1000 Gold)'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    guildManager.joinRandomGuild();
                  },
                  child: const Text('Join Random Guild'),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(guild.name)),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Guild Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Level ${guild.level}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('EXP: ${guild.exp} / ${guild.maxExp}'),
                        const SizedBox(height: 10),
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

                const SizedBox(height: 20),

                // Actions
                ElevatedButton.icon(
                  onPressed: () {
                    guildManager.donateToGuild();
                  },
                  icon: const Icon(Icons.monetization_on),
                  label: const Text('Donate 100 Gold (+10 EXP)'),
                ),

                const SizedBox(height: 20),

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
        title: const Text('Create Guild'),
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
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
