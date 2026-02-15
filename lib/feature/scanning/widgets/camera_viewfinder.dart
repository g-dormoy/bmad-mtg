import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mtg/feature/scanning/models/add_card_state.dart';
import 'package:mtg/feature/scanning/models/recognition_state.dart';
import 'package:mtg/feature/scanning/providers/add_card_provider.dart';
import 'package:mtg/feature/scanning/providers/camera_controller_provider.dart';
import 'package:mtg/feature/scanning/providers/card_recognition_provider.dart';
import 'package:mtg/feature/scanning/providers/frame_processor_provider.dart';
import 'package:mtg/feature/scanning/widgets/card_frame_overlay.dart';
import 'package:mtg/feature/scanning/widgets/scan_result_overlay.dart';

/// Full-screen camera preview with the card frame overlay on
/// top. Watches the recognition provider and frame processor
/// to drive automatic card recognition.
class CameraViewfinder extends ConsumerWidget {
  const CameraViewfinder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerAsync =
        ref.watch(cameraControllerProvider);

    // Watch recognition state for overlay updates
    final recognitionState =
        ref.watch(cardRecognitionProvider);

    // Watch add-card state for confirmation display
    final addCardState = ref.watch(addCardProvider);

    // Watch frame processor to ensure streaming is active
    ref.watch(frameProcessorProvider);

    return controllerAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Camera error: $error',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (controller) {
        if (!controller.value.isInitialized) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final previewSize = controller.value.previewSize;
        if (previewSize == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final isRecognized = recognitionState.status ==
            RecognitionStatus.recognized;
        final recognizedCard =
            recognitionState.recognizedCard;

        // AnimatedSwitcher child selection:
        // 1. If added → show AddedConfirmation
        // 2. If recognized (even while adding) → show
        //    ScanResultOverlay so AnimatedSwitcher can
        //    crossfade directly to AddedConfirmation
        // 3. Otherwise → empty
        Widget switcherChild;
        if (addCardState.status == AddCardStatus.added) {
          switcherChild = const _AddedConfirmation(
            key: ValueKey('added'),
          );
        } else if (isRecognized &&
            recognizedCard != null) {
          switcherChild = ScanResultOverlay(
            key: ValueKey(recognizedCard.id),
            card: recognizedCard,
            onTap: addCardState.status ==
                    AddCardStatus.adding
                ? null
                : () => ref
                    .read(addCardProvider.notifier)
                    .addCard(recognizedCard),
          );
        } else {
          switcherChild = const SizedBox.shrink();
        }

        return Stack(
          children: [
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: previewSize.height,
                  height: previewSize.width,
                  child: CameraPreview(controller),
                ),
              ),
            ),
            CardFrameOverlay(
              recognitionStatus: recognitionState.status,
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 24 +
                  MediaQuery.of(context).padding.bottom,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                reverseDuration:
                    const Duration(milliseconds: 150),
                child: switcherChild,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Brief "Added!" confirmation with green checkmark.
///
/// Replaces [ScanResultOverlay] in the [AnimatedSwitcher]
/// when the card has been successfully saved.
class _AddedConfirmation extends StatelessWidget {
  const _AddedConfirmation({super.key});

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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF4CAF50),
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Added!',
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }
}
