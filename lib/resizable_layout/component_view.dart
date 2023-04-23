import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/resizable_layout/common.dart';
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

class SharedMessage {
  String signature ="";
  double scale_x = 1.0;
  Offset pos = Offset(0, 0);
  SharedMessage(this.signature,[double? scale_x, Offset? pos]){
    this.scale_x = scale_x ?? 1.0;
    this.pos = pos?.copyWith() ?? Offset(0, 0);
  }
}

class SharedModel extends ChangeNotifier{
  // current select
  String signature="";

  // signature, value
  Map<String, SharedMessage> sharedMessage={};

  SharedModel();

  double get scale_x => this.sharedMessage[signature]?.scale_x ?? 1.0;

  Offset get pos => this.sharedMessage[signature]?.pos.copyWith() ?? Offset(0, 0);

  void resetScalePos(String signature){
    this.sharedMessage[signature]=SharedMessage(signature,1.0,Offset(0, 0));
    notifyListeners();
    print("change $signature");
  }

  void resetMultiScalePos(List<String> signatures){
    for(String signature in signatures){
      this.sharedMessage[signature]=SharedMessage(signature,1.0,Offset(0, 0));
      print("change $signature");
    }
    notifyListeners();
  }

  void changeScaleWithSignature(String signature, double scale_x, [double? scale_y]){
    this.signature=signature;
    this.sharedMessage.putIfAbsent(signature, () => SharedMessage(signature))..scale_x=scale_x;
    notifyListeners();
  }

  void changeScale(double scale_x, [double? scale_y]){
    this.sharedMessage.putIfAbsent(signature, () => SharedMessage(signature))..scale_x=scale_x;
    notifyListeners();
  }

  void saveScale(double scale_x, [double? scale_y]){
    print("saveScale $signature");
    this.sharedMessage.putIfAbsent(signature, () => SharedMessage(signature))..scale_x=scale_x;
  }

  void changePosWithSignature(String signature, Offset pos){
    this.signature=signature;
    this.sharedMessage.putIfAbsent(signature, () => SharedMessage(signature))..pos=pos.copyWith();
    notifyListeners();
  }

  void changePos(Offset pos){
    this.sharedMessage.putIfAbsent(signature, () => SharedMessage(signature))..pos=pos.copyWith();
    notifyListeners();
  }

  void savePos(Offset pos){
    this.sharedMessage.putIfAbsent(signature, () => SharedMessage(signature))..pos=pos.copyWith();
  }

  void removeSignature(String signature){
    this.sharedMessage.remove(signature);
    this.signature="";
    notifyListeners();
  }

  void changeSignature(String signature) {
    this.signature = signature;
    notifyListeners();
  }

  void saveSignature(String signature) {
    this.signature = signature;
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
  final double min=0.0001;
  final int divisions =40;
  final double buttonWidth=20;
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
                double scale_x=sharedModel.scale_x-2*widget.max/widget.divisions;                  sharedModel.changeSignature(sharedModel.signature);
                sharedModel.changeSignature(sharedModel.signature);

                if(scale_x>widget.min){
                  sharedModel.changeScale(scale_x);
                }else{
                  sharedModel.changeScale(widget.min);
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
                sharedModel.changeSignature(sharedModel.signature);

                if(scale_x>widget.min){
                  sharedModel.changeScale(scale_x);
                }else{
                  sharedModel.changeScale(widget.min);
                }
                // double scale_y=sharedModel.scale_y-2*widget.max/widget.divisions;
                // if(scale_y>=0){
                //   sharedModel.changeSignature(sharedModel.signature);
                //   sharedModel.changeScale(scale_y);
                // }
              },
              // hoverColor:  Colors.white,
              minWidth: widget.buttonWidth,
              child: Icon(
                Icons.remove,
                color: Colors.white.withAlpha(190),
                size: widget.buttonWidth,
              ),
            )
          ),
        SliderTheme(
          data: SliderThemeData(
            // trackHeight:4.0, //滑条宽度
            thumbColor: CupertinoColors.systemBlue, // 拖动控件的颜色
            overlayColor: Colors.transparent, // 光晕颜色
            activeTrackColor: CupertinoColors.activeOrange, // 已激活部分的颜色
            inactiveTrackColor: CupertinoColors.systemTeal.withOpacity(0.4), // 未激活部分的颜色
            overlayShape: SliderComponentShape.noOverlay,//左右padding
          ),
          child: Slider(
            autofocus: true,
            secondaryTrackValue:1,
            // inactiveColor: Colors.transparent,
            max: widget.max,
            min: widget.min,
            divisions: widget.divisions,
            value: sharedModel.scale_x,
            // label: (sharedModel.scale_x*100).toString()+"%",
            onChanged: (value) {
              setState(() {
                sharedModel.changeSignature(sharedModel.signature);
                sharedModel.changeScale(value);
              });
            },
          ),
        ),
        GestureDetector(
            onLongPressStart: (longPressStartDetails){
              timer = Timer.periodic(const Duration(milliseconds: 250), (t) {
                double scale_x=sharedModel.scale_x+2*widget.max/widget.divisions;
                sharedModel.changeSignature(sharedModel.signature);
                if(scale_x<=widget.max){
                  sharedModel.changeScale(scale_x);
                }else{
                  sharedModel.changeScale(widget.max);
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
                sharedModel.changeSignature(sharedModel.signature);
                if(scale_x<=widget.max){
                  sharedModel.changeScale(scale_x);
                }else{
                  sharedModel.changeScale(widget.max);
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
                size: widget.buttonWidth,
              ),
            )
        ),
        SizedBox(width: 10,),
        SizedBox(width: 50,
          child: Text((sharedModel.scale_x*100).toStringAsFixed(0).toString()+"%",
            style: TextStyle(color: CupertinoColors.activeOrange.darkHighContrastElevatedColor),
          ),
        )

      ],
    );
  }
}