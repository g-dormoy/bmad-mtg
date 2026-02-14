import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mtg/feature/collection/screens/collection_screen.dart';
import 'package:mtg/feature/scanning/providers/camera_permission_provider.dart';
import 'package:mtg/feature/scanning/screens/scan_screen.dart';
import 'package:mtg/shared/widget/scaffold_with_bottom_nav.dart';
import 'package:permission_handler/permission_handler.dart';

/// Helper to create a GoRouter with StatefulShellRoute for testing.
GoRouter createTestRouter({String initialLocation = '/scan'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNav(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/scan',
                builder: (context, state) => const ScanScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/collection',
                builder: (context, state) => const CollectionScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

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
  Widget wrapWithProviderScope(Widget child) {
    return ProviderScope(
      overrides: [
        cameraPermissionProvider.overrideWith(_TestPermissionNotifier.new),
      ],
      child: child,
    );
  }

  group('ScaffoldWithBottomNav', () {
    testWidgets('renders bottom navigation bar with 2 tabs', (tester) async {
      final router = createTestRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Should find a NavigationBar
      expect(find.byType(NavigationBar), findsOneWidget);

      // Should have exactly 2 NavigationDestination items
      expect(find.byType(NavigationDestination), findsNWidgets(2));
    });

    testWidgets('Scan tab has camera icon', (tester) async {
      final router = createTestRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Scan NavigationDestination
      final scanDestination = find.widgetWithText(
        NavigationDestination,
        'Scan',
      );
      expect(scanDestination, findsOneWidget);

      // Camera icon should be within the NavigationBar
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byIcon(Icons.camera_alt),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Collection tab has grid icon', (tester) async {
      final router = createTestRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Collection destination by label
      expect(find.text('Collection'), findsOneWidget);

      // Should have collections_bookmark outlined icon (inactive tab)
      expect(
        find.byIcon(Icons.collections_bookmark_outlined),
        findsOneWidget,
      );
    });

    testWidgets('tapping Collection tab navigates to collection screen',
        (tester) async {
      final router = createTestRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Initially on Scan screen
      expect(find.byType(ScanScreen), findsOneWidget);
      expect(find.byType(CollectionScreen), findsNothing);

      // Tap the Collection tab
      await tester.tap(find.text('Collection'));
      await tester.pumpAndSettle();

      // Now on Collection screen
      expect(find.byType(CollectionScreen), findsOneWidget);
    });

    testWidgets('tapping Scan tab from Collection navigates back to scan',
        (tester) async {
      final router = createTestRouter(initialLocation: '/collection');
      addTearDown(router.dispose);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Initially on Collection screen
      expect(find.byType(CollectionScreen), findsOneWidget);

      // Tap the Scan tab
      await tester.tap(find.text('Scan'));
      await tester.pumpAndSettle();

      // Now on Scan screen
      expect(find.byType(ScanScreen), findsOneWidget);
    });

    testWidgets('re-tapping active tab calls goBranch with initialLocation',
        (tester) async {
      final router = createTestRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Helper to tap a tab label within the NavigationBar only
      Future<void> tapTab(String label) async {
        await tester.tap(find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ));
        await tester.pumpAndSettle();
      }

      // Navigate to Collection first
      await tapTab('Collection');
      expect(find.byType(CollectionScreen), findsOneWidget);

      // Re-tap Collection (active tab) — should not crash and should
      // remain on Collection screen (goBranch with initialLocation: true)
      await tapTab('Collection');
      expect(find.byType(CollectionScreen), findsOneWidget);

      // Navigate back to Scan and re-tap Scan
      await tapTab('Scan');
      expect(find.byType(ScanScreen), findsOneWidget);

      await tapTab('Scan');
      expect(find.byType(ScanScreen), findsOneWidget);
    });
  });
}
