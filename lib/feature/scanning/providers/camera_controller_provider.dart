import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mtg/feature/scanning/providers/camera_permission_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraControllerNotifier extends AsyncNotifier<CameraController> {
  CameraController? _controller;

  @override
  Future<CameraController> build() async {
    final permissionStatus = await ref.watch(cameraPermissionProvider.future);
    if (!permissionStatus.isGranted) {
      throw CameraException(
        'permissionDenied',
        'Camera permission is not granted',
      );
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw CameraException('noCameras', 'No cameras available on device');
    }

    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      backCamera,
      ResolutionPreset.medium,
    );

    await controller.initialize();
    _controller = controller;

    // Use _controller field so disposeCamera() can null it to prevent
    // double-dispose when Riverpod triggers onDispose during rebuild.
    ref.onDispose(() {
      _controller?.dispose();
      _controller = null;
    });

    return controller;
  }

  Future<void> disposeCamera() async {
    await _controller?.dispose();
    _controller = null;
  }

  Future<void> reinitialize() async {
    await _controller?.dispose();
    _controller = null;
    ref.invalidateSelf();
  }
}

final cameraControllerProvider =
    AsyncNotifierProvider<CameraControllerNotifier, CameraController>(
  CameraControllerNotifier.new,
);
