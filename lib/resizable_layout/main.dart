import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main()=> runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      title: "resizable layout",
      home: Scaffold(
        body: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget{
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  bool clickRightPanelBar=false;
  bool clickLeftPanelBar=false;

  double rightPanel_width=50;
  double rightPanelBar_width=40;

  double leftPanel_width=50;
  double leftPanelBar_width=40;

  double bottomPanel_width=40;
  double bottomPanelBar_width=30;

  double VerticalDivider_width=1;
  double HorizontalDivider_height=1;

  // late double rightPanel_x;
  // late double leftPanel_x;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) => ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Stack(
            // alignment: AlignmentDirectional.centerStart,
            // fit: StackFit.expand,
            clipBehavior:  Clip.hardEdge,
            children: [

              // left panel buttonBar
              Positioned(
                top: 0,
                bottom: bottomPanelBar_width,
                left: 0,
                width: leftPanelBar_width,
                child: Container(
                    color: Colors.grey.shade300,
                    // height: double.maxFinite,
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(height: 6,),
                        Container(
                          color: Colors.grey.shade300,
                          width: leftPanelBar_width-5,
                          alignment: Alignment.center,

                          child:MaterialButton(
                            color: clickLeftPanelBar?Colors.blue:Colors.grey.shade300,
                            highlightElevation:0,
                            focusElevation:0,
                            hoverElevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                            ),
                            elevation:0,
                            onPressed: (){
                              setState(() {
                                clickLeftPanelBar=!clickLeftPanelBar;
                              });
                            },
                            child: Icon(Icons.explore_outlined,color: clickLeftPanelBar?Colors.white.withOpacity(0.8):Colors.black,),
                            // minWidth: 35,
                          ),
                        ),
                        Divider(),
                        Container(
                          color: Colors.grey.shade300,
                          width: leftPanelBar_width-5,
                          alignment: Alignment.center,

                          child:MaterialButton(
                            color: clickLeftPanelBar?Colors.blue:Colors.grey.shade300,
                            highlightElevation:0,
                            focusElevation:0,
                            hoverElevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                            ),
                            elevation:0,
                            onPressed: (){
                              setState(() {
                                clickLeftPanelBar=!clickLeftPanelBar;
                              });
                            },
                            child: Icon(Icons.explore_outlined,color: clickLeftPanelBar?Colors.white.withOpacity(0.8):Colors.black,),
                            // minWidth: 35,
                          ),
                        ),
                        Divider(),
                        Container(
                          color: Colors.grey.shade300,
                          width: leftPanelBar_width-5,
                          alignment: Alignment.center,

                          child:MaterialButton(
                            color: clickLeftPanelBar?Colors.blue:Colors.grey.shade300,
                            highlightElevation:0,
                            focusElevation:0,
                            hoverElevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                            ),
                            elevation:0,
                            onPressed: (){
                              setState(() {
                                clickLeftPanelBar=!clickLeftPanelBar;
                              });
                            },
                            child: Icon(Icons.explore_outlined,color: clickLeftPanelBar?Colors.white.withOpacity(0.8):Colors.black,),
                            // minWidth: 35,
                          ),
                        ),
                      ],
                    )
                ),
              ),

              clickLeftPanelBar? Positioned(
                  top:0,
                  bottom:bottomPanelBar_width,
                  left: leftPanelBar_width,
                  width: leftPanel_width+VerticalDivider_width,
                  child: Row(
                    children: [

                      // left panel
                      Container(color: Colors.red,width: leftPanel_width,),

                      // resizeLeftRight divider
                      VerticalDivider(
                        VerticalDivider_width:VerticalDivider_width,
                        onDrag: (dx){
                          // print("leftPanel_width+dx: ${leftPanel_width+dx}");
                          // print("leftPanel_width: ${leftPanel_width}");
                          // print("dx: ${dx}");
                          setState(() {
                            if(leftPanel_width+dx<=1){
                              leftPanel_width=1;
                            } else if(leftPanelBar_width+leftPanel_width+VerticalDivider_width+dx>=constraints.maxWidth-VerticalDivider_width-rightPanel_width-rightPanelBar_width){
                              leftPanel_width=constraints.maxWidth-VerticalDivider_width-rightPanel_width-rightPanelBar_width-1-leftPanelBar_width-VerticalDivider_width;
                            } else{
                                leftPanel_width+=dx;
                            }
                          });
                        },),

                    ],
                  )
              ):Positioned(
                top:0,
                bottom:bottomPanelBar_width,
                left: leftPanelBar_width,
                width: 0,
                child: Container(),
              ),


              // center content panel
              Positioned(
                top: 0,
                bottom: bottomPanelBar_width,
                left: clickLeftPanelBar?leftPanelBar_width+leftPanel_width+VerticalDivider_width:leftPanelBar_width,
                right: clickRightPanelBar?rightPanelBar_width+rightPanel_width+VerticalDivider_width:rightPanelBar_width,
                child: Container(color: Colors.green,),
              ),


              clickRightPanelBar? Positioned(
                  top: 0,
                  bottom: bottomPanelBar_width,
                  right: 0,
                  width: VerticalDivider_width+rightPanel_width+rightPanelBar_width,
                  child: Row(
                    children: [

                      // resizeLeftRight divider
                      VerticalDivider(
                        VerticalDivider_width:VerticalDivider_width,
                        onDrag: (dx){
                          setState(() {
                            if(rightPanel_width-dx<=1){
                              rightPanel_width=1;
                            }else if(constraints.maxWidth-VerticalDivider_width-(rightPanel_width-dx)-rightPanelBar_width<=leftPanelBar_width+leftPanel_width+VerticalDivider_width){
                              rightPanel_width=constraints.maxWidth-leftPanelBar_width-leftPanel_width-VerticalDivider_width-rightPanelBar_width-VerticalDivider_width-1;
                            } else{
                              rightPanel_width-=dx;
                            }
                          });
                        },),

                      // right panel
                      Container(color: Colors.blue, width: rightPanel_width,),
                    ],),
              ) : Positioned(
                top:0,
                bottom:bottomPanelBar_width,
                width: 0,
                right: rightPanelBar_width,
                child: Container(),
              ),

              // right panel buttonBar
              Positioned(
                top: 0,
                bottom: bottomPanelBar_width,
                right: 0,
                width: rightPanelBar_width,
                child: Container(color: Colors.grey.shade300,width: rightPanelBar_width,
                    // height: double.maxFinite,
                    alignment: Alignment.topCenter,
                    child: Column(
                      // alignment: MainAxisAlignment.center,
                      children: [
                        Container(height: 6,),
                        Container(
                          color: Colors.grey.shade300,
                          width: leftPanelBar_width-5,
                          alignment: Alignment.center,

                          child:MaterialButton(
                            color: clickRightPanelBar?Colors.blue:Colors.grey.shade300,
                            highlightElevation:0,
                            focusElevation:0,
                            hoverElevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                            ),
                            elevation:0,
                            onPressed: (){
                              setState(() {
                                clickRightPanelBar=!clickRightPanelBar;
                              });
                            },
                            child: Icon(Icons.account_tree_outlined,color: clickRightPanelBar?Colors.white.withOpacity(0.8):Colors.black,),
                            // minWidth: 35,
                          ),
                        ),
                        Divider(),
                        Container(
                          color: Colors.grey.shade300,
                          width: leftPanelBar_width-5,
                          alignment: Alignment.center,

                          child:MaterialButton(
                            color: clickRightPanelBar?Colors.blue:Colors.grey.shade300,
                            highlightElevation:0,
                            focusElevation:0,
                            hoverElevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                            ),
                            elevation:0,
                            onPressed: (){
                              setState(() {
                                clickRightPanelBar=!clickRightPanelBar;
                              });
                            },
                            child: Icon(Icons.account_tree_outlined,color: clickRightPanelBar?Colors.white.withOpacity(0.8):Colors.black,),
                            // minWidth: 35,
                          ),
                        ),
                        Divider(),
                        Container(
                          color: Colors.grey.shade300,
                          width: leftPanelBar_width-5,
                          alignment: Alignment.center,

                          child:MaterialButton(
                            color: clickRightPanelBar?Colors.blue:Colors.grey.shade300,
                            highlightElevation:0,
                            focusElevation:0,
                            hoverElevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                            ),
                            elevation:0,
                            onPressed: (){
                              setState(() {
                                clickRightPanelBar=!clickRightPanelBar;
                              });
                            },
                            child: Icon(Icons.account_tree_outlined,color: clickRightPanelBar?Colors.white.withOpacity(0.8):Colors.black,),
                            // minWidth: 35,
                          ),
                        ),
                      ],
                    )
                ),
              ),

              // bottom window
              Positioned(
                bottom: 0,
                height: bottomPanelBar_width,
                left: 0,
                right: 0,
                child: Container(
                  color: CupertinoColors.systemIndigo.color,
                  child: Row(
                    // alignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        color: CupertinoColors.systemIndigo.highContrastColor,
                        child: MaterialButton(
                          onPressed: () => {},
                          child: Icon(
                            Icons.settings_input_component,
                            color: CupertinoColors.extraLightBackgroundGray,
                          ),
                          // height: 20,
                          // minWidth: 20,
                        ),
                      ),
                      MaterialButton(
                        onPressed: ()=>{},
                        child: Icon(
                          Icons.refresh,
                          color: CupertinoColors.extraLightBackgroundGray,
                        ),
                        // height: 20,
                        // minWidth:20,
                      ),
                    ],
                  ),
                ),),

            ],
          ),

        ),
    );

  }
}



// resize LeftRight divider
class VerticalDivider extends StatefulWidget{

  final Function ? onDrag;
  final double VerticalDivider_width;
  const VerticalDivider({super.key,this.onDrag,this.VerticalDivider_width=1});

  @override
  State<VerticalDivider> createState() {
    return _VerticalDividerState();
  }

}

class _VerticalDividerState extends State<VerticalDivider>{

  late double start_x;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
          width: widget.VerticalDivider_width,
          color: Colors.transparent,
        ),
      ),
    );
  }

}

// resize TopBottom divider
class HorizontalDivider extends StatefulWidget{
  final Function ? onDrag;
  final double HorizontalDivider_height;
  const HorizontalDivider({super.key,this.onDrag,this.HorizontalDivider_height=1});

  @override
  _HorizontalDividerState createState() {
    return _HorizontalDividerState();
  }

}

class _HorizontalDividerState extends State<HorizontalDivider>{
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
          height: widget.HorizontalDivider_height,
          color: Colors.transparent,
        ),
      ),
    );
  }

}
