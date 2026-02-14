import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mtg/app/widget/app.dart';
import 'package:mtg/feature/collection/screens/collection_screen.dart';
import 'package:mtg/feature/scanning/screens/scan_screen.dart';
import 'package:mtg/shared/constants/app_theme.dart';
import 'package:mtg/shared/widget/scaffold_with_bottom_nav.dart';

void main() {
  group('App Theme Integration', () {
    testWidgets('app renders with dark background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const Scaffold(body: Text('Test')),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final context = tester.element(find.byType(Scaffold));
      final theme = Theme.of(context);

      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
      expect(scaffold.backgroundColor, isNull); // Uses theme default
    });

    testWidgets('NavigationBar inherits theme colors', (tester) async {
      final router = GoRouter(
        initialLocation: '/scan',
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
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      // NavigationBar should exist and inherit theme
      expect(find.byType(NavigationBar), findsOneWidget);

      // Verify the theme context has Material 3 enabled
      final context = tester.element(find.byType(NavigationBar));
      final theme = Theme.of(context);
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, const Color(0xFF6750A4));
    });

    testWidgets('actual App widget applies dark theme correctly',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App()),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold).first);
      final theme = Theme.of(context);

      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, const Color(0xFF6750A4));
      expect(theme.extension<MtgColors>(), isNotNull);
    });

    testWidgets('MtgColors extension is accessible from widget context',
        (tester) async {
      late MtgColors? capturedColors;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              capturedColors = Theme.of(context).extension<MtgColors>();

              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(capturedColors, isNotNull);
      expect(capturedColors!.manaBlue, const Color(0xFF0E68AB));
      expect(capturedColors!.manaRed, const Color(0xFFD32029));
    });
  });
}
