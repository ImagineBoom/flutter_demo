## isolate基本用法

1. 调用doWork函数，包含一个参数sendPort
```dart
await Isolate.spawn(doWork, rootReceivePort.sendPort);
```

2. 调用包含多个参数的doWork函数

```dart
await Isolate.spawn(doWork, [rootReceivePort.sendPort,dir]);
```

```dart
Future<void> doWork(List<dynamic> args) async {
  //发送消息端口
  SendPort sendPort = args[0];
  String dir = args[1];
  ...
}
```
3. isolate中不能使用插件。只能支持原生。
因此保存文件时先在主isolate中使用第三方插件path_provider获取路径。
然后在通过参数传入子isolate中。在子isolate中使用原生的io读写文件即可。

```dart
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
```
第一次创建文件时需要使用create方法。
```dart
File file = await File('$dir/data.json').create(recursive: true);
await file.writeAsString("write contents test",mode: FileMode.writeOnly);
```

回调函数doWork必须在顶层或者定义为静态方法

## provider的基本用法
 
1.顶层视图中添加provider
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => IsolateModel()),
  ]
)
```
2.定义Model类继承ChangeNotifier

```dart
class IsolateModel extends ChangeNotifier {
  final List<String> messageList = [];
  ...
}
```

3.使用watch方法调用函数进行数据更新，或者使用变量获取更新的值

```dart
@override
Widget build(BuildContext context) {
  var itemNameStyle = Theme.of(context).textTheme.titleLarge;

  var isolateModel = context.watch<IsolateModel>();
  return ListView.builder(
    //获取更新的值
    itemCount: isolateModel.messageList.length,
    itemBuilder: (context, index) => ListTile(
      leading: const Icon(Icons.done),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        onPressed: () {
          //使用函数更新
          isolateModel.removeItem(index);
        },
      ),
      title: Text(
        //获取更新的值
        isolateModel.messageList[index],
        style: itemNameStyle,
      ),
    ),
  );
}
```

```dart
  @override
  Widget build(BuildContext context) {

    var isolateModel = context.watch<IsolateModel>();

    return Scaffold(
      ...
      bottomSheet: Row(
        children: [
          MaterialButton(
            // 调用函数更新
            onPressed: () async=> await isolateModel.main([]),
            color: Colors.greenAccent,
            child: Text("new Isolate"),
          ),
        ],
      ),
    );
  }
```

4.在改变数据的函数中添加监听，以便更新数据
```dart
  void removeItem(int index){
    messageList.removeAt(index);
    notifyListeners();
  }
```

## 使用provider时复用组件，改变Model
1. Model中设置bool类型的变量isClick，为true时表示更新了，为false时表示禁用了,默认为禁用状态。

```dart
class IsolateModel_fw extends ChangeNotifier {
  final List<String> messageList = [];
  bool isClick = false;

  Future<void> setIsClick(bool sel)async{
    isClick=sel;
    notifyListeners();
  }
  ...
}
```

2. 界面中点击按钮触发事件时，激活当前功能对应的Model, 同时禁用其余Model

```dart
MaterialButton(
  onPressed: () async=> {
    isolateModel_fw.setIsClick(false),//禁用
    await isolateModel.main([])
  },
  color: Colors.greenAccent,
  child: Text("new Isolate"),
),
```

```dart
// isolateModel Class
Future<void> main(List<String> args) async {
    // 激活按钮
    await setIsClick(true);//激活
    //主isolate启动
    messageNotify("main isolate start");
    //创建一个新的isolate
    await createIsolate();
}
```

3. 使用dynamic变量接收为ture的model,默认值设置为第一个按钮的Model。

```dart
var isolateModel_ = context.watch<IsolateModel>();
var isolateModel_fw = context.watch<IsolateModel_fw>();
dynamic isolateModel=isolateModel_;//dynamic中间变量
if(isolateModel_.isClick){
  isolateModel=isolateModel_;
}else if(isolateModel_fw.isClick){
  isolateModel=isolateModel_fw;
}
```

