import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sport/slider.dart';

class SliderPainter extends CustomPainter {
  final double sliderPosition;
  final double dragPercentage;

  final Color color;
  final Paint fillPainter;
  final Paint sliderPainter;

  final double animationProgress;
  final SliderState sliderState;

  double _previousSliderPosition = 0;

  SliderPainter({
    @required this.sliderPosition,
    @required this.dragPercentage,
    @required this.color,
    @required this.animationProgress,
    @required this.sliderState,
  })  : fillPainter = new Paint()
          ..color = color
          ..style = PaintingStyle.fill,
        sliderPainter = new Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    _paintAnchors(canvas, size);

    switch (sliderState) {
      case (SliderState.START):
        _paintStarting(canvas, size);
        break;
      case (SliderState.STOP):
        _paintStopping(canvas, size);
        break;
      case (SliderState.SLIDE):
        _paintSliding(canvas, size);
        break;
      case (SliderState.REST):
        _paintResting(canvas, size);
        break;
      default:
        _paintResting(canvas, size);
        break;
    }
  }

  void _paintLine(Canvas canvas, Size size, SliderCurveDefinitions curve) {
    Path path = Path();
    path.moveTo(0.0, size.height);
    path.lineTo(curve.startOfBezier, size.height);
    path.cubicTo(
      curve.leftControlPoint1,
      size.height,
      curve.leftControlPoint2,
      curve.controlHeight,
      curve.centerPoint,
      curve.controlHeight,
    );
    path.cubicTo(
      curve.rightControlPoint1,
      curve.controlHeight,
      curve.rightControlPoint2,
      size.height,
      curve.endOfBezier,
      size.height,
    );
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, sliderPainter);
  }

  void _paintAnchors(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(0.0, size.height), 5.0, fillPainter);
    canvas.drawCircle(Offset(size.width, size.height), 5.0, fillPainter);
  }

  @override
  bool shouldRepaint(SliderPainter oldDelegate) {
    _previousSliderPosition = oldDelegate.sliderPosition;

    return true;
  }

  SliderCurveDefinitions _calculateSliderCurveDefinitions(Size size) {
    double minSliderHeight = size.height * 0.2;
    double maxSliderHeight = size.height * 0.8;

    double controlHeight =
        (size.height - minSliderHeight) - (maxSliderHeight * dragPercentage);

    double bendWidth = 20.0 + 20.0 * dragPercentage;
    double bezierWidth = 20.0 + 20.0 * dragPercentage;

    double startOfBend = sliderPosition - bendWidth / 2;
    double startOfBezier = startOfBend - bezierWidth;
    double endOfBend = sliderPosition + bendWidth / 2;
    double endOfBezier = endOfBend + bezierWidth;

    double centerPoint = sliderPosition;
    centerPoint = (centerPoint > size.width) ? size.width : centerPoint;

    startOfBend = (startOfBend <= 0.0) ? 0.0 : startOfBend;
    startOfBezier = (startOfBezier <= 0.0) ? 0.0 : startOfBezier;
    endOfBend = (endOfBend >= size.width) ? size.width : endOfBend;
    endOfBezier = (endOfBezier > size.width) ? size.width : endOfBezier;

    double leftControlPoint1 = startOfBend;
    double leftControlPoint2 = startOfBend;
    double rightControlPoint1 = endOfBend;
    double rightControlPoint2 = endOfBend;

    double bendability = 25.0;
    double maxSliderDifference = 20.0;

    double slideDifference = (sliderPosition - _previousSliderPosition).abs();
    slideDifference = (slideDifference > maxSliderDifference)
        ? maxSliderDifference
        : slideDifference;

    bool moveLeft = sliderPosition < _previousSliderPosition;

    double bend =
        lerpDouble(0.0, bendability, slideDifference / maxSliderDifference);
    bend = moveLeft ? -bend : bend;

    leftControlPoint1 = leftControlPoint1 + bend;
    leftControlPoint2 = leftControlPoint2 - bend;
    rightControlPoint1 = rightControlPoint1 - bend;
    rightControlPoint2 = rightControlPoint2 + bend;
    centerPoint = centerPoint - bend;

    SliderCurveDefinitions curve = SliderCurveDefinitions(
      bendWidth: bendWidth,
      bezierWidth: bezierWidth,
      startOfBend: startOfBend,
      startOfBezier: startOfBezier,
      endOfBend: endOfBend,
      endOfBezier: endOfBezier,
      controlHeight: controlHeight,
      centerPoint: centerPoint,
      leftControlPoint1: leftControlPoint1,
      leftControlPoint2: leftControlPoint2,
      rightControlPoint1: rightControlPoint1,
      rightControlPoint2: rightControlPoint2,
    );

    return curve;
  }

  void _paintStarting(Canvas canvas, Size size) {
    SliderCurveDefinitions curve = _calculateSliderCurveDefinitions(size);

    double height = lerpDouble(size.height, curve.controlHeight,
        Curves.elasticOut.transform(animationProgress));
    curve.controlHeight = height;
    _paintLine(canvas, size, curve);
  }

  void _paintStopping(Canvas canvas, Size size) {
    SliderCurveDefinitions curve = _calculateSliderCurveDefinitions(size);

    double height = lerpDouble(curve.controlHeight, size.height,
        Curves.elasticOut.transform(animationProgress));
    curve.controlHeight = height;
    _paintLine(canvas, size, curve);
  }

  void _paintSliding(Canvas canvas, Size size) {
    SliderCurveDefinitions curve = _calculateSliderCurveDefinitions(size);

    _paintLine(canvas, size, curve);
  }

  void _paintResting(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, sliderPainter);
  }
}

class SliderCurveDefinitions {
  final double bendWidth;
  final double bezierWidth;

  final double startOfBend;
  final double startOfBezier;
  final double endOfBend;
  final double endOfBezier;

  double controlHeight;
  final double centerPoint;

  final double leftControlPoint1;
  final double leftControlPoint2;
  final double rightControlPoint1;
  final double rightControlPoint2;

  SliderCurveDefinitions({
    this.bendWidth,
    this.bezierWidth,
    this.startOfBend,
    this.startOfBezier,
    this.endOfBend,
    this.endOfBezier,
    this.controlHeight,
    this.centerPoint,
    this.leftControlPoint1,
    this.leftControlPoint2,
    this.rightControlPoint1,
    this.rightControlPoint2,
  });
}
