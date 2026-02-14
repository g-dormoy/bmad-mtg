import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtg/feature/collection/screens/collection_screen.dart';
import 'package:mtg/feature/scanning/providers/camera_permission_provider.dart';
import 'package:mtg/feature/scanning/screens/scan_screen.dart';
import 'package:mtg/shared/route/app_router.dart';
import 'package:permission_handler/permission_handler.dart';

/// Test notifier that returns denied permission (avoids platform channels).
class _TestPermissionNotifier extends AsyncNotifier<PermissionStatus>
    implements CameraPermissionNotifier {
  @override
  Future<PermissionStatus> build() async => PermissionStatus.denied;

  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> recheckPermission() async {}
}

void main() {
  group('AppRouter', () {
    testWidgets('initial location is /scan', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cameraPermissionProvider
                .overrideWith(_TestPermissionNotifier.new),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(routerProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The initial screen should be the ScanScreen
      expect(find.byType(ScanScreen), findsOneWidget);
    });

    testWidgets('routes resolve correctly for /scan and /collection',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cameraPermissionProvider
                .overrideWith(_TestPermissionNotifier.new),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(routerProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should start at /scan
      expect(find.byType(ScanScreen), findsOneWidget);

      // Find NavigationBar and verify it renders
      expect(find.byType(NavigationBar), findsOneWidget);

      // Tap Collection tab to navigate to /collection
      await tester.tap(find.text('Collection'));
      await tester.pumpAndSettle();

      // Collection screen should now be visible
      expect(find.byType(CollectionScreen), findsOneWidget);
      // NavigationBar should still be present
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });
}
