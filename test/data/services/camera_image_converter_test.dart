import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mtg/data/services/camera_image_converter.dart';

class MockCameraImage extends Mock implements CameraImage {}

class MockPlane extends Mock implements Plane {}

class MockImageFormat extends Mock implements ImageFormat {}

void main() {
  group('CameraImageConverter', () {
    group('convertCameraImage', () {
      late MockCameraImage mockImage;
      late MockImageFormat mockFormat;
      late MockPlane mockPlane;
      const backCamera = CameraDescription(
        name: 'back',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      );

      setUp(() {
        mockImage = MockCameraImage();
        mockFormat = MockImageFormat();
        mockPlane = MockPlane();

        when(() => mockPlane.bytes)
            .thenReturn(Uint8List.fromList([1, 2, 3, 4]));
        when(() => mockPlane.bytesPerRow).thenReturn(2);
        when(() => mockImage.planes).thenReturn([mockPlane]);
        when(() => mockImage.width).thenReturn(320);
        when(() => mockImage.height).thenReturn(240);
        when(() => mockImage.format).thenReturn(mockFormat);
      });

      tearDown(() {
        debugDefaultTargetPlatformOverride = null;
      });

      test('returns null for unsupported image format on Android', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        when(() => mockFormat.group).thenReturn(ImageFormatGroup.jpeg);

        final result = CameraImageConverter.convertCameraImage(
          mockImage,
          backCamera,
        );

        expect(result, isNull);
      });

      test('returns null for unknown format group on iOS', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        when(() => mockFormat.group).thenReturn(ImageFormatGroup.unknown);

        final result = CameraImageConverter.convertCameraImage(
          mockImage,
          backCamera,
        );

        expect(result, isNull);
      });

      test('converts nv21 image on Android successfully', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        when(() => mockFormat.group).thenReturn(ImageFormatGroup.nv21);

        final result = CameraImageConverter.convertCameraImage(
          mockImage,
          backCamera,
        );

        expect(result, isNotNull);
      });

      test('converts yuv420 image on Android successfully', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        when(() => mockFormat.group).thenReturn(ImageFormatGroup.yuv420);

        final result = CameraImageConverter.convertCameraImage(
          mockImage,
          backCamera,
        );

        expect(result, isNotNull);
      });

      test('converts bgra8888 image on iOS successfully', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        when(() => mockFormat.group).thenReturn(ImageFormatGroup.bgra8888);

        final result = CameraImageConverter.convertCameraImage(
          mockImage,
          backCamera,
        );

        expect(result, isNotNull);
      });

      test('returns null for nv21 format on iOS', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        when(() => mockFormat.group).thenReturn(ImageFormatGroup.nv21);

        final result = CameraImageConverter.convertCameraImage(
          mockImage,
          backCamera,
        );

        expect(result, isNull);
      });

      test('returns null for bgra8888 format on Android', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        when(() => mockFormat.group).thenReturn(ImageFormatGroup.bgra8888);

        final result = CameraImageConverter.convertCameraImage(
          mockImage,
          backCamera,
        );

        expect(result, isNull);
      });

      test('returns null for unsupported platform', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.linux;

        when(() => mockFormat.group).thenReturn(ImageFormatGroup.nv21);

        final result = CameraImageConverter.convertCameraImage(
          mockImage,
          backCamera,
        );

        expect(result, isNull);
      });

      test('concatenates multiple plane bytes', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        final plane1 = MockPlane();
        when(() => plane1.bytes)
            .thenReturn(Uint8List.fromList([1, 2, 3, 4]));
        when(() => plane1.bytesPerRow).thenReturn(4);

        final plane2 = MockPlane();
        when(() => plane2.bytes)
            .thenReturn(Uint8List.fromList([5, 6, 7, 8]));
        when(() => plane2.bytesPerRow).thenReturn(4);

        when(() => mockImage.planes).thenReturn([plane1, plane2]);
        when(() => mockFormat.group).thenReturn(ImageFormatGroup.nv21);

        final result = CameraImageConverter.convertCameraImage(
          mockImage,
          backCamera,
        );

        expect(result, isNotNull);
      });

      test('returns null for invalid sensor orientation', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        when(() => mockFormat.group).thenReturn(ImageFormatGroup.nv21);

        const oddCamera = CameraDescription(
          name: 'back',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 45,
        );

        final result = CameraImageConverter.convertCameraImage(
          mockImage,
          oddCamera,
        );

        expect(result, isNull);
      });

      test('handles all valid sensor orientations', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        when(() => mockFormat.group).thenReturn(ImageFormatGroup.nv21);

        for (final orientation in [0, 90, 180, 270]) {
          final camera = CameraDescription(
            name: 'back',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: orientation,
          );

          final result = CameraImageConverter.convertCameraImage(
            mockImage,
            camera,
          );

          expect(
            result,
            isNotNull,
            reason: 'Failed for orientation $orientation',
          );
        }
      });
    });
  });
}
