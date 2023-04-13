import 'dart:collection';

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
                Expanded(child: Container(constraints: BoxConstraints.expand(),color: Color((widget.signature.hashCode.toDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),child: Text(widget.signature),),)
              ]
          ),
        )
    );
  }

}

class PanelHashTableElement{
  // current split action state
  SplitDirection? state;

  PoS pos;

  PanelWidget content;

  PanelHashTableElement({
    this.state,
    required this.pos,
    required this.content,
  });
  
}

// panelHashTable use PanelNode's signature as key
var panelHashTable = <String, PanelHashTableElement>{};

// Position and Size
class PoS{
  // position
  double top,left;
  double ?bottom,right;
  // size
  double ?width, height;

  PoS({required this.top, required this.left, this.bottom, this.right, this.width, this.height});
  PoS.fromObj(PoS pos):
    top=pos.top,
    left=pos.left,
    right=pos.right,
    bottom=pos.bottom,
    width=pos.width,
    height=pos.height;

  // use copyWith deep copy, and select assign
  PoS copyWith({double? top, double? left, double? bottom, double? right, double? width, double? height}){
    return PoS(
      top: top ?? this.top,
      left: left ?? this.left,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  String toString() {
    return "top,left,bottom,right={$top, $left, $bottom, $right}, width,height={$width, $height}";
  }
}

class PanelNode{
  String signature;
  SplitDirection? state;
  PoS pos;
  PanelNode? parent;
  PanelNode? child1;
  PanelNode? child2;

  PanelNode(this.signature, this.pos, {this.state, this.child1, this.child2, this.parent});

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
  // find the leaf at the end
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
  // find the node at the begin
  PanelNode? findBeginNode(String signature, PanelNode? node){
    // print("===============================================================");
    // print("Node       =${node?.signature}");
    // print("Node.child1=${node?.child1?.signature}");
    // print("Node.child2=${node?.child2?.signature}");
    // print("===============================================================");
    PanelNode? pn=node;
    for(; pn?.parent?.signature==node?.signature; pn=pn?.parent){}

    return pn;
  }

  // according it's signature
  PanelNode? findNodeBrother(String signature){
    var leafNode=findLeafNode(signature,root);
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
  // 1. remove the node and it's brother node
  // 2. replace all nodes signature with the provided node's brother node's signature
  void removeNodeInTree(PanelNode? node){
    if(node!=null){
      // find brother and parent nodes
      PanelNode? brotherNode = findNodeBrother(node.signature);
      PanelNode? parentNode = brotherNode?.parent;

      // if node and brother are leaves
      if(brotherNode?.child1==null ||brotherNode?.child2==null){
        // 1. remove the two brothers
        parentNode?.child1=null;
        parentNode?.child2=null;
        // update parent children
        // parentNode?.child1=brotherNode?.child1;
        // brotherNode?.child1?.parent=parentNode;
        // parentNode?.child2=brotherNode?.child2;
        // brotherNode?.child2?.parent=parentNode;

        // print("parentNode?.child1=${parentNode?.child1}");
        // print("parentNode?.child2=${parentNode?.child2}");
        // print("node=${node}");
        // print("brother=${brotherNode}");

        // 2. 回溯 parents node
        for(PanelNode? pn=node.parent; pn?.signature==node.signature; pn=pn?.parent){
          if(brotherNode!=null){
            pn?.signature=brotherNode.signature;
          }
          print("pn.signature=${pn?.signature}");
        }

        //  cut off
        node.parent=null;
        brotherNode?.parent=null;
      }else{
      // if brother is child tree

        // 1. remove the two brothers
        parentNode?.child1=null;
        parentNode?.child2=null;

        // 2. 回溯 parents node
        for(PanelNode? pn=node.parent; pn?.signature==node.signature; pn=pn?.parent){
          if(brotherNode!=null){
            pn?.signature=brotherNode.signature;
          }
          print("pn.signature=${pn?.signature}");
        }

        brotherNode?.pos=parentNode!.pos.copyWith();
        // set new relation
        if(parentNode?.parent!=null){
          brotherNode?.parent=parentNode?.parent;
          if(parentNode?.parent?.child1?.signature==parentNode?.signature){
            parentNode?.parent?.child1=brotherNode;
          }else if(parentNode?.parent?.child2?.signature==parentNode?.signature){
            parentNode?.parent?.child2=brotherNode;
          }
        }else{
          root=brotherNode!;
          brotherNode.parent=null;
        }

        //  cut off old relation
        node.parent=null;


        // splitFromTree
        splitFromTree(brotherNode!);
      }

    }
  }

  // according it's signature
  // the child root node need defined PoS
  void splitFromTree(PanelNode child){

    Queue<PanelNode> stack=Queue();

    // init the stack
    stack.addLast(child);

    // pre-order traversal algorithm for binary trees
    while(stack.isNotEmpty){
      PanelNode curNode=stack.removeLast();
      panelHashTable[curNode.signature]?.pos = curNode.pos.copyWith();

      if(curNode.child1==null || curNode.child2==null){
        continue;
      }

      if(curNode.child1!=null && curNode.child2!=null){

        if(curNode.state==SplitDirection.vertical){
          // child1
          curNode.child1?.pos=curNode.pos.copyWith(
            right: curNode.pos.right!+curNode.pos.width!/2,
            width: curNode.pos.width!/2
          );

          panelHashTable[curNode.child1?.signature]?.pos = curNode.child1!.pos.copyWith();

          // child2
          curNode.child2?.pos=curNode.pos.copyWith(
              left: curNode.pos.left+curNode.pos.width!/2,
              width: curNode.pos.width!/2
          );

          panelHashTable[curNode.child2?.signature]?.pos=curNode.child2!.pos.copyWith();


        }else if(curNode.state==SplitDirection.horizontal){
          // child1
          curNode.child1?.pos=curNode.pos.copyWith(
              bottom: curNode.pos.bottom!+curNode.pos.height!/2,
              height: curNode.pos.height!/2
          );
          panelHashTable[curNode.child1?.signature]?.pos=curNode.child1!.pos.copyWith();

          // child2
          curNode.child2?.pos=curNode.pos.copyWith(
              top: curNode.pos.top+curNode.pos.height!/2,
              height: curNode.pos.height!/2
          );
          panelHashTable[curNode.child2?.signature]?.pos=curNode.child2!.pos.copyWith();

        }

        stack.addLast(curNode.child1!);
        stack.addLast(curNode.child2!);

      }

    }

  }

  // child1: old node, child2: new node
  void splitUp(String signature){
    print("splitUp ${signature}");
  }

  // child1: old node, child2: new node
  void splitDown(String signature){
    print("splitDown ${signature}");
    // 1. sign
    String newSignature=widget.sign();
    print("newSignature=$newSignature");

    // calculate PoS1 and PoS2

    PoS pos1 = panelHashTable[signature]!.pos.copyWith(
      bottom: panelHashTable[signature]!.pos.bottom!+panelHashTable[signature]!.pos.height!/2,
      height: panelHashTable[signature]!.pos.height!/2
    );

    PoS pos2 = panelHashTable[signature]!.pos.copyWith(
      top: panelHashTable[signature]!.pos.top+panelHashTable[signature]!.pos.height!/2,
      height: panelHashTable[signature]!.pos.height!/2,
    );

    // PoS pos1 = PoS.fromObj(panelHashTable[signature]!.pos);
    // pos1.bottom = panelHashTable[signature]!.pos.bottom!+panelHashTable[signature]!.pos.height!/2;
    // pos1.height = panelHashTable[signature]!.pos.height!/2;
    //
    // PoS pos2 = PoS.fromObj(panelHashTable[signature]!.pos);
    // pos2.top=panelHashTable[signature]!.pos.top+panelHashTable[signature]!.pos.height!/2;
    // pos2.height=panelHashTable[signature]!.pos.height!/2;


    setState(() {
      // 2. fill hash table
      // add new element
      panelHashTable[newSignature]=PanelHashTableElement(
        state: SplitDirection.horizontal,
        pos: pos2.copyWith(),
        content: PanelWidget(
          signature: newSignature,
          splitUp: splitUp,
          splitDown: splitDown,
          splitLeft: splitLeft,
          splitRight: splitRight,
          close: close,
        )
      );

      // modify old element
      panelHashTable[signature]!.state=SplitDirection.horizontal;
      panelHashTable[signature]!.pos.height=pos1.height;
      panelHashTable[signature]!.pos.bottom=pos1.bottom;

      // 3. complete node tree
      PanelNode? node=findLeafNode(signature,root);
      if(node!=null){
        var panelNode1=PanelNode(signature,pos1.copyWith()); panelNode1.parent=node;
        var panelNode2=PanelNode(newSignature,pos2.copyWith()); panelNode2.parent=node;
        node.state=SplitDirection.horizontal;
        node.child1=panelNode1;
        node.child2=panelNode2;
      }
      print("node        PoS=${node?.pos}");
      print("node.child1 PoS=${node?.child1?.pos}");
      print("node.child2 PoS=${node?.child2?.pos}");

    });
  }

  // child1: old node, child2: new node
  void splitLeft(String signature){
    print("splitLeft ${signature}");

  }

  // child1: old node, child2: new node
  void splitRight(String signature){
    print("splitRight ${signature}");
    // 1. sign
    String newSignature=widget.sign();
    print("newSignature=$newSignature");

    // calculate PoS1 and PoS2
    PoS pos1=panelHashTable[signature]!.pos.copyWith(
      right: panelHashTable[signature]!.pos.right!+panelHashTable[signature]!.pos.width!/2,
      width: panelHashTable[signature]!.pos.width!/2
    );

    PoS pos2=panelHashTable[signature]!.pos.copyWith(
      left: panelHashTable[signature]!.pos.left+panelHashTable[signature]!.pos.width!/2,
      width: panelHashTable[signature]!.pos.width!/2,
    );

    // PoS pos1=PoS.fromObj(panelHashTable[signature]!.pos);
    // pos1.right=panelHashTable[signature]!.pos.right!+panelHashTable[signature]!.pos.width!/2;
    // pos1.width=panelHashTable[signature]!.pos.width!/2;
    //
    // PoS pos2=PoS.fromObj(panelHashTable[signature]!.pos);
    // pos2.left=panelHashTable[signature]!.pos.left+panelHashTable[signature]!.pos.width!/2;
    // pos2.width=panelHashTable[signature]!.pos.width!/2;

    setState(() {
      // 2. fill hash table

      // add new element
      panelHashTable[newSignature]=PanelHashTableElement(
        pos: pos2.copyWith(),
        content: PanelWidget(
          signature: newSignature,
          splitUp: splitUp,
          splitDown: splitDown,
          splitLeft: splitLeft,
          splitRight: splitRight,
          close: close,
        )
      );

      // modify old element
      panelHashTable[signature]!.state=SplitDirection.vertical;
      panelHashTable[signature]!.pos.width=pos1.width;
      panelHashTable[signature]!.pos.right=pos1.right;

      // 3. complete node tree
      PanelNode? node=findLeafNode(signature,root);

      if(node!=null){
        var panelNode1=PanelNode(signature, pos1.copyWith()); panelNode1.parent=node;
        var panelNode2=PanelNode(newSignature, pos2.copyWith()); panelNode2.parent=node;
        node.state=SplitDirection.vertical;
        node.child1=panelNode1;
        node.child2=panelNode2;
      }

      print("node        PoS=${node?.pos}");
      print("node.child1 PoS=${node?.child1?.pos}");
      print("node.child2 PoS=${node?.child2?.pos}");

    });
    print("");

  }

  void close(String signature){
    print("close ${signature}");

    // 1. find brother and parent nodes
    PanelNode? node=findLeafNode(signature, root);
    PanelNode? brotherNode = findNodeBrother(signature);
    PanelNode? parentNode = brotherNode?.parent;

    print("node?.signature=${node?.signature}");
    print("brotherNode?.signature=${brotherNode?.signature}");
    print("parentNode?.signature=${parentNode?.signature}");
    print("node PoS       =${node?.pos}");
    print("brotherNode PoS=${brotherNode?.pos}");
    print("parentNode PoS =${parentNode?.pos}");

    setState(() {
      if(brotherNode == null){
        print("is root node");
        // is root node

      }else{
        // not root node

        // 2. update node tree
        // remove the node
        removeNodeInTree(node);

        // 3. update hashtable from node tree

        if(panelHashTable.containsKey(signature)){
          panelHashTable[brotherNode.signature]?.state = parentNode?.state;
          panelHashTable[brotherNode.signature]?.pos = parentNode!.pos.copyWith();
          panelHashTable.remove(signature);
        }

        // update hash table element's position and size
        // PanelNode? beginNode=findBeginNode(signature, node);
        // if(beginNode!=null){
        //   splitFromTree(beginNode);
        // }

      }

    });

  }

  @override
  void initState() {
    super.initState();
    String signature=widget.sign();
    print("signature=$signature");
    PoS pos=PoS(
      top: 0.0,
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      width: widget.maxWidth,
      height: widget.maxHeight,
    );
    root=PanelNode(signature, pos.copyWith());
    panelHashTable[signature]=PanelHashTableElement(
        pos: pos.copyWith(),
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
  void didUpdateWidget(covariant PanelTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("${widget.maxWidth},${widget.maxHeight}");
    root.pos= PoS(
      top: 0.0,
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      width: widget.maxWidth,
      height: widget.maxHeight,
    );
    splitFromTree(root);
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
          left: panelHashTable[k]?.pos.left,
          // right: panelHashTable[k]?.pos.right,
          top: panelHashTable[k]?.pos.top,
          // bottom: panelHashTable[k]?.pos.bottom,
          width: panelHashTable[k]?.pos.width,
          height: panelHashTable[k]?.pos.height,
          child: panelHashTable[k]!.content,
        );
      }).toList()
    );
  }

}


