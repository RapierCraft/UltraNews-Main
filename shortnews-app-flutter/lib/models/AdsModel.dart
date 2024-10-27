import 'package:cloud_firestore/cloud_firestore.dart';

class AdsModel {
  String? title;
  String? dec;
  String? img;
  String? id;
  String? url;
  DateTime? createdAt;
  DateTime? updatedAt;

  AdsModel({this.title, this.dec, this.url, this.id, this.img, this.createdAt, this.updatedAt});

  factory AdsModel.fromJson(Map<String, dynamic> json) {
    return AdsModel(
      id: json['id'],
      url: json['url'],
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
    data['url'] = this.url;
    data['title'] = this.title;
    data['img'] = this.img;
    data['dec'] = this.dec;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class AdMobAdsModel {
  String? adMobBannerAd;
  String? adMobInterstitialAd;
  String? adMobBannerIos;
  String? adMobInterstitialIos;
  DateTime? createdAt;
  DateTime? updatedAt;

  AdMobAdsModel({this.adMobBannerAd, this.adMobBannerIos, this.adMobInterstitialAd, this.adMobInterstitialIos, this.createdAt, this.updatedAt});

  factory AdMobAdsModel.fromJson(Map<String, dynamic> json) {
    return AdMobAdsModel(
      adMobBannerAd: json['adMobBannerAd'],
      adMobBannerIos: json['adMobBannerIos'],
      adMobInterstitialAd: json['adMobInterstitialAd'],
      adMobInterstitialIos: json['adMobInterstitialIos'],
      createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : null,
      updatedAt: json['updatedAt'] != null ? (json['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['adMobBannerAd'] = this.adMobBannerAd;
    data['adMobBannerIos'] = this.adMobBannerIos;
    data['adMobInterstitialAd'] = this.adMobInterstitialAd;
    data['adMobInterstitialIos'] = this.adMobInterstitialIos;

    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class FaceBookAdsModel {
  String? faceBookBannerAd;
  String? faceBookInterstitialAd;
  String? faceBookBannerIos;
  String? faceBookInterstitialIos;
  DateTime? createdAt;
  DateTime? updatedAt;

  FaceBookAdsModel({this.faceBookBannerAd, this.faceBookInterstitialAd, this.faceBookBannerIos, this.faceBookInterstitialIos, this.createdAt, this.updatedAt});

  factory FaceBookAdsModel.fromJson(Map<String, dynamic> json) {
    return FaceBookAdsModel(
      faceBookBannerAd: json['faceBookBannerAd'],
      faceBookInterstitialAd: json['faceBookInterstitialAd'],
      faceBookBannerIos: json['faceBookBannerIos'],
      faceBookInterstitialIos: json['faceBookInterstitialIos'],
      createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : null,
      updatedAt: json['updatedAt'] != null ? (json['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['faceBookBannerAd'] = this.faceBookBannerAd;
    data['faceBookInterstitialAd'] = this.faceBookInterstitialAd;
    data['faceBookBannerIos'] = this.faceBookBannerIos;
    data['faceBookInterstitialIos'] = this.faceBookInterstitialIos;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
