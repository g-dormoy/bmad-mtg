import 'package:flutter/material.dart';
import 'package:mtg/data/models/scryfall_card.dart';

/// Overlay showing the recognized card's name and set code.
///
/// Positioned at the bottom of the camera viewfinder above the
/// navigation bar. Designed with a minimum 48dp touch target
/// for future tap-to-add functionality (Story 2.6).
class ScanResultOverlay extends StatelessWidget {
  const ScanResultOverlay({
    required this.card,
    super.key,
  });

  /// The recognized card to display.
  final ScryfallCard card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer
            .withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            card.name,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            card.setCode.toUpperCase(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
