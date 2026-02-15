import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mtg/data/models/scryfall_card.dart';
import 'package:mtg/feature/scanning/models/recognition_state.dart';
import 'package:mtg/feature/scanning/providers/camera_controller_provider.dart';
import 'package:mtg/feature/scanning/providers/card_recognition_provider.dart';
import 'package:mtg/feature/scanning/providers/frame_processor_provider.dart';
import 'package:mtg/feature/scanning/widgets/camera_viewfinder.dart';
import 'package:mtg/feature/scanning/widgets/scan_result_overlay.dart';
import 'package:mtg/shared/constants/app_theme.dart';

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

const _testCard = ScryfallCard(
  id: 'test-id-123',
  name: 'Lightning Bolt',
  typeLine: 'Instant',
  manaCost: '{R}',
  cmc: 1,
  colors: ['R'],
  setCode: 'lea',
  setName: 'Limited Edition Alpha',
  rarity: 'common',
);

const _fakeCameraDescription = CameraDescription(
  name: 'fake-back',
  lensDirection: CameraLensDirection.back,
  sensorOrientation: 0,
);

// ---------------------------------------------------------------------------
// Mock CameraController using mocktail
// ---------------------------------------------------------------------------

class _MockCameraController extends Mock implements CameraController {
  final _listeners = <VoidCallback>[];
  CameraValue _value =
      const CameraValue.uninitialized(_fakeCameraDescription);

  @override
  CameraValue get value => _value;
  @override
  set value(CameraValue v) {
    _value = v;
    for (final listener in _listeners) {
      listener();
    }
  }

  @override
  void addListener(VoidCallback listener) =>
      _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _listeners.remove(listener);

  @override
  bool get hasListeners => _listeners.isNotEmpty;

  @override
  Widget buildPreview() => const SizedBox();

  @override
  CameraDescription get description => _value.description;
}

// ---------------------------------------------------------------------------
// Test Riverpod notifiers
// ---------------------------------------------------------------------------

class _TestCameraControllerNotifier
    extends CameraControllerNotifier {
  _TestCameraControllerNotifier(this._controller);
  final CameraController _controller;

  @override
  Future<CameraController> build() async => _controller;
}

class _TestCardRecognitionNotifier
    extends CardRecognitionNotifier {
  _TestCardRecognitionNotifier(this._state);
  final RecognitionState _state;

  @override
  RecognitionState build() => _state;
}

class _TestFrameProcessorNotifier
    extends FrameProcessorNotifier {
  @override
  bool build() => true;
}

// ---------------------------------------------------------------------------
// Helper to build the widget with provider overrides
// ---------------------------------------------------------------------------

Widget _buildViewfinder({
  required CameraController controller,
  required RecognitionState recognitionState,
}) {
  return ProviderScope(
    overrides: [
      cameraControllerProvider.overrideWith(
        () => _TestCameraControllerNotifier(controller),
      ),
      cardRecognitionProvider.overrideWith(
        () => _TestCardRecognitionNotifier(recognitionState),
      ),
      frameProcessorProvider.overrideWith(
        _TestFrameProcessorNotifier.new,
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: const Scaffold(body: CameraViewfinder()),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CameraViewfinder integration', () {
    late _MockCameraController mockController;

    setUp(() {
      mockController = _MockCameraController();
      mockController.value = mockController.value.copyWith(
        isInitialized: true,
        previewSize: const Size(1920, 1080),
        deviceOrientation: DeviceOrientation.portraitUp,
      );
    });

    testWidgets(
      'shows ScanResultOverlay when recognition status is '
      'recognized',
      (tester) async {
        await tester.pumpWidget(
          _buildViewfinder(
            controller: mockController,
            recognitionState:
                const RecognitionState.recognized(_testCard),
          ),
        );
        await tester.pump();

        expect(
          find.byType(ScanResultOverlay),
          findsOneWidget,
        );
        expect(find.text('Lightning Bolt'), findsOneWidget);
        expect(find.text('LEA'), findsOneWidget);
      },
    );

    testWidgets(
      'hides ScanResultOverlay when recognition status is idle',
      (tester) async {
        await tester.pumpWidget(
          _buildViewfinder(
            controller: mockController,
            recognitionState: const RecognitionState.idle(),
          ),
        );
        await tester.pump();

        expect(
          find.byType(ScanResultOverlay),
          findsNothing,
        );
      },
    );

    testWidgets(
      'hides ScanResultOverlay when recognition status is '
      'processing',
      (tester) async {
        await tester.pumpWidget(
          _buildViewfinder(
            controller: mockController,
            recognitionState:
                const RecognitionState.processing(),
          ),
        );
        await tester.pump();

        expect(
          find.byType(ScanResultOverlay),
          findsNothing,
        );
      },
    );

    testWidgets(
      'hides ScanResultOverlay when recognition status is '
      'error',
      (tester) async {
        await tester.pumpWidget(
          _buildViewfinder(
            controller: mockController,
            recognitionState:
                const RecognitionState.error('Network error'),
          ),
        );
        await tester.pump();

        expect(
          find.byType(ScanResultOverlay),
          findsNothing,
        );
      },
    );
  });
}
