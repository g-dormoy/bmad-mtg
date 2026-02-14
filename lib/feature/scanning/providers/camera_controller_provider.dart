import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mtg/feature/scanning/providers/camera_permission_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Manages the [CameraController] lifecycle including image
/// streaming for the recognition pipeline.
class CameraControllerNotifier
    extends AsyncNotifier<CameraController> {
  CameraController? _controller;
  bool _isStreaming = false;

  @override
  Future<CameraController> build() async {
    final permissionStatus =
        await ref.watch(cameraPermissionProvider.future);
    if (!permissionStatus.isGranted) {
      throw CameraException(
        'permissionDenied',
        'Camera permission is not granted',
      );
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw CameraException(
        'noCameras',
        'No cameras available on device',
      );
    }

    final backCamera = cameras.firstWhere(
      (camera) =>
          camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      backCamera,
      ResolutionPreset.medium,
      imageFormatGroup:
          defaultTargetPlatform == TargetPlatform.android
              ? ImageFormatGroup.nv21
              : ImageFormatGroup.bgra8888,
    );

    await controller.initialize();
    _controller = controller;

    // Use _controller field so disposeCamera() can null it
    // to prevent double-dispose when Riverpod triggers
    // onDispose during rebuild.
    ref.onDispose(() {
      _stopStreamSync();
      _controller?.dispose();
      _controller = null;
    });

    return controller;
  }

  /// Starts the camera image stream, calling [onImage] for
  /// each frame.
  ///
  /// Does nothing if the controller is null or already
  /// streaming.
  Future<void> startImageStream(
    void Function(CameraImage) onImage,
  ) async {
    if (_controller == null || _isStreaming) return;
    await _controller!.startImageStream(onImage);
    _isStreaming = true;
  }

  /// Stops the camera image stream.
  ///
  /// Does nothing if not currently streaming.
  Future<void> stopImageStream() async {
    if (_controller == null || !_isStreaming) return;
    await _controller!.stopImageStream();
    _isStreaming = false;
  }

  /// Whether the camera is currently streaming images.
  bool get isStreaming => _isStreaming;

  Future<void> disposeCamera() async {
    await _stopStreamIfActive();
    await _controller?.dispose();
    _controller = null;
  }

  Future<void> reinitialize() async {
    await _stopStreamIfActive();
    await _controller?.dispose();
    _controller = null;
    ref.invalidateSelf();
  }

  Future<void> _stopStreamIfActive() async {
    if (_isStreaming && _controller != null) {
      await _controller!.stopImageStream();
      _isStreaming = false;
    }
  }

  /// Synchronous stream stop for use in onDispose callback.
  void _stopStreamSync() {
    if (_isStreaming && _controller != null) {
      _controller!.stopImageStream();
      _isStreaming = false;
    }
  }
}

final cameraControllerProvider = AsyncNotifierProvider<
    CameraControllerNotifier, CameraController>(
  CameraControllerNotifier.new,
);
