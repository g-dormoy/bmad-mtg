import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mtg/feature/scanning/providers/camera_controller_provider.dart';
import 'package:mtg/feature/scanning/widgets/card_frame_overlay.dart';

/// Full-screen camera preview with the card frame overlay on top.
class CameraViewfinder extends ConsumerWidget {
  const CameraViewfinder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerAsync = ref.watch(cameraControllerProvider);

    return controllerAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Camera error: $error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (controller) {
        if (!controller.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        final previewSize = controller.value.previewSize;
        if (previewSize == null) {
          return const Center(child: CircularProgressIndicator());
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
            const CardFrameOverlay(),
          ],
        );
      },
    );
  }
}
