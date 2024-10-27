import 'package:flutter/material.dart';
import '/../utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../models/AdsModel.dart';
import '../../../utils/Colors.dart';
import '../../../utils/Constants.dart';

class FacebookAdsComponent extends StatefulWidget {
  @override
  _FacebookAdsComponentState createState() => _FacebookAdsComponentState();
}

class _FacebookAdsComponentState extends State<FacebookAdsComponent> {
  TextEditingController faceBookBannerAdCont = TextEditingController();
  TextEditingController faceBookInterstitialAdCont = TextEditingController();
  TextEditingController faceBookBannerIosCont = TextEditingController();
  TextEditingController faceBookInterstitialIosCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await adsService.getFacebookAds().then((value) {
      faceBookBannerAdCont.text = value.faceBookBannerAd.validate();
      faceBookInterstitialAdCont.text = value.faceBookInterstitialAd.validate();
      faceBookBannerIosCont.text = value.faceBookBannerIos.validate();
      faceBookInterstitialIosCont.text = value.faceBookInterstitialIos.validate();
    });
  }

  Future<void> saveFacebook() async {
    if (appStore.isTester) return toast(mTesterNotAllowedMsg);
    FaceBookAdsModel adsData = FaceBookAdsModel();

    adsData.faceBookBannerAd = faceBookBannerAdCont.text.trim();
    adsData.faceBookInterstitialAd = faceBookInterstitialAdCont.text.trim();
    adsData.faceBookBannerIos = faceBookBannerIosCont.text.trim();
    adsData.faceBookInterstitialIos = faceBookInterstitialIosCont.text.trim();
    adsData.createdAt = DateTime.now();
    adsData.updatedAt = DateTime.now();

    await adsService.addFacebookAds(adsData).then((value) async {
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
        Text("Facebook Id for Android", style: boldTextStyle()),
        16.height,
        Row(
          children: [
            AppTextField(
              controller: faceBookBannerAdCont,
              textFieldType: TextFieldType.OTHER,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
              decoration: inputDecoration(labelText: 'Facebook Banner ID'),
            ).expand(),
            20.width,
            AppTextField(
              controller: faceBookInterstitialAdCont,
              textFieldType: TextFieldType.NAME,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
              decoration: inputDecoration(labelText: 'Facebook Interstitial ID'),
            ).expand(),
          ],
        ),
        20.height,
        Text("Facebook Id For IOS", style: boldTextStyle()),
        16.height,
        Row(
          children: [
            AppTextField(
              controller: faceBookBannerIosCont,
              textFieldType: TextFieldType.NAME,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
              decoration: inputDecoration(labelText: 'Facebook Banner ID'),
            ).expand(),
            20.width,
            AppTextField(
              controller: faceBookInterstitialIosCont,
              textFieldType: TextFieldType.OTHER,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
              decoration: inputDecoration(labelText: 'Facebook Interstitial ID'),
            ).expand(),
          ],
        ),
        30.height,
        AppButton(
          text:languages.save,
          width: context.width(),
          color: colorPrimary,
          padding: EdgeInsets.all(20),
          textColor: Colors.white,
          onTap: () {
            saveFacebook();
          },
        ),
      ],
    ).paddingOnly(right: 30);
  }
}
