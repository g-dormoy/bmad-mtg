import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtg/feature/scanning/widgets/card_frame_overlay.dart';

void main() {
  group('CardFrameOverlay', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardFrameOverlay(),
          ),
        ),
      );

      expect(find.byType(CardFrameOverlay), findsOneWidget);
      // CustomPaint is used for the frame overlay painter
      expect(
        find.descendant(
          of: find.byType(CardFrameOverlay),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays instruction text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardFrameOverlay(),
          ),
        ),
      );

      expect(find.text('Position card within frame'), findsOneWidget);
    });

    test('painter uses correct 63:88 MTG card aspect ratio', () {
      // Verify the actual constant used by CardFramePainter matches
      // the standard MTG card dimensions (63mm wide x 88mm tall).
      expect(cardAspectRatio, closeTo(63 / 88, 0.0001));
      expect(cardAspectRatio, lessThan(1.0)); // Card is taller than wide
    });
  });
}
