import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mtg/feature/scanning/providers/camera_controller_provider.dart';
import 'package:mtg/feature/scanning/providers/camera_permission_provider.dart';
import 'package:mtg/feature/scanning/providers/card_recognition_provider.dart';
import 'package:mtg/feature/scanning/providers/frame_processor_provider.dart';
import 'package:mtg/feature/scanning/widgets/camera_permission_denied.dart';
import 'package:mtg/feature/scanning/widgets/camera_viewfinder.dart';
import 'package:permission_handler/permission_handler.dart';

/// Main scan screen that manages camera permissions and
/// displays either the camera viewfinder or a
/// permission-denied view.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() =>
      _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Restart fresh: recheck permission, reset
        // recognition so the pipeline restarts cleanly.
        ref
            .read(cameraPermissionProvider.notifier)
            .recheckPermission();
        ref
            .read(cardRecognitionProvider.notifier)
            .reset();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        // Stop recognition and camera when backgrounded.
        // Sequenced via _handleBackgrounded to avoid
        // concurrent stopImageStream calls.
        _handleBackgrounded();
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  /// Sequences the stop → reset → dispose pipeline so that
  /// `stopImageStream` completes before `disposeCamera` runs,
  /// avoiding concurrent stream-stop calls.
  Future<void> _handleBackgrounded() async {
    ref
        .read(cardRecognitionProvider.notifier)
        .reset();
    await ref
        .read(frameProcessorProvider.notifier)
        .stop();
    await ref
        .read(cameraControllerProvider.notifier)
        .disposeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final permissionAsync =
        ref.watch(cameraPermissionProvider);

    return permissionAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Permission error: $error',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
        ),
      ),
      data: (status) {
        if (status.isGranted) {
          return const CameraViewfinder();
        }
        return const CameraPermissionDenied();
      },
    );
  }
}
