import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtg/feature/scanning/widgets/camera_permission_denied.dart';

void main() {
  group('CameraPermissionDenied', () {
    testWidgets('shows camera denied message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPermissionDenied(),
          ),
        ),
      );

      expect(
        find.text('Camera access is needed to scan your MTG cards'),
        findsOneWidget,
      );
      expect(
        find.text('Enable camera permission in your device settings'),
        findsOneWidget,
      );
    });

    testWidgets('shows Open Settings button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPermissionDenied(),
          ),
        ),
      );

      expect(find.text('Open Settings'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows camera icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPermissionDenied(),
          ),
        ),
      );

      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });

    testWidgets('Open Settings button is tappable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPermissionDenied(),
          ),
        ),
      );

      // Verify the button can be tapped without throwing.
      // The actual openAppSettings() call uses a platform channel
      // which won't work in tests, but the tap shouldn't crash.
      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      // We just verify the button exists and is enabled
      final elevatedButton = tester.widget<ElevatedButton>(button);
      expect(elevatedButton.onPressed, isNotNull);
    });
  });
}
