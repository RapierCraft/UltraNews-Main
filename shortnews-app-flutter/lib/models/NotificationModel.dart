import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationClass {
  String? title;
  String? dec;
  DateTime? time;
  String? img;
  String? id;
  String? newsId;
  DateTime? createdAt;
  DateTime? updatedAt;

  NotificationClass({this.title, this.dec, this.time, this.id, this.img, this.createdAt, this.updatedAt, this.newsId});

  factory NotificationClass.fromJson(Map<String, dynamic> json) {
    return NotificationClass(
      id: json['id'],
      newsId: json['newsId'],
      title: json['title'],
      img: json['img'],
      dec: json['dec'],
      createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : null,
      updatedAt: json['updatedAt'] != null ? (json['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['newsId'] = this.newsId;
    data['title'] = this.title;
    data['img'] = this.img;
    data['dec'] = this.dec;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
