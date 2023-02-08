//isolate_create.dart文件
import 'dart:isolate';
import 'dart:io';

import 'package:flutter/foundation.dart';


class IsolateModel extends ChangeNotifier{
  final List<String> messageList=[];

  void messageNotify(String message){
    if (kDebugMode) {
      print(message);
      messageList.add(message);
      print(messageList.length);
    }
    notifyListeners();
  }

  void removeItem(int index){
    messageList.removeAt(index);
    notifyListeners();
  }

  Future<void> main(List<String> args) async {

    //主isolate启动
    messageNotify("main isolate start");
    //创建一个新的isolate
    await createIsolate();
    //主isolate停止
    // print("main isolate end");

  }

//创建一个新的isolate
  Future<void> createIsolate() async{

    //发送消息端口
    SendPort? rootSendPort;

    //接收消息端口
    ReceivePort rootReceivePort = ReceivePort();

    //创建一个新的isolate
    //传入要执行任务方法doWork
    //传入主isolate的接收端口rootReceivePort的sendPort，用于子isolate的sendPort
    await Isolate.spawn(doWork, rootReceivePort.sendPort);


    //接收消息端口监听新isolate发送过来的消息
    rootReceivePort.listen((receiveMessage){

      //打印接收到的所有消息
      messageNotify("main isolate receive <-- $receiveMessage");

      //消息类型为端口
      if (receiveMessage['type'] == 'port'){
        //将新isolate发送过的端口赋值给senPort
        rootSendPort = receiveMessage['data'];
        messageNotify("new isolate start");
      }
      else if((receiveMessage['type'] == 'message') && (receiveMessage['state'] == 'running')){
        //当sendPort对象实例化后可以向新isolate发送消息了
        //消息类型为message
        //消息数据为字符串
        var sendMessage={
          'type':'message',
          'data':'I know task1 running',
          'state':'running',
        };

        messageNotify("main isolate send      --> $sendMessage");

        rootSendPort?.send(sendMessage);
      }
      else if((receiveMessage['type'] == 'message') && (receiveMessage['state'] == 'end')){
        var sendMessage={
          'type':'message',
          'data':'I konw task1 finished, exit new isolate',
          'state':'end',
        };

        messageNotify("main isolate send      --> $sendMessage");

        rootSendPort?.send(sendMessage);
      }

    });
  }
}

// isolate 的回调函数要么是顶层，要么是静态函数

//处理耗时任务 接收一个可以向主isolate发送消息的端口
void doWork(SendPort sendPort){

  //发送消息端口
  //sendPort;

  //接收消息端口
  ReceivePort receivePort = ReceivePort();

  //接收消息端口监听主isolate发送过来的消息
  receivePort.listen((receiveMessage){
    if((receiveMessage['type'] == 'message') && (receiveMessage['state'] == 'end')){
      Isolate.exit();
    }
  });

  var sendMessage={
    'type':'port',
    'data':receivePort.sendPort,
    'state':'start',
  };

  //将新isolate的sendPort发送到主isolate中用于通信
  sendPort.send(sendMessage);

  // 模拟耗时5秒
  sleep(const Duration(seconds:5));

  sendMessage={
    'type':'message',
    'data':'task1 running',
    'state':'running'
  };

  //发送消息表示任务进行中
  sendPort.send(sendMessage);

  // 模拟耗时5秒
  sleep(const Duration(seconds:5));

  sendMessage={
    'type':'message',
    'data':'task1 finished',
    'state':'end'
  };

  //发送消息表示任务结束
  sendPort.send(sendMessage);
}
