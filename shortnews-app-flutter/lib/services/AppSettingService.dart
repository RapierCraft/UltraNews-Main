import '../models/AppSettingModel.dart';
import '../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'BaseService.dart';

class AppSettingService extends BaseService {
  String? id;

  AppSettingService() {
    ref = db.collection('settings');
  }

  Future<AppSettingModel> getAppSettings() async {
    return await ref!.get().then((value) async {
      if (value.docs.isEmpty) {
        return await setAppSettings();
      } else {
        return await ref!.doc('setting').get().then((value) async {
          id = value.id;
          return AppSettingModel.fromJson(value.data() as Map<String, dynamic>);
        }).catchError((e) {
          throw e;
        });
      }
    }).catchError((e) {
      throw e;
    });
  }

  Future<AppSettingModel> setAppSettings() async {
    AppSettingModel appSettingModel = AppSettingModel();

    //region Default values
    appSettingModel.disableAd = true;

    appSettingModel.disableSponsored = false;

    appSettingModel.termCondition = '';
    appSettingModel.adType = '';

    appSettingModel.privacyPolicy = '';
    appSettingModel.contactInfo = '';
    appSettingModel.flutterWebBuildVersion = '';
    appSettingModel.dashboardWidgetOrder = [];
    //endregion
    return ref!.get().then((value) async {
      if (value.docs.isNotEmpty) {
        appSettingModel = await ref!.doc('setting').get().then((value) => AppSettingModel.fromJson(value.data() as Map<String, dynamic>));
        await saveAppSettings(appSettingModel);
        LiveStream().emit(StreamRefresh, true);
      } else {
        ref!.doc("setting").set(appSettingModel.toJson());
      }
      return appSettingModel;
    }).catchError((e) {
      log(e);
    });
  }

  Future<void> saveAppSettings(AppSettingModel appSettingModel) async {
    // await setValue(DISABLE_AD, appSettingModel.disableAd.validate());
    await setValue(DISABLE_AD, false);
    await setValue(TERMS_AND_CONDITION_PREF, appSettingModel.termCondition.validate());
    await setValue(PRIVACY_POLICY_PREF, appSettingModel.privacyPolicy.validate());
    await setValue(CONTACT_PREF, appSettingModel.contactInfo.validate());
    await setValue(FLUTTER_WEB_BUILD_VERSION, appSettingModel.flutterWebBuildVersion.validate());
    if (appSettingModel.adType != null && appSettingModel.adType!.isEmpty)
      await setValue(AD_TYPE, Admob);
    else
      await setValue(AD_TYPE, appSettingModel.adType);
  }
}
