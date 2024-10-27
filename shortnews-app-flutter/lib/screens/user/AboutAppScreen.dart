import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mighty_sort_news/main.dart';
import '../../components/AdMobAdComponent.dart';
import '../../components/FacebookAdComponent.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import 'package:flutter/services.dart';

import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutAppScreen extends StatelessWidget {
  static String tag = '/AboutAppScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(languages.about, showBack: true, color: colorPrimary,systemUiOverlayStyle: SystemUiOverlayStyle.light, textColor: Colors.white),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mAppName, style: primaryTextStyle(size: 30)),
            16.height,
            Container(
              decoration: BoxDecoration(color: colorPrimary, borderRadius: radius(4)),
              height: 4,
              width: 100,
            ),
            16.height,
            Text(languages.version, style: secondaryTextStyle()),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (_, snap) {
                if (snap.hasData) {
                  return Text('${snap.data!.version.validate()}', style: primaryTextStyle());
                }
                return SizedBox();
              },
            ),
            16.height,
            Text(mAboutApp, style: primaryTextStyle(size: 14), textAlign: TextAlign.justify),
            16.height,
            AppButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.contact_support_outlined, color: context.iconColor),
                  8.width,
                  Text(languages.contact, style: boldTextStyle()),
                ],
              ),
              onTap: () {
                launchUrlWidget('mailto:${getStringAsync(CONTACT_PREF)}');
              },
            ),
            16.height,
            // AppButton(
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Image.asset('assets/purchase.png', height: 24),
            //       8.width,
            //       Text('purchase'.translate, style: boldTextStyle()),
            //     ],
            //   ),
            //   onTap: () {
            //     launchUrlWidget(codeCanyonURL);
            //   },
            // ),
          ],
        ),
      ),
      bottomNavigationBar: getBoolAsync(DISABLE_AD) == false
          ? getStringAsync(AD_TYPE) == Admob
              ? Container(child: AdWidget(ad: buildBannerAd()..load()), height: buildBannerAd().size.height.toDouble())
              : loadFacebookBannerId()
          : SizedBox(),
    );
  }
}
