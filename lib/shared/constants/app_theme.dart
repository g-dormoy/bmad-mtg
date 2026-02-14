import 'package:flutter/material.dart';

/// MTG-inspired dark theme with Material 3 design tokens.
///
/// All color values are derived from the UX Design Specification.
@immutable
class MtgColors extends ThemeExtension<MtgColors> {
  const MtgColors({
    required this.manaWhite,
    required this.manaBlue,
    required this.manaBlack,
    required this.manaRed,
    required this.manaGreen,
    required this.manaColorless,
    required this.manaGold,
  });

  final Color manaWhite;
  final Color manaBlue;
  final Color manaBlack;
  final Color manaRed;
  final Color manaGreen;
  final Color manaColorless;
  final Color manaGold;

  @override
  MtgColors copyWith({
    Color? manaWhite,
    Color? manaBlue,
    Color? manaBlack,
    Color? manaRed,
    Color? manaGreen,
    Color? manaColorless,
    Color? manaGold,
  }) {
    return MtgColors(
      manaWhite: manaWhite ?? this.manaWhite,
      manaBlue: manaBlue ?? this.manaBlue,
      manaBlack: manaBlack ?? this.manaBlack,
      manaRed: manaRed ?? this.manaRed,
      manaGreen: manaGreen ?? this.manaGreen,
      manaColorless: manaColorless ?? this.manaColorless,
      manaGold: manaGold ?? this.manaGold,
    );
  }

  @override
  ThemeExtension<MtgColors> lerp(
    covariant ThemeExtension<MtgColors>? other,
    double t,
  ) {
    if (other is! MtgColors) return this;

    return MtgColors(
      manaWhite: Color.lerp(manaWhite, other.manaWhite, t)!,
      manaBlue: Color.lerp(manaBlue, other.manaBlue, t)!,
      manaBlack: Color.lerp(manaBlack, other.manaBlack, t)!,
      manaRed: Color.lerp(manaRed, other.manaRed, t)!,
      manaGreen: Color.lerp(manaGreen, other.manaGreen, t)!,
      manaColorless: Color.lerp(manaColorless, other.manaColorless, t)!,
      manaGold: Color.lerp(manaGold, other.manaGold, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  // Dark theme background colors
  static const _background = Color(0xFF121212);
  static const _surface = Color(0xFF1E1E1E);
  static const _surfaceVariant = Color(0xFF2C2C2C);

  // Primary accent
  static const _primary = Color(0xFF6750A4);

  // Semantic colors
  static const _error = Color(0xFFCF6679);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFB74D);

  // Text colors
  static const _onSurface = Color(0xFFFFFFFF);
  static const _onSurfaceVariant = Color(0xFFE0E0E0);

  // MTG mana colors
  static const _mtgColors = MtgColors(
    manaWhite: Color(0xFFF9FAF4),
    manaBlue: Color(0xFF0E68AB),
    manaBlack: Color(0xFF3D3D3D),
    manaRed: Color(0xFFD32029),
    manaGreen: Color(0xFF00733E),
    manaColorless: Color(0xFF9E9E9E),
    manaGold: Color(0xFFC9A227),
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: _background,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: _primary,
        surface: _background,
        surfaceContainer: _surface,
        surfaceContainerHighest: _surfaceVariant,
        onSurface: _onSurface,
        onSurfaceVariant: _onSurfaceVariant,
        error: _error,
      ),
      extensions: const [_mtgColors],
    );
  }
}
