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

class PanelDisplay extends StatefulWidget{
  Function? verticalSplit;
  Function? horizontalSplit;
  Function? close;
  double top=0,bottom=0,left=0,right=0,width=0,hight=0;
  Color? color;

  PanelDisplay({super.key, top=0, bottom=0, left=0, right=0, this.verticalSplit, this.horizontalSplit, this.close, this.width=0, this.hight=0, this.color}){
    if(this.color==null){
      this.color=Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    }
  }

  @override
  State<StatefulWidget> createState() {
    return PanelDisplayState();
  }

}

class PanelDisplayState extends State<PanelDisplay>{

  @override
  Widget build(BuildContext context) {
    return Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: (){
                      widget.close!();
                    },
                    icon: Icon(Icons.clear),
                    splashRadius: 15.0,
                    tooltip: "Close",
                  ),
                  Spacer(flex: 1,),
                  IconButton(
                    onPressed: (){
                      widget.verticalSplit!();
                    },
                    icon: Transform.rotate(angle: math.pi/2, child: Icon(Icons.view_agenda_outlined,),),
                    padding: EdgeInsets.zero,
                    splashRadius: 15.0,
                    tooltip: "Split Right",
                  ),
                  IconButton(
                    onPressed: (){
                      widget.horizontalSplit!();
                    },
                    icon: Transform.rotate(angle: math.pi/2, child: Icon(Icons.width_normal_outlined,)),
                    padding: EdgeInsets.zero,
                    splashRadius: 15.0,
                    tooltip: "Split Down",
                  ),
                ],
              ),
              Expanded(child: Container(color: widget.color,),)

            ]
    );
  }
}

class Panel extends StatefulWidget{

  double width,height;
  double top=0,bottom=0,left=0,right=0;
  bool? onDrug;
  bool isVerticalSplit=false;
  bool isHorizontalSplit=false;
  bool isClose=false;
  Widget? child;
  Panel({super.key,required this.width,required this.height,this.top=0,this.bottom=0,this.left=0,this.right=0,this.onDrug,this.isHorizontalSplit=false,this.isVerticalSplit=false,this.child}){

  }

  @override
  State<Panel> createState() {
    return _PanelState();
  }

}

class _PanelState extends State<Panel>{

  @override
  Widget build(BuildContext context) {
    Widget splitPanel = PanelDisplay(
      verticalSplit: (){
        setState(() {
          widget.isVerticalSplit=true;
        });
      },
      horizontalSplit: (){
        setState(() {
          widget.isHorizontalSplit=true;
        });
      },
      close: (){
        setState(() {
          widget.isClose=true;
        });
      },
    );

    if(widget.isVerticalSplit){

      return Stack(
        children: [
          Positioned(
              top:0,bottom:0,left:0,right:widget.width/2,
              child: Panel(width: widget.width/2,height: widget.height,)
          ),
          Positioned(
              top:0,bottom:0,left:widget.width/2,right:0,
              child: Panel(width: widget.width/2,height: widget.height,)
          ),
        ],
      );
    } else if(widget.isHorizontalSplit){

      return Stack(
        children: [
          Positioned(
              top:0, bottom:widget.height/2, left:0, right:0,
              child: Panel(width: widget.width, height: widget.height/2,)
          ),
          Positioned(
              top:widget.height/2, bottom:0, left:0, right:0,
              child: Panel(width: widget.width, height: widget.height/2,)
          ),
        ],
      );

    } else{

      if(widget.isClose) {
        return PanelDisplay(
          verticalSplit: (){
            setState(() {
              widget.isVerticalSplit=true;
            });
          },
          horizontalSplit: (){
            setState(() {
              widget.isHorizontalSplit=true;
            });
          },
          close: (){
            setState(() {
              widget.isClose=true;
            });
          },
          color: Colors.transparent,
        );
      }

      return Stack(
        children: [
          Positioned(
              top:0,bottom:0,left:0,right:0,
              child: splitPanel
          ),
        ],
      );
    }
  }

}


class PanelSet extends StatefulWidget{

  List<Panel> PanelList=[];

  @override
  State<StatefulWidget> createState() {
    return PanelSetState();
  }
  
}

class PanelSetState extends State<PanelSet>{

  void horizontalSplit(){

  }

  void verticalSplit(){
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
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