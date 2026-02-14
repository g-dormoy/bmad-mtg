import 'package:flutter/material.dart';
import 'package:mtg/feature/scanning/models/recognition_state.dart';

/// Overlay widget that draws a semi-transparent mask with a
/// card-shaped cut-out (63:88 MTG aspect ratio), instructional
/// text, and an animated border that pulses green on
/// recognition.
class CardFrameOverlay extends StatefulWidget {
  const CardFrameOverlay({
    super.key,
    this.recognitionStatus = RecognitionStatus.idle,
  });

  /// Controls border color and animation.
  final RecognitionStatus recognitionStatus;

  @override
  State<CardFrameOverlay> createState() =>
      _CardFrameOverlayState();
}

class _CardFrameOverlayState extends State<CardFrameOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;

  /// Green color used for the recognition pulse.
  static const _recognizedColor = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _borderColorAnimation = ColorTween(
      begin: Colors.white,
      end: _recognizedColor,
    ).animate(_animationController);

    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant CardFrameOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recognitionStatus !=
        widget.recognitionStatus) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.recognitionStatus ==
        RecognitionStatus.recognized) {
      _animationController.forward();
    } else {
      // Instant reset to white (no reverse animation)
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _borderColorAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: CardFramePainter(
                  borderColor:
                      _borderColorAnimation.value ??
                          Colors.white,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).size.height *
                  0.15,
              child: const Text(
                'Position card within frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// MTG card aspect ratio: 63mm wide x 88mm tall.
@visibleForTesting
const double cardAspectRatio = 63 / 88;

/// Fraction of screen width the cut-out occupies.
const double _cutoutWidthFraction = 0.80;

/// Corner radius for the card cut-out rectangle.
const double _cutoutCornerRadius = 8;

/// Border stroke width around the cut-out.
const double _borderStrokeWidth = 2.5;

/// Paints the card frame overlay with configurable border
/// color.
@visibleForTesting
class CardFramePainter extends CustomPainter {
  const CardFramePainter({
    this.borderColor = Colors.white,
  });

  /// The color of the card frame border.
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cutoutWidth = size.width * _cutoutWidthFraction;
    final cutoutHeight = cutoutWidth / cardAspectRatio;

    final left = (size.width - cutoutWidth) / 2;
    final top = (size.height - cutoutHeight) / 2;

    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, cutoutWidth, cutoutHeight),
      const Radius.circular(_cutoutCornerRadius),
    );

    final fullRect =
        Rect.fromLTWH(0, 0, size.width, size.height);

    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6);
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _borderStrokeWidth;

    // Draw semi-transparent overlay with transparent cut-out
    canvas
      ..saveLayer(fullRect, Paint())
      ..drawRect(fullRect, overlayPaint)
      ..drawRRect(cardRect, clearPaint)
      ..restore()
      ..drawRRect(cardRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CardFramePainter oldDelegate) {
    return oldDelegate.borderColor != borderColor;
  }
}
