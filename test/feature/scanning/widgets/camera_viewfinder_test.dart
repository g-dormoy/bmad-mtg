import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mtg/data/models/scryfall_card.dart';
import 'package:mtg/feature/scanning/models/add_card_state.dart';
import 'package:mtg/feature/scanning/models/recognition_state.dart';
import 'package:mtg/feature/scanning/providers/add_card_provider.dart';
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

class _TestAddCardNotifier extends AddCardNotifier {
  _TestAddCardNotifier(this._state);
  final AddCardState _state;

  bool addCardCalled = false;
  ScryfallCard? lastCard;

  @override
  AddCardState build() => _state;

  @override
  Future<void> addCard(ScryfallCard card) async {
    addCardCalled = true;
    lastCard = card;
  }
}

// ---------------------------------------------------------------------------
// Helper to build the widget with provider overrides
// ---------------------------------------------------------------------------

Widget _buildViewfinder({
  required CameraController controller,
  required RecognitionState recognitionState,
  AddCardState addCardState = const AddCardState.idle(),
  _TestAddCardNotifier? addCardNotifier,
}) {
  final notifier =
      addCardNotifier ?? _TestAddCardNotifier(addCardState);
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
      addCardProvider.overrideWith(() => notifier),
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

  group('CameraViewfinder add-card integration', () {
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
      'tapping ScanResultOverlay triggers addCard',
      (tester) async {
        final notifier = _TestAddCardNotifier(
          const AddCardState.idle(),
        );

        await tester.pumpWidget(
          _buildViewfinder(
            controller: mockController,
            recognitionState:
                const RecognitionState.recognized(_testCard),
            addCardNotifier: notifier,
          ),
        );
        await tester.pump();

        // Verify overlay is visible
        expect(
          find.byType(ScanResultOverlay),
          findsOneWidget,
        );

        // Tap the overlay
        await tester.tap(find.byType(ScanResultOverlay));
        await tester.pump();

        // Verify addCard was called with the correct card
        expect(notifier.addCardCalled, isTrue);
        expect(notifier.lastCard, _testCard);
      },
    );

    testWidgets(
      'AddedConfirmation widget appears when addCardState '
      'is added',
      (tester) async {
        await tester.pumpWidget(
          _buildViewfinder(
            controller: mockController,
            recognitionState:
                const RecognitionState.recognized(_testCard),
            addCardState: const AddCardState.added(),
          ),
        );
        await tester.pump();

        // "Added!" text should be visible
        expect(find.text('Added!'), findsOneWidget);
        // Check icon is present
        expect(
          find.byIcon(Icons.check_circle),
          findsOneWidget,
        );
        // ScanResultOverlay should NOT be visible
        expect(
          find.byType(ScanResultOverlay),
          findsNothing,
        );
      },
    );

    testWidgets(
      'ScanResultOverlay stays visible but untappable '
      'when addCardState is adding',
      (tester) async {
        final notifier = _TestAddCardNotifier(
          const AddCardState.adding(),
        );

        await tester.pumpWidget(
          _buildViewfinder(
            controller: mockController,
            recognitionState:
                const RecognitionState.recognized(_testCard),
            addCardState: const AddCardState.adding(),
            addCardNotifier: notifier,
          ),
        );
        await tester.pump();

        // Overlay stays visible for smooth crossfade
        expect(
          find.byType(ScanResultOverlay),
          findsOneWidget,
        );
        expect(find.text('Added!'), findsNothing);

        // Tap should be ignored (onTap is null)
        await tester.tap(find.byType(ScanResultOverlay));
        await tester.pump();
        expect(notifier.addCardCalled, isFalse);
      },
    );

    testWidgets(
      'viewfinder returns to idle state after add completes',
      (tester) async {
        await tester.pumpWidget(
          _buildViewfinder(
            controller: mockController,
            recognitionState: const RecognitionState.idle(),
          ),
        );
        await tester.pump();

        // No overlay, no confirmation
        expect(
          find.byType(ScanResultOverlay),
          findsNothing,
        );
        expect(find.text('Added!'), findsNothing);
      },
    );
  });
}
