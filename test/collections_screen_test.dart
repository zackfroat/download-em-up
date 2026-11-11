import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insideteam/features/collections/screens/collections_screen.dart';

void main() {
  testWidgets('CollectionsScreen renders Neo-Brutalist elements accurately',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CollectionsScreen(),
      ),
    );

    // Verify Title headlines
    expect(find.text('Save now.\nFind anytime.'), findsOneWidget);
    expect(find.text('My Collections'), findsOneWidget);

    // Verify Input bar elements
    expect(find.text('Paste link to save'), findsOneWidget);
    expect(find.text('#'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    // Verify standard sample collections from the design
    expect(find.text('Unsorted'), findsOneWidget);
    expect(find.text('Must watch'), findsOneWidget);
    expect(find.text('Learning & Research'), findsOneWidget);
    expect(find.text('Coffee & Chill Spots'), findsOneWidget);
    expect(find.text('Travel plan'), findsOneWidget);
    expect(find.text('Weekend Recipes'), findsOneWidget);

    // Verify NEW badge
    expect(find.text('NEW'), findsOneWidget);

    // Verify folder counts
    expect(find.text('2 folders'), findsOneWidget);
    expect(find.text('57 links'), findsOneWidget);

    // Verify tapping on a folder opens details modal
    await tester.tap(find.text('Must watch'));
    await tester.pumpAndSettle();

    expect(find.text('Flutter Neo-Brutalism Masterclass'), findsOneWidget);
    expect(find.text('UI Design breakdown 2026'), findsOneWidget);
  });
}
