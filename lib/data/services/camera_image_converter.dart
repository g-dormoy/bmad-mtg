import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Converts [CameraImage] frames to ML Kit's [InputImage] format.
///
/// Handles platform-specific image formats:
/// - Android: NV21
/// - iOS: BGRA8888
class CameraImageConverter {
  const CameraImageConverter._();

  /// Converts a [CameraImage] to an [InputImage] for ML Kit processing.
  ///
  /// Returns `null` if the image format is not supported or conversion fails.
  static InputImage? convertCameraImage(
    CameraImage image,
    CameraDescription camera,
  ) {
    final inputImageFormat = _getInputImageFormat(image.format.group);
    if (inputImageFormat == null) {
      return null;
    }

    final rotation = _getInputImageRotation(camera);
    if (rotation == null) {
      return null;
    }

    final bytes = _concatenatePlaneBytes(image.planes);

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: inputImageFormat,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  /// Concatenates all image plane bytes into a single buffer.
  static Uint8List _concatenatePlaneBytes(List<Plane> planes) {
    final allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  /// Maps camera image format to ML Kit input image format.
  ///
  /// Returns `null` for unsupported formats.
  static InputImageFormat? _getInputImageFormat(ImageFormatGroup format) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        if (format == ImageFormatGroup.nv21) {
          return InputImageFormat.nv21;
        }
        if (format == ImageFormatGroup.yuv420) {
          return InputImageFormat.yuv_420_888;
        }
        return null;
      case TargetPlatform.iOS:
        if (format == ImageFormatGroup.bgra8888) {
          return InputImageFormat.bgra8888;
        }
        return null;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return null;
    }
  }

  /// Calculates the input image rotation from camera sensor orientation.
  ///
  /// Returns `null` if the sensor orientation doesn't match a known rotation.
  static InputImageRotation? _getInputImageRotation(
    CameraDescription camera,
  ) {
    final sensorOrientation = camera.sensorOrientation;
    switch (sensorOrientation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return null;
    }
  }
}
