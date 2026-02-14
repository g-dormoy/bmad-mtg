import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtg/shared/constants/app_theme.dart';

void main() {
  group('AppTheme', () {
    late ThemeData theme;

    setUp(() {
      theme = AppTheme.darkTheme;
    });

    test('dark theme has correct background color (#121212)', () {
      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
    });

    test('dark theme has correct surface color (#1E1E1E)', () {
      expect(theme.colorScheme.surfaceContainer, const Color(0xFF1E1E1E));
    });

    test('dark theme has correct primary color (#6750A4)', () {
      expect(theme.colorScheme.primary, const Color(0xFF6750A4));
    });

    test('dark theme has white text on background', () {
      expect(theme.colorScheme.onSurface, const Color(0xFFFFFFFF));
    });

    test('dark theme has Material 3 enabled', () {
      expect(theme.useMaterial3, isTrue);
    });

    test('dark theme has dark brightness', () {
      expect(theme.brightness, Brightness.dark);
    });

    test('success color is correct (#4CAF50)', () {
      expect(AppTheme.successColor, const Color(0xFF4CAF50));
    });

    test('warning color is correct (#FFB74D)', () {
      expect(AppTheme.warningColor, const Color(0xFFFFB74D));
    });

    test('dark theme has correct surface variant color (#2C2C2C)', () {
      expect(
        theme.colorScheme.surfaceContainerHighest,
        const Color(0xFF2C2C2C),
      );
    });

    test('dark theme has correct error color (#CF6679)', () {
      expect(theme.colorScheme.error, const Color(0xFFCF6679));
    });

    test('dark theme has correct onSurfaceVariant color (#E0E0E0)', () {
      expect(theme.colorScheme.onSurfaceVariant, const Color(0xFFE0E0E0));
    });
  });

  group('MtgColors ThemeExtension', () {
    late ThemeData theme;
    late MtgColors mtgColors;

    setUp(() {
      theme = AppTheme.darkTheme;
      mtgColors = theme.extension<MtgColors>()!;
    });

    test('MtgColors extension is registered in theme', () {
      expect(theme.extension<MtgColors>(), isNotNull);
    });

    test('mana white is correct (#F9FAF4)', () {
      expect(mtgColors.manaWhite, const Color(0xFFF9FAF4));
    });

    test('mana blue is correct (#0E68AB)', () {
      expect(mtgColors.manaBlue, const Color(0xFF0E68AB));
    });

    test('mana black is correct (#3D3D3D)', () {
      expect(mtgColors.manaBlack, const Color(0xFF3D3D3D));
    });

    test('mana red is correct (#D32029)', () {
      expect(mtgColors.manaRed, const Color(0xFFD32029));
    });

    test('mana green is correct (#00733E)', () {
      expect(mtgColors.manaGreen, const Color(0xFF00733E));
    });

    test('mana colorless is correct (#9E9E9E)', () {
      expect(mtgColors.manaColorless, const Color(0xFF9E9E9E));
    });

    test('mana gold is correct (#C9A227)', () {
      expect(mtgColors.manaGold, const Color(0xFFC9A227));
    });

    test('MtgColors.lerp interpolates correctly', () {
      const colorsA = MtgColors(
        manaWhite: Color(0xFFF9FAF4),
        manaBlue: Color(0xFF0E68AB),
        manaBlack: Color(0xFF3D3D3D),
        manaRed: Color(0xFFD32029),
        manaGreen: Color(0xFF00733E),
        manaColorless: Color(0xFF9E9E9E),
        manaGold: Color(0xFFC9A227),
      );

      const colorsB = MtgColors(
        manaWhite: Color(0xFF000000),
        manaBlue: Color(0xFF000000),
        manaBlack: Color(0xFF000000),
        manaRed: Color(0xFF000000),
        manaGreen: Color(0xFF000000),
        manaColorless: Color(0xFF000000),
        manaGold: Color(0xFF000000),
      );

      // t=0 returns the original
      final lerped = colorsA.lerp(colorsB, 0) as MtgColors;
      expect(lerped.manaWhite, colorsA.manaWhite);
      expect(lerped.manaBlue, colorsA.manaBlue);

      // t=1 returns the target
      final lerpedEnd = colorsA.lerp(colorsB, 1) as MtgColors;
      expect(lerpedEnd.manaWhite, colorsB.manaWhite);
      expect(lerpedEnd.manaRed, colorsB.manaRed);

      // t=0.5 returns intermediate values
      final lerpedMid = colorsA.lerp(colorsB, 0.5) as MtgColors;
      expect(lerpedMid.manaWhite, isNot(colorsA.manaWhite));
      expect(lerpedMid.manaWhite, isNot(colorsB.manaWhite));
      expect(lerpedMid.manaGold, isNot(colorsA.manaGold));
      expect(lerpedMid.manaGold, isNot(colorsB.manaGold));
    });

    test('MtgColors.copyWith overrides specified fields', () {
      const original = MtgColors(
        manaWhite: Color(0xFFF9FAF4),
        manaBlue: Color(0xFF0E68AB),
        manaBlack: Color(0xFF3D3D3D),
        manaRed: Color(0xFFD32029),
        manaGreen: Color(0xFF00733E),
        manaColorless: Color(0xFF9E9E9E),
        manaGold: Color(0xFFC9A227),
      );

      final copied = original.copyWith(manaBlue: const Color(0xFF0000FF));

      // Overridden field changes
      expect(copied.manaBlue, const Color(0xFF0000FF));
      // Non-overridden fields preserved
      expect(copied.manaWhite, original.manaWhite);
      expect(copied.manaRed, original.manaRed);
      expect(copied.manaGold, original.manaGold);
    });
  });
}
