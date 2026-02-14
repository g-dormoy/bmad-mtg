import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPermissionNotifier extends AsyncNotifier<PermissionStatus> {
  @override
  Future<PermissionStatus> build() async {
    final status = await Permission.camera.status;
    // If already granted or permanently denied, return immediately.
    if (status.isGranted || status.isPermanentlyDenied) {
      return status;
    }
    // Auto-request permission if not yet granted (AC #4).
    return Permission.camera.request();
  }

  Future<void> requestPermission() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final status = await Permission.camera.request();
      return status;
    });
  }

  Future<void> recheckPermission() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => Permission.camera.status);
  }
}

final cameraPermissionProvider =
    AsyncNotifierProvider<CameraPermissionNotifier, PermissionStatus>(
  CameraPermissionNotifier.new,
);
