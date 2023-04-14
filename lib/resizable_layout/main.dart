import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_demo/resizable_layout/component_view.dart';

import 'package:flutter_demo/resizable_layout/view_engine.dart';

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

  double centerPanelBar_height=30;

  double rightPanel_width=300;
  double rightPanelBar_width=40;

  double leftPanel_width=300;
  double leftPanelBar_width=40;

  double bottomPanelBar_height=30;
  double bottomPanel_height=40;

  double PaneVerticalDivider_width=1;
  double PaneHorizontalDivider_height=1;

  // late double rightPanel_x;
  // late double leftPanel_x;
  void horizontalSplit(){

  }

  void verticalSplit(){
    setState(() {
    });
  }

  @override
  void initState() {
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

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
                bottom: bottomPanelBar_height,
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
                            color: Colors.grey.shade300,
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
                            child: Icon(Icons.explore_outlined,color: Colors.black,),
                            // minWidth: 35,
                          ),
                        ),
                        Divider(),
                        Container(
                          color: Colors.grey.shade300,
                          width: leftPanelBar_width-5,
                          alignment: Alignment.center,

                          child:MaterialButton(
                            color: Colors.grey.shade300,
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
                            child: Icon(Icons.explore_outlined,color: Colors.black,),
                            // minWidth: 35,
                          ),
                        ),
                      ],
                    )
                ),
              ),

              clickLeftPanelBar ? Positioned(
                  top:0,
                  bottom:bottomPanelBar_height,
                  left: leftPanelBar_width,
                  width: leftPanel_width+PaneVerticalDivider_width,
                  child: Row(
                    children: [

                      // left panel
                      Container(color: Colors.red,width: leftPanel_width,),

                      // resizeLeftRight divider
                      PaneVerticalDivider(
                        PaneVerticalDivider_width:PaneVerticalDivider_width,
                        onDrag: (dx){
                          // print("leftPanel_width+dx: ${leftPanel_width+dx}");
                          // print("leftPanel_width: ${leftPanel_width}");
                          // print("dx: ${dx}");
                          setState(() {
                            if(leftPanel_width+dx<=1){
                              leftPanel_width=1;
                            } else if(leftPanelBar_width+leftPanel_width+PaneVerticalDivider_width+dx>=constraints.maxWidth-PaneVerticalDivider_width-rightPanel_width-rightPanelBar_width){
                              leftPanel_width=constraints.maxWidth-PaneVerticalDivider_width-rightPanel_width-rightPanelBar_width-1-leftPanelBar_width-PaneVerticalDivider_width;
                            } else{
                                leftPanel_width+=dx;
                            }
                          });
                        },
                        onHover: (double width){
                          setState(() {
                            PaneVerticalDivider_width=width;
                          });
                        },
                      ),

                    ],
                  )
              ) : Positioned(
                top:0,
                bottom:bottomPanelBar_height,
                left: leftPanelBar_width,
                width: 0,
                child: Container(),
              ),

              // center content panel
              Positioned(
                top: 0,
                bottom: bottomPanelBar_height,
                left: clickLeftPanelBar?leftPanelBar_width+leftPanel_width+PaneVerticalDivider_width:leftPanelBar_width,
                right: clickRightPanelBar?rightPanelBar_width+rightPanel_width+PaneVerticalDivider_width:rightPanelBar_width,
                child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                  return PanelTree(
                    maxWidth: constraints.maxWidth,
                    maxHeight: constraints.maxHeight,
                  );
                }),
              ),

              clickRightPanelBar ? Positioned(
                  top: 0,
                  bottom: bottomPanelBar_height,
                  right: 0,
                  width: PaneVerticalDivider_width+rightPanel_width+rightPanelBar_width,
                  child: Row(
                    children: [

                      // resizeLeftRight divider
                      PaneVerticalDivider(
                        PaneVerticalDivider_width:PaneVerticalDivider_width,
                        onDrag: (dx){
                          setState(() {
                            if(rightPanel_width-dx<=1){
                              rightPanel_width=1;
                            }else if(constraints.maxWidth-PaneVerticalDivider_width-(rightPanel_width-dx)-rightPanelBar_width<=leftPanelBar_width+leftPanel_width+PaneVerticalDivider_width){
                              rightPanel_width=constraints.maxWidth-leftPanelBar_width-leftPanel_width-PaneVerticalDivider_width-rightPanelBar_width-PaneVerticalDivider_width-1;
                            } else{
                              rightPanel_width-=dx;
                            }
                          });
                        },
                        onHover: (double width){
                          setState(() {
                            PaneVerticalDivider_width=width;
                          });
                        },
                      ),

                      // right panel
                      Container(color: Colors.blue, width: rightPanel_width,),
                    ],
                  ),
              ) : Positioned(
                top:0,
                bottom:bottomPanelBar_height,
                width: 0,
                right: rightPanelBar_width,
                child: Container(),
              ),

              // right panel buttonBar
              Positioned(
                top: 0,
                bottom: bottomPanelBar_height,
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
                            color: Colors.grey.shade300,
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
                            child: Icon(Icons.account_tree_outlined,color:Colors.black,),
                            // minWidth: 35,
                          ),
                        ),
                        Divider(),
                        Container(
                          color: Colors.grey.shade300,
                          width: leftPanelBar_width-5,
                          alignment: Alignment.center,

                          child:MaterialButton(
                            color: Colors.grey.shade300,
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
                            child: Icon(Icons.account_tree_outlined,color: Colors.black,),
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
                height: bottomPanelBar_height,
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
                            color: CupertinoColors.extraLightBackgroundGray.withAlpha(220),
                          ),
                          // height: 20,
                          // minWidth: 20,
                        ),
                      ),
                      MaterialButton(
                        onPressed: ()=>{},
                        child: Icon(
                          Icons.refresh,
                          color: CupertinoColors.extraLightBackgroundGray.withAlpha(220),
                        ),
                        // height: 20,
                        // minWidth:20,
                      ),
                      Spacer(flex: 24),
                      Row(
                        children: [
                          Icon(Icons.remove,color: Colors.white.withAlpha(190),),
                          Sliders(),
                          Icon(Icons.add,color: Colors.white.withAlpha(190),),
                        ],
                      ),
                      Spacer(flex: 1),
                    ],

                  ),
                ),),

            ],
          ),

        ),
    );

  }
}




