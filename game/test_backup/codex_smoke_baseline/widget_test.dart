import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';

void main() {
  testWidgets('Guild Wanderers app launches', (tester) async {
    await tester.pumpWidget(const GuildWanderersApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Raid Power: 0'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
