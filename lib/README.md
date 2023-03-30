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

## json serializable

1. pubspec.yaml添加对应库
```dart
dependencies:
  json_annotation: ^4.8.0

dev_dependencies:
  build_runner: ^2.3.3
  json_serializable: ^6.6.0
```

2. 添加part声明，同文件名加.g.
```dart
part 'json_serialize.g.dart';
```

3. 添加Json语法糖
```dart
// 用于开启成员类的生成
@JsonSerializable(explicitToJson: true)
class DemoModel extends ChangeNotifier{

  // 显式声明json key
  @JsonKey(name: "Num")
  num? number;

  @JsonKey(name: "Label")
  String label;

  // 保存checkpoint的文件夹名称
  @JsonKey(name: "BasePath")
  String BasePath="";

  // checkpoint列表
  @JsonKey(name: "datalist")
  List <DataModel> datalist=[];

  DemoModel(this.number,this.label);
  ...

}
```
数字型的变量无初始值时需要制定为可空类型

4. 编写json<->model互转的语句
```dart
// 用于开启成员类的生成
@JsonSerializable(explicitToJson: true)
class DemoModel extends ChangeNotifier{
  ...
  // 编写json<->model互转的语句
  factory DemoModel.fromJson(Map<String,dynamic> json) => _$DemoModelFromJson(json);
  Map<String, dynamic> toJson() => _$DemoModelToJson(this);

}
```

5. 添加build.yaml
```dart
targets:
  $default:
    builders:
      json_serializable:
        options:
          # Options configure how source code is generated for every
          # `@JsonSerializable`-annotated class in the package.
          #
          # The default value for each is listed.
          any_map: false
          checked: false
          constructor: ""
          create_factory: true
          create_field_map: false
          create_to_json: true
          disallow_unrecognized_keys: false
          explicit_to_json: true
          field_rename: none
          generic_argument_factories: false
          ignore_unannotated: false
          include_if_null: true
```

6. 项目顶层目录执行自动生成器
```dart
flutter pub run build_runner watch
```
生成的代码在同级目录下

## 语法使用
### 使用类中的其他变量初始化变量

```dart
class Test {
  int foo = 0;
  late int bar = foo; // No error
}
```
### Row中元素均匀排列
```dart
Row(
    mainAxisAlignment:MainAxisAlignment.spaceEvenly,
    children: [
        Text(index.toString()),
        Text(checkpointsModel.checkpointlist[index].simpts.toString()),
        Text(checkpointsModel.checkpointlist[index].weights.toString()),
    ],
),
```

- mainAxisAlignment:MainAxisAlignment.spaceBetween,//所有子节点均匀分布，第一个和最后一个子节点顶格
- mainAxisAlignment:MainAxisAlignment.spaceAround,//所有子节点均匀分布，但第一个子节点之前和最后一个子节点之后也会有一半大小的均分的空间
- mainAxisAlignment:MainAxisAlignment.spaceEvenly,//所有子节点均匀分布，但第一个子节点之前和最后一个子节点之后也会有均分的空间
- mainAxisAlignment:MainAxisAlignment.start,
- mainAxisAlignment:MainAxisAlignment.center,
- mainAxisAlignment:MainAxisAlignment.end,

#### 调整字符串占位数,给出占位数和占位符
```dart
simpts.toString().padLeft(6," ")
simpts.toString().padRight(6," ")
```
#### double类型，设置精度
```dart
double a=0.0;
a+=0.1;
//都是四舍五入
print(a.toStringAsPrecision(2));//小数点后的长度不一定是2位，可能是3位
print(a.toStringAsFixed(2));//小数点后的位数一定是两位
//再转为数字
num.parse((0.6625/10).toStringAsPrecision(2))//double->string->num
double.parse(0.6625.toStringAsPrecision(1))//double->string->double
```

### 组件-AspectRatio
```dart
AspectRatio(
  aspectRatio: 2.0 / 1.0,
  child: Container(color: Colors.blue),
)
```

### 生成列表的便捷方法
```dart
List a = new List.generate(10, (value) => value + 1);
print(a);//[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

### Converts object to a JSON String.
```dart
// 不带indent
String json = jsonEncode(this);
```
```dart
// 自定义indent
var spaces = ' ' * 4;
var encoder = JsonEncoder.withIndent(spaces);
String json = encoder.convert(this);
```

### 全局配置的设置方式
- 实际配置类
```dart
@JsonSerializable(explicitToJson: true)
class AppConfig {

  @JsonKey(name: "theme")
  ColorCode? theme = ColorCode.blue;
  
}
```
- 全局变量类
```dart
class Global {
  Global.create(){
    AppConfig appconfig = AppConfig(ColorCode.blue);
    appconfig.writeConfig();
  }

  // 项目配置
  static AppConfig profile = AppConfig.empty();
}
```
- 将配置类与全局变量类相互绑定的类
```dart
// Global.profile是全局配置
class AppConfigModel extends ChangeNotifier{

  AppConfig get appConfig=>Global.profile;

  void set appConfig(AppConfig appConfig){
    Global.profile=appConfig;
    Global.profile.writeConfig();
    notifyListeners();
  }
}
```

### 根据条件使用/添加组件
spread运算符 ...
将一个列表添加到另一个列表中
```dart
Widget foo = Column(children:[
  MyHeader(),
  ...isHandset ?
      _getHandsetChildren() :
      _getNormalChildren(),
]);
```
### 隐藏debug字段
debugShowCheckedModeBanner:false
```dart
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
```
### Material Button
```dart
Container(
  color: Colors.grey.shade200,
  width: leftPanelBar_width-5,
  alignment: Alignment.center,

  child:MaterialButton(
    color: clickLeftPanelBar?Colors.blue:Colors.grey.shade200,
    highlightElevation:0,
    focusElevation:0,
    hoverElevation: 0,
    padding: EdgeInsets.zero, //使 Icon居中
    shape: RoundedRectangleBorder( // shape用法
        borderRadius: BorderRadius.circular(5)
    ),
    elevation:0,  //阴影大小
    onPressed: (){
      setState(() {
        clickLeftPanelBar=!clickLeftPanelBar;
      });
    },
    child: Icon(Icons.explore_outlined,),
    // minWidth: 35,
  ),
),
```

### 修改状态

```dart
// resize LeftRight divider
class VerticalDivider extends StatefulWidget{

  final Function ? onHover;//通过传递函数修改final成员VerticalDivider_width的值
  final double VerticalDivider_width;
  const VerticalDivider({super.key, this.onDrag, this.onHover, this.VerticalDivider_width=1});

  @override
  State<VerticalDivider> createState() {
    return _VerticalDividerState();
  }

}

class _VerticalDividerState extends State<VerticalDivider>{

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
        child: Container(
          width: isHovered?widget.VerticalDivider_width:widget.VerticalDivider_width,
          color: isHovered?CupertinoColors.activeBlue:Colors.transparent,
        ),
      ),
    );
  }

}

```

```dart
  VerticalDivider(
    VerticalDivider_width:VerticalDivider_width,
    onHover: (double width){
      setState(() {
        VerticalDivider_width=width;
      });
    },
  ),
```