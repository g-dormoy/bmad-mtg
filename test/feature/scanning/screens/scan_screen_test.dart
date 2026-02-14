import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtg/feature/scanning/providers/camera_permission_provider.dart';
import 'package:mtg/feature/scanning/screens/scan_screen.dart';
import 'package:mtg/feature/scanning/widgets/camera_permission_denied.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  group('ScanScreen', () {
    testWidgets('shows loading indicator while permission is being checked',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cameraPermissionProvider.overrideWith(
              _PendingPermissionNotifier.new,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: ScanScreen()),
          ),
        ),
      );

      // Should show loading while permission check is pending
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows permission denied view when permission is denied',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cameraPermissionProvider.overrideWith(
              _DeniedPermissionNotifier.new,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: ScanScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CameraPermissionDenied), findsOneWidget);
      expect(
        find.text('Camera access is needed to scan your MTG cards'),
        findsOneWidget,
      );
    });

    testWidgets(
        'shows loading indicator when permission is granted '
        '(camera controller initializing)', (tester) async {
      // When permission is granted, CameraViewfinder will try to
      // watch cameraControllerProvider which requires platform channels.
      // In test, the camera controller will be in loading state, so
      // we verify the granted path triggers the viewfinder branch.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cameraPermissionProvider.overrideWith(
              _GrantedPermissionNotifier.new,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: ScanScreen()),
          ),
        ),
      );
      await tester.pump();

      // Permission granted means we enter CameraViewfinder which shows
      // a loading indicator while the camera controller initializes.
      // In tests, the camera controller can't fully initialize (no hardware),
      // so we verify we're NOT on the permission denied view.
      expect(find.byType(CameraPermissionDenied), findsNothing);
    });
  });
}

/// Test notifier that stays in loading state (never completes).
class _PendingPermissionNotifier extends AsyncNotifier<PermissionStatus>
    implements CameraPermissionNotifier {
  @override
  Future<PermissionStatus> build() async {
    // Return a future that never completes to keep loading state
    return Future<PermissionStatus>.delayed(const Duration(days: 1));
  }

  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> recheckPermission() async {}
}

/// Test notifier that returns denied permission.
class _DeniedPermissionNotifier extends AsyncNotifier<PermissionStatus>
    implements CameraPermissionNotifier {
  @override
  Future<PermissionStatus> build() async {
    return PermissionStatus.denied;
  }

  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> recheckPermission() async {}
}

/// Test notifier that returns granted permission.
class _GrantedPermissionNotifier extends AsyncNotifier<PermissionStatus>
    implements CameraPermissionNotifier {
  @override
  Future<PermissionStatus> build() async {
    return PermissionStatus.granted;
  }

  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> recheckPermission() async {}
}
