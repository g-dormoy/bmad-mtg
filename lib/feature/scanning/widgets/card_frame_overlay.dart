import 'package:flutter/material.dart';

/// Overlay widget that draws a semi-transparent mask with a card-shaped
/// cut-out (63:88 MTG aspect ratio) and instructional text.
class CardFrameOverlay extends StatelessWidget {
  const CardFrameOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _CardFramePainter(),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).size.height * 0.15,
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

class _CardFramePainter extends CustomPainter {
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

    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    final borderPaint = Paint()
      ..color = Colors.white
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
