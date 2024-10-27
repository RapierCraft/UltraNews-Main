import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mighty_sort_news/models/UserPreferenceCategory.dart';
import 'package:mighty_sort_news/store/AppStore.dart';
import 'package:mighty_sort_news/utils/ModelKeys.dart';
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';
import 'BaseService.dart';

class UserPreferenceService extends BaseService {

  UserPreferenceService() {
    ref = db.collection('user_preference');
  }

  addPreference(UserPreferenceCategory data) async {
    return ref!.doc('user_preference').set(data.toJson());
  }

  /// Delete existing interests first
  addPreferences(List<UserPreferenceCategory> data, List<UserPreferenceCategory> oldCat) async {
      await ref!.where(UserPreferenceCategoryKeys.userId, isEqualTo: appStore.userId).get().then((value) {
        value.docs.forEach((doc) {
          doc.reference.delete();
        });

        for(int i = 0; i < data.length; i++){
          print("Category ID: ${data[i].categoryId}");
          // ref!.doc(appStore.userId).set(data[i].toJson(),SetOptions(merge: true));
          db.collection('user_preference').add(data[i].toJson());
        }
      });
  }

  Future<UserPreferenceCategory> getPreference() async {
    var doc = ref!.doc('user_preference').get().then((value) => UserPreferenceCategory.fromJson(value.data() as Map<String, dynamic>));
    return doc;
  }

  Future<List<UserPreferenceCategory>> getPreferences({int? limit}) async {
    Query query = ref!.where(UserPreferenceCategoryKeys.userId, isEqualTo: appStore.userId);
    return await query.get().then((x) => x.docs.map((y) => UserPreferenceCategory.fromJson(y.data() as Map<String, dynamic>)).toList());
  }
}
