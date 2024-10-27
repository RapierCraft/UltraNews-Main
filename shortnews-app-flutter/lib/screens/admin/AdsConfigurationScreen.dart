import 'package:flutter/material.dart';
import '../../utils/Colors.dart';
import '/../screens/admin/components/AdMobComponet.dart';
import '/../screens/admin/components/FaceBookAdsComponent.dart';
import '../../models/AppSettingModel.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import '../../utils/Constants.dart';

class AdsConfigurationScreen extends StatefulWidget {
  @override
  _AdsConfigurationScreenState createState() => _AdsConfigurationScreenState();
}

class _AdsConfigurationScreenState extends State<AdsConfigurationScreen> {
  bool isUpdate = false;

  List<String> adsTypeList = [Admob, Facebook];

  String? adsType = Admob;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {}

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text(languages.selectAdsType, style: boldTextStyle()),
        16.height,
        Wrap(
          children: adsTypeList.map((e) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio(
                  value: e,
                  groupValue: adsType,
                  activeColor:colorPrimary,
                  onChanged: (dynamic s) async {
                    if (appStore.isTester) return toast(mTesterNotAllowedMsg);
                    adsType = s;
                    AppSettingModel appSettingModel = AppSettingModel();
                    setState(() {});
                    await appSettingService.getAppSettings().then((value) async {
                      appSettingModel.disableAd = value.disableAd;
                      appSettingModel.termCondition = value.termCondition!;
                      appSettingModel.privacyPolicy = value.privacyPolicy!;
                      appSettingModel.contactInfo = value.contactInfo!;

                      appSettingModel.flutterWebBuildVersion = value.flutterWebBuildVersion.validate();
                      appSettingModel.adType = adsType;
                      setState(() {});
                    }).catchError((e) {
                      toast(e, print: true);
                    });

                    db.collection('settings').doc("setting").update(appSettingModel.toJson()).then((value) async {
                      await appSettingService.saveAppSettings(appSettingModel);
                      toast(languages.successSaved);
                    }).catchError((e) {
                      toast(e.toString(), print: true);
                    });
                  },
                ),
                Text(e.capitalizeFirstLetter(), style: secondaryTextStyle()).withWidth(100).paddingAll(8).onTap(() async {
                  if (appStore.isTester) return toast(mTesterNotAllowedMsg);
                  adsType = e;
                  setState(() {});
                  AppSettingModel appSettingModel = AppSettingModel();
                  setState(() {});
                  await appSettingService.getAppSettings().then((value) async {
                    appSettingModel.disableAd = value.disableAd;
                    appSettingModel.termCondition = value.termCondition!;
                    appSettingModel.privacyPolicy = value.privacyPolicy!;
                    appSettingModel.contactInfo = value.contactInfo!;

                    appSettingModel.flutterWebBuildVersion = value.flutterWebBuildVersion.validate();
                    appSettingModel.adType = adsType;
                    setState(() {});
                  }).catchError((e) {
                    toast(e, print: true);
                  });
                  db.collection('settings').doc("setting").update(appSettingModel.toJson()).then((value) async {
                    await appSettingService.saveAppSettings(appSettingModel);

                    //  toast(languages.successSaved);
                  }).catchError((e) {
                    toast(e.toString(), print: true);
                  });
                }),
              ],
            );
          }).toList(),
        ),
        adsType == Facebook ? FacebookAdsComponent() : AdmobComponent(),
      ],
    ).paddingAll(16);
  }
}
