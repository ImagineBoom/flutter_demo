import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

enum SplitDirection{ vertical, horizontal }

class PanelWidget extends StatefulWidget{
  final String signature;
  final bool isVerticalSplit=false;
  final bool isHorizonSplit=false;
  final Function(String signature) splitUp;
  final Function(String signature) splitDown;
  final Function(String signature) splitRight;
  final Function(String signature) splitLeft;
  final Function(String signature) close;

  const PanelWidget({super.key, required this.signature, required this.splitUp, required this.splitDown, required this.splitRight, required this.splitLeft, required this.close});

  @override
  State<PanelWidget> createState() {
    return PanelWidgetState();
  }

}

class PanelWidgetState extends State<PanelWidget> {

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) => ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: (){
                        widget.close(widget.signature);
                      },
                      icon: Icon(Icons.clear),
                      splashRadius: 15.0,
                      tooltip: "Close",
                    ),
                    Spacer(flex: 1,),
                    IconButton(
                      onPressed: (){
                        widget.splitRight(widget.signature);
                      },
                      icon: Transform.rotate(angle: math.pi/2, child: Icon(Icons.view_agenda_outlined,),),
                      padding: EdgeInsets.zero,
                      splashRadius: 15.0,
                      tooltip: "Split Right",
                    ),
                    IconButton(
                      onPressed: (){
                        widget.splitDown(widget.signature);
                      },
                      icon: Transform.rotate(angle: math.pi/2, child: Icon(Icons.width_normal_outlined,)),
                      padding: EdgeInsets.zero,
                      splashRadius: 15.0,
                      tooltip: "Split Down",
                    ),
                  ],
                ),
                Expanded(child: Container(constraints: BoxConstraints.expand(),color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),child: Text(widget.signature),),)
              ]
          ),
        )
    );
  }

}

class PanelHashTableElement{

  SplitDirection? state;

  // position
  double top,left;
  double ?bottom,right;
  // size
  double ?width, height;

  PanelWidget content;

  PanelHashTableElement({required this.content, this.state,
    this.height,  this.width,
    required this.left, this.right,
    required this.top, this.bottom});
  
}

// panelHashTable use PanelNode's signature as key
var panelHashTable = <String, PanelHashTableElement>{};

class PanelNode{

  String signature;
  PanelNode? parent;
  PanelNode? child1;
  PanelNode? child2;

  PanelNode(this.signature,{this.child1,this.child2,this.parent});

}

class PanelTree extends StatefulWidget{

  final double maxHeight;
  final double maxWidth;
  const PanelTree({super.key, required this.maxHeight, required this.maxWidth});

  @override
  State<PanelTree> createState() {
    return PanelTreeState();
  }

  String sign(){
    math.Random random = math.Random.secure();
    int high32 = random.nextInt(math.pow(2, 32)as int) ;
    random = math.Random.secure();
    int low32 = random.nextInt(math.pow(2, 32)as int) ;
    var randomInt64 = (high32 << 32) | low32;
    return "${DateTime.fromMicrosecondsSinceEpoch(DateTime.now().microsecondsSinceEpoch).toLocal()}${randomInt64}";
  }

}

class PanelTreeState extends State<PanelTree>{
  late PanelNode root;

  // from Node(signature), add new Node and it self as children
  void insertNode(String signature){

  }

  // according it's signature
  PanelNode? findLeafNode(String signature, PanelNode? node){
    // print("===============================================================");
    // print("Node       =${node?.signature}");
    // print("Node.child1=${node?.child1?.signature}");
    // print("Node.child2=${node?.child2?.signature}");
    // print("===============================================================");

    if(node==null){
      return null;
    }

    if(node.child2==null && node.child1==null && node.signature==signature){
      return node;
    }

    var leftNode = findLeafNode(signature, node.child1);
    if(leftNode!=null){
      return leftNode;
    }

    var rightNode = findLeafNode(signature, node.child2);
    if(rightNode!=null){
      return rightNode;
    }

    return null;
  }

  // according it's signature
  PanelNode? findNodeBrother(String signature, PanelNode? node){
    var leafNode=findLeafNode(signature,node);
    if(leafNode!=null){
      if(leafNode.parent?.child1?.signature != signature){
        return leafNode.parent?.child1;
      }else if(leafNode.parent?.child2?.signature != signature){
        return leafNode.parent?.child2;
      }
    }
    return null;
  }

  // according it's signature
  void splitFromTree(String signature){

  }

  void splitUp(String signature){
    print("splitUp ${signature}");
  }

  void splitDown(String signature){
    print("splitDown ${signature}");
    // 1. sign
    String newSignature=widget.sign();
    print("newSignature=$newSignature");

    setState(() {
      // 2. fill hash table
      var width=panelHashTable[signature]!.width;
      var height=panelHashTable[signature]!.height!/2;

      print("new top=${panelHashTable[signature]!.bottom!+height}");
      print("new bot=${panelHashTable[signature]!.bottom}");
      // add new element
      panelHashTable[newSignature]=PanelHashTableElement(
        state: SplitDirection.horizontal,
        top: panelHashTable[signature]!.top!+height,
        bottom: panelHashTable[signature]!.bottom,
        left: panelHashTable[signature]!.left,
        right: panelHashTable[signature]!.right,
        width: width,
        height: height,
        content: PanelWidget(
          signature: newSignature,
          splitUp: splitUp,
          splitDown: splitDown,
          splitLeft: splitLeft,
          splitRight: splitRight,
          close: close,
        )
      );

      print("old top=${panelHashTable[signature]!.top!}");
      print("old bot=${panelHashTable[signature]!.bottom!+height}");
      // modify old element
      panelHashTable[signature]!.state=SplitDirection.horizontal;
      panelHashTable[signature]!.height=height;
      panelHashTable[signature]!.bottom=panelHashTable[signature]!.bottom!+height;

      // 3. complete node tree
      PanelNode? node=findLeafNode(signature,root);
      if(node!=null){
        var panelNode1=PanelNode(signature);panelNode1.parent=node;
        var panelNode2=PanelNode(newSignature);panelNode2.parent=node;
        node.child1=panelNode1;
        node.child2=panelNode2;
      }
    });
    print("");
  }

  void splitLeft(String signature){
    print("splitLeft ${signature}");

  }

  void splitRight(String signature){
    print("splitRight ${signature}");
    // 1. sign
    String newSignature=widget.sign();
    print("newSignature=$newSignature");

    setState(() {
      // 2. fill hash table
      var width=panelHashTable[signature]!.width!/2;
      var height=panelHashTable[signature]!.height;

      print("new left =${panelHashTable[signature]!.left!+width}");
      print("new right=${panelHashTable[signature]!.right}");
      // add new element
      panelHashTable[newSignature]=PanelHashTableElement(
        top: panelHashTable[signature]!.top!,
        bottom: panelHashTable[signature]!.bottom,
        left: panelHashTable[signature]!.left!+width,
        right: panelHashTable[signature]!.right,
        width: width,
        height: height,
        content: PanelWidget(
          signature: newSignature,
          splitUp: splitUp,
          splitDown: splitDown,
          splitLeft: splitLeft,
          splitRight: splitRight,
          close: close,
        )
      );

      print("old left =${panelHashTable[signature]!.left!}");
      print("old right=${panelHashTable[signature]!.right!+width}");
      // modify old element
      panelHashTable[signature]!.state=SplitDirection.vertical;
      panelHashTable[signature]!.width=width;
      panelHashTable[signature]!.right=panelHashTable[signature]!.right!+width;

      // 3. complete node tree
      PanelNode? node=findLeafNode(signature,root);
      if(node!=null){
        var panelNode1=PanelNode(signature);panelNode1.parent=node;
        var panelNode2=PanelNode(newSignature);panelNode2.parent=node;
        node.child1=panelNode1;
        node.child2=panelNode2;
      }

    });
    print("");

  }

  void close(String signature){
    print("close ${signature}");

    // 1. find brother and parent nodes
    PanelNode? brotherNode = findNodeBrother(signature, root);
    PanelNode? parentNode = brotherNode?.parent;
    setState(() {
      if(brotherNode == null){
        print("is root node");
        // is root node

      }else{
        // not root node


        // 2. update hash table
        // resize brother Tree element
        if(panelHashTable[parentNode?.signature]?.state == SplitDirection.vertical){
          if(panelHashTable.containsKey(brotherNode.signature)){
            panelHashTable[brotherNode.signature]?.width = panelHashTable[brotherNode.signature]!.width! *2;
            panelHashTable[brotherNode.signature]?.left = panelHashTable[parentNode?.signature]!.left;
            panelHashTable[brotherNode.signature]?.right =  math.min(panelHashTable[signature]!.right!, panelHashTable[brotherNode.signature]!.right!);
          }
          print("close state=${panelHashTable[parentNode?.signature]?.state}");
        }else if(panelHashTable[parentNode?.signature]?.state == SplitDirection.horizontal){
          if(panelHashTable.containsKey(brotherNode.signature)){
            panelHashTable[brotherNode.signature]?.height = panelHashTable[brotherNode.signature]!.height! *2;
            panelHashTable[brotherNode.signature]?.top = panelHashTable[parentNode?.signature]!.top;
            panelHashTable[brotherNode.signature]?.bottom =  math.min(panelHashTable[signature]!.bottom!, panelHashTable[brotherNode.signature]!.bottom!);
          }
          print("close state=${panelHashTable[parentNode?.signature]?.state}");

        }
        // delete this element
        panelHashTable.remove(signature);

        // 3. update node tree

        // replace their parent signature with brother's signature
        parentNode?.signature=brotherNode.signature;
        // remove the two brothers
        parentNode?.child1=null;
        parentNode?.child2=null;

      }

    });

  }

  @override
  void initState() {
    super.initState();
    String signature=widget.sign();
    print("signature=$signature");
    var panelNode=PanelNode(signature);
    root=panelNode;
    panelHashTable[signature]=PanelHashTableElement(
        top: 0.0,
        bottom: 0.0,
        left: 0.0,
        right: 0.0,
        width: widget.maxWidth,
        height: widget.maxHeight,
        content: PanelWidget(
          signature: signature,
          splitUp: splitUp,
          splitDown: splitDown,
          splitLeft: splitLeft,
          splitRight: splitRight,
          close: close,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    print("panelHashTable.keys.len=${panelHashTable.keys.length}");

    return Stack(
      children: panelHashTable.keys.toList().map((k) {
        // print("k=$k");
        // print("panelHashTable[k]?.content.left=${panelHashTable[k]?.content.left}");
        // print("panelHashTable[k]?.content.right,=${panelHashTable[k]?.content.right}");
        // print("panelHashTable[k]?.content.width=${panelHashTable[k]?.content.width}");
        return Positioned(
          left: panelHashTable[k]?.left,
          // right: panelHashTable[k]?.right,
          top: panelHashTable[k]?.top,
          // bottom: panelHashTable[k]?.bottom,
          width: panelHashTable[k]?.width,
          height: panelHashTable[k]?.height,
          child: panelHashTable[k]!.content,
        );
      }).toList()
    );
  }

}


