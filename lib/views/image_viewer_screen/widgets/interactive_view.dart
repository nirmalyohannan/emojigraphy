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
  InteractionController({this.imageAreaWidth, this.imageAreaHeight});

  double scale = 1.0;
  Offset _prevOffset = Offset.zero; //Offset of widget before pan
  Offset _panStartPoint = Offset.zero; //Position of touch where pan started
  Offset _changeInOffset = Offset.zero; //How much the widget has been moved
  Offset get offset => _prevOffset + _changeInOffset;

  void onDoubleTap() {
    if (scale > 1 || _prevOffset != Offset.zero) {
      //Already zoomed in
      //So zoom out
      scale = 1.0;
      //Also resetting the offset
      _prevOffset = Offset.zero;
    } else {
      //Zoom in
      scale = 4.0;
    }
    notifyListeners();
  }

  void onScaleStart(ScaleStartDetails details) {
    _panStartPoint = details.focalPoint;
  }

  void onScaleEnd(ScaleEndDetails details) {
    _prevOffset = _prevOffset +
        _changeInOffset; //To Fix the Offset, Comment this to reset at PanEnd
    if (imageAreaHeight != null && imageAreaWidth != null) {
      _prevOffset = Offset(
          clampDouble(
              _prevOffset.dx, -imageAreaWidth! / 10, imageAreaWidth! / 10),
          clampDouble(
              _prevOffset.dy, -imageAreaHeight! / 10, imageAreaHeight! / 10));
    }
    _changeInOffset = Offset.zero;
    notifyListeners();
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    _changeInOffset = details.focalPoint - _panStartPoint;
    _changeInOffset = _changeInOffset *
        (1 / scale); //This adjusts difference in changeInOffset due to scaling

    bool isPanning = _changeInOffset != Offset.zero;
    if (isPanning) {
      // offset = newOffset;
    } else {
      scale = details.scale;
    }
    notifyListeners();
  }
}
