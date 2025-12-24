import 'package:flutter/material.dart';

class OfflineRewardDialog extends StatelessWidget {
  final Duration duration;
  final int goldReward;
  final VoidCallback onClaim;

  const OfflineRewardDialog({
    super.key,
    required this.duration,
    required this.goldReward,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Welcome Back!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 48, color: Colors.amber),
          const SizedBox(height: 16),
          Text('You were away for: ${_formatDuration(duration)}'),
          const SizedBox(height: 8),
          Text('Your heroes farmed: $goldReward Gold'),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            onClaim();
            Navigator.of(context).pop();
          },
          child: const Text('Claim'),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes % 60}m';
    }
    return '${d.inMinutes}m';
  }
}
