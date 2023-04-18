import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';

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

class SharedModel extends ChangeNotifier{
  String signature ="";
  double scale_x = 1.0;
  double scale_y = 1.0;
  Offset pos = Offset(0, 0);

  SharedModel();

  SharedModel.withCopy([String? signature, double? scale_x, double? scale_y]){
    this.signature=signature?? this.signature;
    this.scale_x=scale_x??this.scale_x;
    this.scale_y=scale_y??this.scale_y;
    notifyListeners();
  }

  void changeScale(double scale_x, [double? scale_y]){
    this.scale_x=scale_x;
    this.scale_y=scale_y??this.scale_y;
    notifyListeners();
  }

  void changePos(Offset pos){
    this.pos=pos;
    notifyListeners();
  }

  void changeSignature(String signature){
    this.signature=signature;
    notifyListeners();
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

class ScaleSlider extends StatefulWidget {
  const ScaleSlider({super.key});
  final double max=10.0;
  final int divisions =40;
  final double buttonWidth=30;
  @override
  State<ScaleSlider> createState() => _SlidersState();
}

class _SlidersState extends State<ScaleSlider> {
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    SharedModel sharedModel=context.watch<SharedModel>();

    return Row(
      children: [
        GestureDetector(
            onLongPressStart: (longPressStartDetails){
              timer = Timer.periodic(const Duration(milliseconds: 250), (t) {
                double scale_x=sharedModel.scale_x-2*widget.max/widget.divisions;
                if(scale_x>=0){
                  sharedModel.changeSignature(sharedModel.signature);
                  sharedModel.changeScale(scale_x);
                }

                // double scale_y=sharedModel.scale_y-2*widget.max/widget.divisions;
                // if(scale_y>=0){
                //   sharedModel.changeSignature(sharedModel.signature);
                //   sharedModel.changeScale(scale_y);
                // }
              });
              print("onLongPressStart");
            },
            onLongPressEnd: (longPressStartDetails){
              timer?.cancel();
              print("onLongPressEnd");
            },
            child: MaterialButton(
              padding: EdgeInsets.zero,
              highlightElevation:0,
              focusElevation:0,
              hoverElevation: 0,
              disabledElevation:0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
              ),
              elevation:0,
              onPressed: (){
                double scale_x=sharedModel.scale_x-2*widget.max/widget.divisions;
                if(scale_x>=0){
                  sharedModel.changeSignature(sharedModel.signature);
                  sharedModel.changeScale(scale_x);
                }

                // double scale_y=sharedModel.scale_y-2*widget.max/widget.divisions;
                // if(scale_y>=0){
                //   sharedModel.changeSignature(sharedModel.signature);
                //   sharedModel.changeScale(scale_y);
                // }
              },
              // hoverColor:  Colors.white,
              minWidth: widget.buttonWidth,
              child: Icon(Icons.remove, color: Colors.white.withAlpha(190),),
            )
          ),

        Slider(
          max: widget.max,
          divisions: widget.divisions,
          value: sharedModel.scale_x,
          label: sharedModel.scale_x.toStringAsFixed(2).toString(),
          onChanged: (value) {
            setState(() {
              sharedModel.changeSignature(sharedModel.signature);
              sharedModel.changeScale(value);
            });
          },
        ),

        GestureDetector(
            onLongPressStart: (longPressStartDetails){
              timer = Timer.periodic(const Duration(milliseconds: 250), (t) {
                double scale_x=sharedModel.scale_x+2*widget.max/widget.divisions;
                if(scale_x<=10){
                  sharedModel.changeSignature(sharedModel.signature);
                  sharedModel.changeScale(scale_x);
                }

                // double scale_y=sharedModel.scale_y+2*widget.max/widget.divisions;
                // if(scale_y<=10){
                //   sharedModel.changeSignature(sharedModel.signature);
                //   sharedModel.changeScale(scale_y);
                // }
              });
              print("onLongPressStart");
            },
            onLongPressEnd: (longPressStartDetails){
              timer?.cancel();
              print("onLongPressEnd");
            },

            child: MaterialButton(
              padding: EdgeInsets.zero,
              highlightElevation:0,
              focusElevation:0,
              hoverElevation: 0,
              disabledElevation:0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
              ),
              elevation:0,
              onPressed: (){
                double scale_x=sharedModel.scale_x+2*widget.max/widget.divisions;
                if(scale_x<=10){
                  sharedModel.changeSignature(sharedModel.signature);
                  sharedModel.changeScale(scale_x);
                }

                // double scale_y=sharedModel.scale_y+2*widget.max/widget.divisions;
                // if(scale_y<=10){
                //   sharedModel.changeSignature(sharedModel.signature);
                //   sharedModel.changeScale(scale_y);
                // }
              },
              // hoverColor:  Colors.white,
              minWidth: widget.buttonWidth,
              child: Icon(
                Icons.add,
                color: Colors.white.withAlpha(190),
              ),
            )
        ),
      ],
    );
  }
}