import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtg/data/models/scryfall_card.dart';
import 'package:mtg/feature/scanning/widgets/scan_result_overlay.dart';
import 'package:mtg/shared/constants/app_theme.dart';

const _testCard = ScryfallCard(
  id: 'test-id-123',
  name: 'Lightning Bolt',
  typeLine: 'Instant',
  manaCost: '{R}',
  cmc: 1,
  colors: ['R'],
  setCode: 'lea',
  setName: 'Limited Edition Alpha',
  rarity: 'common',
);

const _testCard2 = ScryfallCard(
  id: 'test-id-456',
  name: 'Counterspell',
  typeLine: 'Instant',
  manaCost: '{U}{U}',
  cmc: 2,
  colors: ['U'],
  setCode: 'cmm',
  setName: 'Commander Masters',
  rarity: 'uncommon',
);

/// Wraps the overlay in a themed [MaterialApp] with a [Stack]
/// and [Positioned] to match the production layout context
/// in `CameraViewfinder`.
Widget buildTestWidget(ScryfallCard card) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: ScanResultOverlay(card: card),
          ),
        ],
      ),
    ),
  );
}

void main() {
  group('ScanResultOverlay', () {
    testWidgets('displays card name when recognized',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(_testCard));

      expect(find.text('Lightning Bolt'), findsOneWidget);
    });

    testWidgets('displays set code in uppercase',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(_testCard));

      expect(find.text('LEA'), findsOneWidget);
    });

    testWidgets('uses Title Medium typography for card name',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(_testCard));

      final element = tester.element(
        find.text('Lightning Bolt'),
      );
      final resolvedTheme = Theme.of(element);
      final nameWidget = tester.widget<Text>(
        find.text('Lightning Bolt'),
      );
      expect(
        nameWidget.style?.fontSize,
        resolvedTheme.textTheme.titleMedium?.fontSize,
      );
    });

    testWidgets('updates when a different card is shown',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(_testCard));
      expect(find.text('Lightning Bolt'), findsOneWidget);
      expect(find.text('LEA'), findsOneWidget);

      await tester.pumpWidget(buildTestWidget(_testCard2));
      expect(find.text('Counterspell'), findsOneWidget);
      expect(find.text('CMM'), findsOneWidget);
      expect(find.text('Lightning Bolt'), findsNothing);
    });

    testWidgets(
        'has semi-transparent background from theme',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(_testCard));

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration =
          container.decoration! as BoxDecoration;

      // surfaceContainer (#1E1E1E) with 85% opacity
      expect(decoration.color?.a, closeTo(0.85, 0.01));
    });
  });
}
