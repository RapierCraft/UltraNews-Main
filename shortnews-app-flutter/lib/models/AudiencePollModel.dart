import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/ModelKeys.dart';

class AudiencePollModel {
  String? id;
  String? pollQuestion;
  String? pollDuration;
  String? userId;
  List<String>? pollChoiceList;
  List<String>? pollTagsList;
  DateTime? createdAt;
  DateTime? endAt;

  AudiencePollModel({
    this.id,
    this.pollQuestion,
    this.pollDuration,
    this.userId,
    this.createdAt,
    this.endAt,
    this.pollChoiceList,
    this.pollTagsList,
  });

  factory AudiencePollModel.fromJson(Map<String, dynamic> json) {
    return AudiencePollModel(
      id: json[CommonKeys.id],
      pollQuestion: json[AudiencePollKeys.pollQuestion],
      pollDuration: json[AudiencePollKeys.pollDuration],
      userId: json[AudiencePollKeys.userId],
      pollChoiceList: json[AudiencePollKeys.pollChoiceList] != null ? List<String>.from(json[AudiencePollKeys.pollChoiceList]) : [],
      pollTagsList: json[AudiencePollKeys.pollTagsList] != null ? List<String>.from(json[AudiencePollKeys.pollTagsList]) : [],
      createdAt: json[CommonKeys.createdAt] != null ? (json[CommonKeys.createdAt] as Timestamp).toDate() : null,
      endAt: json[AudiencePollKeys.endedAt] != null ? (json[AudiencePollKeys.endedAt] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = Map<String, dynamic>();

    data[CommonKeys.id] = this.id;
    data[AudiencePollKeys.pollQuestion] = this.pollQuestion;
    data[AudiencePollKeys.pollDuration] = this.pollDuration;
    data[AudiencePollKeys.userId] = this.userId;
    data[AudiencePollKeys.pollChoiceList] = this.pollChoiceList!.map((e) => e).toList();
    data[AudiencePollKeys.pollTagsList] = this.pollTagsList!.map((e) => e).toList();
    data[CommonKeys.createdAt] = this.createdAt;
    data[AudiencePollKeys.endedAt] = this.endAt;

    return data;
  }
}

class UserData {
  String? id;
  String? pollUserId;
  String? pollAnswer;
  String? pollUserName;
  String? pollUserImage;
  DateTime? createdAt;

  UserData({this.id, this.pollUserId, this.pollAnswer, this.pollUserName, this.pollUserImage, this.createdAt});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json[CommonKeys.id],
      pollUserId: json[AudiencePollUserKeys.pollUserId],
      pollAnswer: json[AudiencePollUserKeys.pollAnswer],
      pollUserName: json[AudiencePollUserKeys.pollUserName],
      pollUserImage: json[AudiencePollUserKeys.pollUserImage],
      createdAt: json[CommonKeys.createdAt] != null ? (json[CommonKeys.createdAt] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = Map<String, dynamic>();

    data[CommonKeys.id] = this.id;
    data[AudiencePollUserKeys.pollUserId] = this.pollUserId;
    data[AudiencePollUserKeys.pollAnswer] = this.pollAnswer;
    data[AudiencePollUserKeys.pollUserName] = this.pollUserName;
    data[AudiencePollUserKeys.pollUserImage] = this.pollUserImage;
    data[CommonKeys.createdAt] = this.createdAt;

    return data;
  }
}
