
import 'package:flutter/material.dart';
import 'package:flutter_demo/isolate/model/isolate.dart';
import 'package:flutter_demo/isolate/model/isolate_fw.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget{
  HomePage({super.key});

  // Future<void> newIsolate() async{
  //   await IsolateModel().main([]);
  // }

  @override
  Widget build(BuildContext context) {


    var isolateModel = context.watch<IsolateModel>();
    var isolateModel_fw = context.watch<IsolateModel_fw>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Demo', style: Theme.of(context).textTheme.displayLarge),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.yellow,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(2),
                child: MessageList(),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Row(
        children: [
          MaterialButton(
            onPressed: () async=> {
              isolateModel_fw.setIsClick(false),
              await isolateModel.main([])
            },
            color: Colors.greenAccent,
            child: Text("new Isolate"),
          ),
          MaterialButton(
            onPressed: () async=> {
              isolateModel.setIsClick(false),
              await isolateModel_fw.main([]),
            },
            color: Colors.greenAccent,
            child: Text("new Isolate fw"),
          ),
        ],
      ),
    );
  }
}

class MessageList extends StatelessWidget {
  MessageList({super.key});

  @override
  Widget build(BuildContext context) {
    var itemNameStyle = Theme.of(context).textTheme.titleLarge;
    // This gets the current state of CartModel and also tells Flutter
    // to rebuild this widget when CartModel notifies listeners (in other words,
    // when it changes).
    var isolateModel_ = context.watch<IsolateModel>();
    var isolateModel_fw = context.watch<IsolateModel_fw>();
    dynamic isolateModel=isolateModel_;
    if(isolateModel_.isClick){
      isolateModel=isolateModel_;
    }else if(isolateModel_fw.isClick){
      isolateModel=isolateModel_fw;
    }

    // print(isolateModel.messageList.length);
    return ListView.builder(
      itemCount: isolateModel.messageList.length,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.done),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline),
        onPressed: () {
          isolateModel.removeItem(index);
        },
        ),
        title: Text(
          isolateModel.messageList[index],
          style: itemNameStyle,
        ),
      ),
    );
  }
}