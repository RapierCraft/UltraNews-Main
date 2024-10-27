import 'package:flutter/material.dart';
import '/../utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../models/AdsModel.dart';
import '../../../utils/Colors.dart';
import '../../../utils/Constants.dart';

class AdmobComponent extends StatefulWidget {
  @override
  _AdmobComponentState createState() => _AdmobComponentState();
}

class _AdmobComponentState extends State<AdmobComponent> {


  TextEditingController adMobBannerAdCont = TextEditingController();
  TextEditingController adMobInterstitialAdCont = TextEditingController();
  TextEditingController adMobBannerIosCont = TextEditingController();
  TextEditingController adMobInterstitialIosCont = TextEditingController();


  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await adsService.getAdMobAds().then((value) {
      adMobBannerAdCont.text = value.adMobBannerAd.validate();
      adMobInterstitialAdCont.text = value.adMobInterstitialAd.validate();
      adMobBannerIosCont.text = value.adMobBannerIos.validate();
      adMobInterstitialIosCont.text = value.adMobInterstitialIos.validate();
    });
  }

  Future<void> saveAdMob() async {
    if (appStore.isTester) return toast(mTesterNotAllowedMsg);
    AdMobAdsModel adsData = AdMobAdsModel();

    adsData.adMobBannerAd = adMobBannerAdCont.text.trim();
    adsData.adMobInterstitialAd = adMobInterstitialAdCont.text.trim();
    adsData.adMobBannerIos = adMobBannerIosCont.text.trim();
    adsData.adMobInterstitialIos = adMobInterstitialIosCont.text.trim();
    adsData.createdAt = DateTime.now();
    adsData.updatedAt = DateTime.now();

    await adsService.addAdmobAds(adsData).then((value) async {
      toast(languages.save);
      // LiveStream().emit(StreamSelectItem, 2);
    });
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        30.height,
        Text(languages.admobIdForAndroid, style: boldTextStyle()),
        16.height,
        Row(
          children: [
            AppTextField(
              controller: adMobBannerAdCont,
              textFieldType: TextFieldType.OTHER,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
              decoration: inputDecoration(labelText: languages.admobBannerIdForAndroid),
            ).expand(),
            20.width,
            AppTextField(
              controller: adMobInterstitialAdCont,
              textFieldType: TextFieldType.NAME,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
              decoration: inputDecoration(labelText: languages.admobInterstitialIdForAndroid),
            ).expand(),
          ],
        ),
        20.height,
        Text(languages.admobIdForIOS, style: boldTextStyle()),
        16.height,
        Row(
          children: [
            AppTextField(
              controller: adMobBannerIosCont,
              textFieldType: TextFieldType.NAME,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
              decoration: inputDecoration(labelText: languages.admobBannerIdForIos),
            ).expand(),
            20.width,
            AppTextField(
              controller: adMobInterstitialIosCont,
              textFieldType: TextFieldType.OTHER,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
              decoration: inputDecoration(labelText: languages.admobInterstitialIdForIos),
            ).expand(),
          ],
        ),
        30.height,
        AppButton(
          text: languages.save,
          width: context.width(),
          padding: EdgeInsets.all(20),
          textColor: Colors.white,
          color: colorPrimary,
          onTap: () {
            saveAdMob();
          },
        ),
      ],
    ).paddingOnly(right: 30);
  }
}
