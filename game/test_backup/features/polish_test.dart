import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/raid/raid_boss.dart';

void main() {
  group('Polish Content Tests', () {
    test('Boss Names for first 5 stages', () {
      expect(RaidBoss.generate(1).name, 'Slime King');
      expect(RaidBoss.generate(2).name, 'Goblin Warlord');
      expect(RaidBoss.generate(3).name, 'Giant Golem');
      expect(RaidBoss.generate(4).name, 'Dark Sorcerer');
      expect(RaidBoss.generate(5).name, 'Infernal Dragon');

      // Check generic after 5
      expect(RaidBoss.generate(6).name, 'Stage 6 Boss');
    });
  });
}
