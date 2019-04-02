import 'package:flutter/material.dart';
import 'package:sport/slider_painter.dart';

class MySlider extends StatefulWidget {
  final double width;
  final double height;
  final Color color;

  final ValueChanged<double> onChanged;

  MySlider({
    this.width,
    this.height,
    this.color,
    @required this.onChanged,
  }) : assert(height >= 50 && height <= 600);

  _SliderState createState() => _SliderState();
}

class _SliderState extends State<MySlider> with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  double _dragPercentage = 0;

  SliderController _sliderController;

  @override
  void initState() {
    _sliderController = SliderController(vsync: this)
      ..addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _sliderController.dispose();
    super.dispose();
  }

  void _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    RenderBox box = context.findRenderObject();
    Offset offset = box.globalToLocal(update.globalPosition);

    _sliderController.setStateToSliding();
    _updateDragPosition(offset);
    _handleChangeStart(_dragPercentage);
  }

  void _onDragEnd(BuildContext context, DragEndDetails end) {
    _sliderController.setStateToStopping();

    setState(() {});
  }

  void _onDragStart(BuildContext context, DragStartDetails start) {
    RenderBox box = context.findRenderObject();
    Offset offset = box.globalToLocal(start.globalPosition);

    _sliderController.setStateToStart();
    _updateDragPosition(offset);
  }

  void _updateDragPosition(Offset value) {
    double newDragPosition = 0;

    if (value.dx <= 0) {
      newDragPosition = 0;
    } else if (value.dx >= widget.width) {
      newDragPosition = widget.width;
    } else {
      newDragPosition = value.dx;
    }

    setState(() {
      _dragPosition = newDragPosition;
      _dragPercentage = _dragPosition / widget.width;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        child: Container(
          width: widget.width,
          height: widget.height,
          child: CustomPaint(
            painter: SliderPainter(
              color: widget.color,
              dragPercentage: _dragPercentage,
              sliderPosition: _dragPosition,
              sliderState: _sliderController.state,
              animationProgress: _sliderController.progress,
            ),
          ),
        ),
        onHorizontalDragUpdate: (DragUpdateDetails update) =>
            _onDragUpdate(context, update),
        onHorizontalDragStart: (DragStartDetails start) =>
            _onDragStart(context, start),
        onHorizontalDragEnd: (DragEndDetails end) => _onDragEnd(context, end),
      ),
    );
  }

  void _handleChangeStart(double value) {
    assert(widget.onChanged != null);
    widget.onChanged(value);
  }
}

class SliderController extends ChangeNotifier {
  final AnimationController controller;
  SliderState _state = SliderState.REST;

  SliderController({
    @required TickerProvider vsync,
  }) : controller = AnimationController(vsync: vsync) {
    controller
      ..addListener(_onProgressUpdate)
      ..addStatusListener(_onStatusChanged);
  }

  double get progress => controller.value;

  SliderState get state => _state;

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _onTransitionComplete();
    }
  }

  void _onProgressUpdate() {
    notifyListeners();
  }

  void _onTransitionComplete() {
    if (_state == SliderState.STOP) {
      setStateToResting();
    }
  }

  void setStateToResting() {
    _state = SliderState.REST;
  }

  void setStateToStopping() {
    _startAnimation();
    _state = SliderState.STOP;
  }

  void setStateToSliding() {
    _state = SliderState.SLIDE;
  }

  void setStateToStart() {
    _startAnimation();
    _state = SliderState.START;
  }

  void _startAnimation() {
    controller.duration = Duration(milliseconds: 700);
    controller.forward(from: 0.0);
    notifyListeners();
  }
}

enum SliderState {
  START,
  REST,
  SLIDE,
  STOP,
}
