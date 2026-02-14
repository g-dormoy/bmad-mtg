import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtg/feature/scanning/models/recognition_state.dart';
import 'package:mtg/feature/scanning/widgets/card_frame_overlay.dart';

/// Finds the [CustomPaint] widget whose painter is a
/// [CardFramePainter].
Finder findCardFramePaint() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is CustomPaint &&
        widget.painter is CardFramePainter,
  );
}

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
      expect(findCardFramePaint(), findsOneWidget);
    });

    testWidgets('displays instruction text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardFrameOverlay(),
          ),
        ),
      );

      expect(
        find.text('Position card within frame'),
        findsOneWidget,
      );
    });

    test(
      'painter uses correct 63:88 MTG card aspect ratio',
      () {
        expect(
          cardAspectRatio,
          closeTo(63 / 88, 0.0001),
        );
        expect(cardAspectRatio, lessThan(1.0));
      },
    );

    testWidgets(
      'default state shows white border',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CardFrameOverlay(),
            ),
          ),
        );

        final customPaint = tester.widget<CustomPaint>(
          findCardFramePaint(),
        );
        final painter =
            customPaint.painter! as CardFramePainter;
        expect(painter.borderColor, Colors.white);
      },
    );

    testWidgets(
      'recognized state triggers green border color',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CardFrameOverlay(
                recognitionStatus:
                    RecognitionStatus.recognized,
              ),
            ),
          ),
        );

        // Advance animation to completion (300ms)
        await tester.pump(
          const Duration(milliseconds: 300),
        );

        final customPaint = tester.widget<CustomPaint>(
          findCardFramePaint(),
        );
        final painter =
            customPaint.painter! as CardFramePainter;
        expect(
          painter.borderColor,
          const Color(0xFF4CAF50),
        );
      },
    );

    testWidgets(
      'animation completes within expected duration',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CardFrameOverlay(
                recognitionStatus:
                    RecognitionStatus.recognized,
              ),
            ),
          ),
        );

        // At 150ms (half), color should be mid-transition
        await tester.pump(
          const Duration(milliseconds: 150),
        );
        var customPaint = tester.widget<CustomPaint>(
          findCardFramePaint(),
        );
        var painter =
            customPaint.painter! as CardFramePainter;
        expect(painter.borderColor, isNot(Colors.white));
        expect(
          painter.borderColor,
          isNot(const Color(0xFF4CAF50)),
        );

        // At 300ms, animation should be complete
        await tester.pump(
          const Duration(milliseconds: 150),
        );
        customPaint = tester.widget<CustomPaint>(
          findCardFramePaint(),
        );
        painter =
            customPaint.painter! as CardFramePainter;
        expect(
          painter.borderColor,
          const Color(0xFF4CAF50),
        );
      },
    );

    testWidgets(
      'returning to idle resets border to white',
      (tester) async {
        // Start with recognized (green)
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CardFrameOverlay(
                recognitionStatus:
                    RecognitionStatus.recognized,
              ),
            ),
          ),
        );
        await tester.pump(
          const Duration(milliseconds: 300),
        );

        // Now switch back to idle
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CardFrameOverlay(),
            ),
          ),
        );
        await tester.pump();

        final customPaint = tester.widget<CustomPaint>(
          findCardFramePaint(),
        );
        final painter =
            customPaint.painter! as CardFramePainter;
        expect(painter.borderColor, Colors.white);
      },
    );

    test('shouldRepaint returns true when color changes', () {
      const white = CardFramePainter();
      const green = CardFramePainter(
        borderColor: Color(0xFF4CAF50),
      );

      expect(green.shouldRepaint(white), isTrue);
      expect(white.shouldRepaint(white), isFalse);
    });
  });
}
