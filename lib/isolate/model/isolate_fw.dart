//isolate_create.dart文件
import 'dart:isolate';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';


class IsolateModel_fw extends ChangeNotifier{
  final List<String> messageList=[];
  bool isClick=false;

  Future<void> setIsClick(bool sel)async{
    isClick=sel;
    notifyListeners();
  }

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

    // 激活按钮
    await setIsClick(true);

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

    // 获取工作目录，用于存储数据
    // getApplicationSupportDirectory
    // 支持Android,	iOS,	Linux,	macOS,	Windows
    // SDK 16+,	9.0+,	Any,	10.11+,	Windows 10+
    String dir = await getApplicationSupportDirectory().then((value) => value.path);
    // 创建一个新的isolate
    // 传入要执行回调函数doWork
    // 传入主isolate的接收端口rootReceivePort的sendPort，用于子isolate的sendPort
    // 传入数据存储的目录
    await Isolate.spawn(doWork, [rootReceivePort.sendPort,dir]);


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
Future<void> doWork(List<dynamic> args) async {


  //发送消息端口
  SendPort sendPort= args[0];
  String dir = args[1];

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

  String res= await fwTask(dir);

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
    'data':'task1 finished,res= $res',
    'state':'end'
  };

  //发送消息表示任务结束
  sendPort.send(sendMessage);
}

Future<String> fwTask(String dir) async {
  File file = await File('$dir/data.json').create(recursive: true);
  await file.writeAsString("write contents test",mode: FileMode.writeOnly);
  return file.readAsString();
}
