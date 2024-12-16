import 'dart:ui';
import 'package:flutter/material.dart';

class InteractiveView extends StatefulWidget {
  final InteractionController? controller;
  final Widget Function(double scale, Offset offset) builder;
  const InteractiveView({super.key, required this.builder, this.controller});

  @override
  State<InteractiveView> createState() => _InteractiveViewState();
}

class _InteractiveViewState extends State<InteractiveView> {
  late InteractionController controller;
  @override
  void initState() {
    controller = widget.controller ?? InteractionController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onDoubleTap: controller.onDoubleTap,
        onScaleStart: controller.onScaleStart,
        onScaleUpdate: controller.onScaleUpdate,
        onScaleEnd: controller.onScaleEnd,
        child: LayoutBuilder(builder: (context, constraints) {
          controller.imageAreaHeight = constraints.maxHeight;
          controller.imageAreaWidth = constraints.maxWidth;
          return ListenableBuilder(
              listenable: controller,
              builder: (context, child) {
                return widget.builder(controller.scale, controller.offset);
              });
        }));
  }
}

class InteractionController extends ChangeNotifier {
  double? imageAreaWidth;
  double? imageAreaHeight;
  double minScale;
  double maxScale;
  InteractionController(
      {this.imageAreaWidth,
      this.imageAreaHeight,
      this.minScale = 0.8,
      this.maxScale = 8.0});

  //Zooming Variables
  double _prevScale = 1.0;
  double _changeInScale = 0;
  // double _pinchStartScale = 1.0;
  double get scale => (_prevScale + _changeInScale).clamp(minScale, maxScale);
  // double scale = 1;

  //Panning Variables
  Offset _prevOffset = Offset.zero; //Offset of widget before pan
  Offset _panStartPoint = Offset.zero; //Position of touch where pan started
  Offset _changeInOffset = Offset.zero; //How much the widget has been moved
  Offset get offset => _prevOffset + _changeInOffset;

  void onDoubleTap() {
    if (scale > 1 || _prevOffset != Offset.zero) {
      //Already zoomed in
      //So zoom out
      // scale = 1.0;
      _prevScale = 1.0;
      //Also resetting the offset
      _prevOffset = Offset.zero;
    } else {
      //Zoom in
      // scale = 4.0;
      _prevScale = 4.0;
      _clampPan();
    }
    notifyListeners();
  }

  void onScaleStart(ScaleStartDetails details) {
    _panStartPoint = details.focalPoint;
  }

  void onScaleEnd(ScaleEndDetails details) {
    //Complete Panning
    _prevOffset = _prevOffset +
        _changeInOffset; //To Fix the Offset, Comment this to reset at PanEnd
    _clampPan(); //Ensures Panning doesn't go beyond Screen bounds
    _changeInOffset = Offset.zero;

    //Complete Pinching
    _prevScale = scale;
    _changeInScale = 0;

    notifyListeners();
  }

  ///[_clampPan] Ensures Panning doesn't go beyond Screen bounds
  void _clampPan() {
    double clampFactor = 4.0;
    if (imageAreaHeight != null && imageAreaWidth != null) {
      _prevOffset = Offset(
          clampDouble(_prevOffset.dx, -imageAreaWidth! / clampFactor,
              imageAreaWidth! / clampFactor),
          clampDouble(_prevOffset.dy, -imageAreaHeight! / clampFactor,
              imageAreaHeight! / clampFactor));
    }
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    //Calculating Offset
    _changeInOffset = details.focalPoint - _panStartPoint;
    _changeInOffset = _changeInOffset *
        (1 / scale); //This adjusts difference in changeInOffset due to scaling

    //Calculating Scale
    bool isMultiTouch = details.pointerCount > 1;
    if (isMultiTouch) {
      //isMultiTouch therefore is pinching
      _changeInScale = (details.scale - 1) *
          2.5; //2.5 is a multiplier to make the zooming feel more natural
    }
    notifyListeners();
  }
}
