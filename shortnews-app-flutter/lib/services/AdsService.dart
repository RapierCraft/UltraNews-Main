import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nb_utils/nb_utils.dart';
import '../models/AdsModel.dart';
import '../utils/Constants.dart';
import 'BaseService.dart';

class AdsService extends BaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  late CollectionReference userRef;
  late CollectionReference adRef;

  AdsService() {
    userRef = fireStore.collection(CUSTOM);
    adRef = fireStore.collection(Ads);
  }

  addCustomAds(AdsModel data) async {
    return userRef.doc('facebook').set(data.toJson());
  }

  addBannerAds(AdsModel data) async {
    var doc;
    doc = userRef.doc('banner').set(data.toJson());

    return doc;
  }

  addAdmobAds(AdMobAdsModel data) async {
    var doc = adRef.doc('admob').set(data.toJson());
    return doc;
  }

  addFacebookAds(FaceBookAdsModel data) async {
    var doc = adRef.doc('facebook').set(data.toJson());
    return doc;
  }

  Future<AdsModel> getCustomAds() async {
    log("value");
    var doc = userRef.doc('custom').get().then((value) => AdsModel.fromJson(value.data() as Map<String, dynamic>));
    return doc;
  }

  Future<AdsModel> getBannerAds() async {
    var doc = userRef.doc('banner').get().then((value) => AdsModel.fromJson(value.data() as Map<String, dynamic>));
    return doc;
  }

  Future<AdMobAdsModel> getAdMobAds() async {
    var doc = adRef.doc('admob').get().then((value) => AdMobAdsModel.fromJson(value.data() as Map<String, dynamic>));
    return doc;
  }

  Future<FaceBookAdsModel> getFacebookAds() async {
    var doc = adRef.doc('facebook').get().then((value) => FaceBookAdsModel.fromJson(value.data() as Map<String, dynamic>));
    return doc;
  }

  Future<AdsModel> getADs(String? id) async {
    Query query = userRef.orderBy("createdAt", descending: true);
    return await query.get().then((x) {
      return AdsModel.fromJson(x.docs.first.data() as Map<String, dynamic>);
    });
  }
}
