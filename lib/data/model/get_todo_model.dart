import 'dart:convert';

List<GetTodoModel> getTodoModelFromJson(String str) => List<GetTodoModel>.from(json.decode(str).map((x) => GetTodoModel.fromJson(x)));

String getTodoModelToJson(List<GetTodoModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetTodoModel {
  final DateTime? createdAt;
  final String? title;
  final String? subtitle;
  final bool? isCompleted;
  final String? id;

  GetTodoModel({
    this.createdAt,
    this.title,
    this.subtitle,
    this.isCompleted,
    this.id,
  });

  factory GetTodoModel.fromJson(Map<String, dynamic> json) => GetTodoModel(
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        title: json["title"],
        subtitle: json["subtitle"],
        isCompleted: json["isCompleted"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "createdAt": createdAt?.toIso8601String(),
        "title": title,
        "subtitle": subtitle,
        "isCompleted": isCompleted,
        "id": id,
      };
}
