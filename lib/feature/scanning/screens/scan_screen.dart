import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mtg/feature/scanning/providers/camera_controller_provider.dart';
import 'package:mtg/feature/scanning/providers/camera_permission_provider.dart';
import 'package:mtg/feature/scanning/providers/card_recognition_provider.dart';
import 'package:mtg/feature/scanning/providers/frame_processor_provider.dart';
import 'package:mtg/feature/scanning/widgets/camera_permission_denied.dart';
import 'package:mtg/feature/scanning/widgets/camera_viewfinder.dart';
import 'package:mtg/shared/util/platform_type.dart';
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
    final platform = ref.read(platformTypeProvider);
    if (platform == PlatformType.web) {
      return const _WebUnavailableView();
    }

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

class _WebUnavailableView extends StatelessWidget {
  const _WebUnavailableView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.web_asset_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'Card scanning is not available on web',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Use the iOS or Android app to scan cards',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
