- isolate基本用法

```
await Isolate.spawn(doWork, rootReceivePort.sendPort);
```
回调函数doWork必须在顶层或者定义为静态方法
- provider的基本用法
 
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

4.在函数中添加监听，以便更新数据
```dart
  void removeItem(int index){
    messageList.removeAt(index);
    notifyListeners();
  }
```

