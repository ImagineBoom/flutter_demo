import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// resize LeftRight divider
class PaneVerticalDivider extends StatefulWidget{

  Function ? onDrag;
  Function ? onHover;
  double PaneVerticalDivider_width;
  PaneVerticalDivider({super.key, this.onDrag, this.onHover, this.PaneVerticalDivider_width=1});

  @override
  State<PaneVerticalDivider> createState() {
    return _PaneVerticalDividerState();
  }

}

class _PaneVerticalDividerState extends State<PaneVerticalDivider>{

  late double start_x;
  bool isHovered=false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event){
        isHovered=true;
        widget.onHover!(2.0);
      },
      onEnter: (event){
        isHovered=true;
        widget.onHover!(2.0);
      },
      onExit: (event){
        isHovered=false;
        widget.onHover!(1.0);
      },
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        onHorizontalDragStart: (details){
          start_x=details.globalPosition.dx;
        },
        onHorizontalDragUpdate: (details){
          var dx=details.delta.dx;
          widget.onDrag!(dx);
        },
        child: Container(
          width: isHovered?widget.PaneVerticalDivider_width:widget.PaneVerticalDivider_width,
          color: isHovered?CupertinoColors.activeBlue:Colors.transparent,
        ),
      ),
    );
  }

}

// resize TopBottom divider
class PaneHorizontalDivider extends StatefulWidget{
  Function ? onDrag;
  double PaneHorizontalDivider_height;
  PaneHorizontalDivider({super.key,this.onDrag,this.PaneHorizontalDivider_height=1});

  @override
  _PaneHorizontalDividerState createState() {
    return _PaneHorizontalDividerState();
  }

}

class _PaneHorizontalDividerState extends State<PaneHorizontalDivider>{
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        onVerticalDragStart: (details){},
        onVerticalDragUpdate: (details){
          details.delta.dy;
        },
        child: Container(
          height: widget.PaneHorizontalDivider_height,
          color: Colors.transparent,
        ),
      ),
    );
  }

}

class Sliders extends StatefulWidget {
  const Sliders({super.key});

  @override
  State<Sliders> createState() => _SlidersState();
}

class _SlidersState extends State<Sliders> {
  double sliderValue1 = 100.0;

  @override
  Widget build(BuildContext context) {
    return Slider(
      max: 200,
      divisions: 10,
      value: sliderValue1,
      label: sliderValue1.round().toString(),
      onChanged: (value) {
        setState(() {
          sliderValue1 = value;
        });
      },
    );
  }
}