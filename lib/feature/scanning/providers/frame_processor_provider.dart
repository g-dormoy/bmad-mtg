import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mtg/data/services/camera_image_converter.dart';
import 'package:mtg/feature/scanning/providers/camera_controller_provider.dart';
import 'package:mtg/feature/scanning/providers/card_recognition_provider.dart';

/// Orchestrates the frame → recognition pipeline by bridging
/// the camera image stream to the card recognition notifier.
///
/// State is `true` when actively streaming frames, `false`
/// otherwise.
class FrameProcessorNotifier extends Notifier<bool> {
  DateTime? _lastProcessedAt;
  CameraDescription? _activeCamera;

  /// Minimum interval between processed frames (500ms).
  static const _throttleInterval = Duration(milliseconds: 500);

  @override
  bool build() {
    ref.watch(cameraControllerProvider).whenData((controller) {
      if (controller.value.isInitialized) {
        _startStreaming(controller);
      }
    });

    ref.onDispose(_cleanup);

    return false;
  }

  Future<void> _startStreaming(
    CameraController controller,
  ) async {
    _activeCamera = controller.description;

    final cameraNotifier = ref.read(
      cameraControllerProvider.notifier,
    );

    if (cameraNotifier.isStreaming) return;

    await cameraNotifier.startImageStream(_onFrame);
    state = true;
  }

  void _onFrame(CameraImage image) {
    final now = DateTime.now();

    // Throttle: process at most 1 frame every 500ms
    if (_lastProcessedAt != null &&
        now.difference(_lastProcessedAt!) < _throttleInterval) {
      return;
    }
    _lastProcessedAt = now;

    final camera = _activeCamera;
    if (camera == null) return;

    final inputImage =
        CameraImageConverter.convertCameraImage(image, camera);
    if (inputImage == null) return;

    ref
        .read(cardRecognitionProvider.notifier)
        .processFrame(inputImage);
  }

  void _cleanup() {
    // Best-effort stream stop – if the camera controller is
    // already disposed this is a no-op.
    try {
      ref
          .read(cameraControllerProvider.notifier)
          .stopImageStream();
    } catch (_) {
      // Camera controller may already be disposed.
    }
    _lastProcessedAt = null;
    _activeCamera = null;
  }

  /// Stops the image stream and resets processing state.
  Future<void> stop() async {
    final cameraNotifier = ref.read(
      cameraControllerProvider.notifier,
    );
    await cameraNotifier.stopImageStream();
    _lastProcessedAt = null;
    state = false;
  }
}

/// Provides the frame processor state (true = streaming).
final frameProcessorProvider =
    NotifierProvider<FrameProcessorNotifier, bool>(
  FrameProcessorNotifier.new,
);
