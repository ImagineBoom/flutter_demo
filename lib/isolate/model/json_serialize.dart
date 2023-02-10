import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'json_serialize.g.dart';

// 用于开启成员类的生成
@JsonSerializable(explicitToJson: true)
class DemoModel extends ChangeNotifier{

  // 显式声明json key
  @JsonKey(name: "Num")
  num number;

  @JsonKey(name: "Label")
  String label;

  // 保存checkpoint的文件夹名称
  @JsonKey(name: "BasePath")
  String BasePath="";

  // checkpoint列表
  @JsonKey(name: "datalist")
  List <DataModel> datalist=[];

  DemoModel(this.number,this.label);

  // 编写json<->model互转的语句
  factory DemoModel.fromJson(Map<String,dynamic> json) => _$DemoModelFromJson(json);
  Map<String, dynamic> toJson() => _$DemoModelToJson(this);

}

@JsonSerializable(explicitToJson: true)
class DataModel {

  @JsonKey(name: "id")
  num id;

  @JsonKey(name: "content")
  String content;

  DataModel(this.id,this.content);

  // 编写json<->model互转的语句
  factory DataModel.fromJson(Map<String,dynamic> json) => _$DataModelFromJson(json);
  Map<String, dynamic> toJson() => _$DataModelToJson(this);
}