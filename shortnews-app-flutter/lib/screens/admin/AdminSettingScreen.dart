import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '/../main.dart';
import '/../models/AppSettingModel.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

class AdminSettingScreen extends StatefulWidget {
  static String tag = '/AdminSettingScreen';

  @override
  _AdminSettingScreenState createState() => _AdminSettingScreenState();
}

class _AdminSettingScreenState extends State<AdminSettingScreen> {
  TextEditingController termConditionCont = TextEditingController();
  TextEditingController privacyPolicyCont = TextEditingController();
  TextEditingController contactInfoCont = TextEditingController();
  TextEditingController flutterWebBuildVersionCont = TextEditingController();

  bool? disableAd = false;

  // bool? disableSponsored = false;

  bool? disableLocation = false;
  bool? disableHeadline = false;
  bool? disableQuickRead = false;
  bool? disableStory = false;

  String termCondition = '';
  String privacyPolicy = '';
  String contactInfo = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setLoading(true);
    setData();

    appStore.setLoading(false);
  }

  Future<void> setData() async {

    await appSettingService.getAppSettings().then((value) async {

      disableAd = value.disableAd;
      termConditionCont.text = !value.termCondition.isEmptyOrNull ? value.termCondition.validate() : '';
      privacyPolicyCont.text = !value.privacyPolicy.isEmptyOrNull ? value.privacyPolicy.validate() : '';
      contactInfoCont.text = !value.contactInfo.isEmptyOrNull ? value.contactInfo.validate() : '';
      flutterWebBuildVersionCont.text = !value.flutterWebBuildVersion.isEmptyOrNull ? value.flutterWebBuildVersion.validate() : '';
      setState(() {});
    }).catchError((e) {
      toast(e, print: true);
    });
  }

  Future<void> save() async {
    if (appStore.isTester) return toast(mTesterNotAllowedMsg);

    appStore.setLoading(true);

    AppSettingModel appSettingModel = AppSettingModel();

    appSettingModel.disableAd = disableAd;

    appSettingModel.termCondition = termConditionCont.text.trim();
    appSettingModel.privacyPolicy = privacyPolicyCont.text.trim();
    appSettingModel.contactInfo = contactInfoCont.text.trim();
    appSettingModel.adType = Admob;

    appSettingModel.dashboardWidgetOrder = sharedPreferences.getStringList(DASHBOARD_WIDGET_ORDER);
    if (appSettingModel.dashboardWidgetOrder == null) appSettingModel.dashboardWidgetOrder = [];

    appSettingModel.flutterWebBuildVersion = flutterWebBuildVersionCont.text.trim();
    db.collection('settings').doc("setting").update(appSettingModel.toJson()).then((value) async {
      await appSettingService.saveAppSettings(appSettingModel);

      toast(languages.save);
    }).catchError((e) {
      e.toString().toastString();
    });

    appStore.setLoading(false);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 30, top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(languages.appSetting, style: boldTextStyle()).paddingLeft(16),
                Wrap(
                  children: [
                    Container(
                      width: 500,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: termConditionCont,
                            textFieldType: TextFieldType.NAME,
                            decoration: inputDecoration(
                              labelText: languages.termCondition,
                            ),
                          ).paddingAll(16),
                          AppTextField(
                            controller: privacyPolicyCont,
                            textFieldType: TextFieldType.NAME,
                            decoration: inputDecoration(
                              labelText: languages.privacyPolicy,
                            ),
                          ).paddingAll(16),
                          AppTextField(
                            controller: contactInfoCont,
                            textFieldType: TextFieldType.NAME,
                            decoration: inputDecoration(
                              labelText: languages.contactInfo,
                            ),
                          ).paddingAll(16),
                          AppTextField(
                            controller: flutterWebBuildVersionCont,
                            textFieldType: TextFieldType.NAME,
                            decoration: inputDecoration(
                              labelText: languages.flutterWebBuildVersion,
                            ),
                          ).paddingAll(16).visible(appStore.isAdmin),
                          SettingItemWidget(
                              title: languages.disableAdMob,
                              trailing: Transform.scale(
                                scale: 0.8,
                                child: CupertinoSwitch(
                                  activeColor: colorPrimary,
                                  value: disableAd!,
                                  onChanged: (v) {
                                    disableAd = v;

                                    setState(() {});
                                  },
                                ).withHeight(10),
                              ),
                              onTap: () {
                                disableAd = !disableAd!;
                                setState(() {});
                              },
                              hoverColor: Colors.transparent,
                              splashColor: Colors.transparent),
                          AppButton(
                            text: languages.save,
                            onTap: () => save(),
                            textColor: Colors.white,
                            color: colorPrimary,
                            height: 60,
                            width: context.width(),
                          ).paddingAll(16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Observer(builder: (_) => loader().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
