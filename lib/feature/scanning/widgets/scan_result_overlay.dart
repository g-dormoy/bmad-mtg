import 'package:flutter/material.dart';
import 'package:mtg/data/models/scryfall_card.dart';

/// Overlay showing the recognized card's name and set code.
///
/// Positioned at the bottom of the camera viewfinder above the
/// navigation bar. Tapping the overlay triggers [onTap] to add
/// the card to the collection.
class ScanResultOverlay extends StatelessWidget {
  const ScanResultOverlay({
    required this.card,
    this.onTap,
    super.key,
  });

  /// The recognized card to display.
  final ScryfallCard card;

  /// Called when the user taps the overlay to add the card.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer
                .withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  card.name,
                  style:
                      theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  card.setCode.toUpperCase(),
                  style:
                      theme.textTheme.bodyMedium?.copyWith(
                    color:
                        theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
