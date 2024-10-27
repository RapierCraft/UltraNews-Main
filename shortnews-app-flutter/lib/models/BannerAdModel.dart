import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';

class BannerAdModel {
  BannerAd? myBanner;
  bool? isAdLoaded = false;

  BannerAd buildBannerAd() {
    return myBanner =  BannerAd(
      adUnitId: getBannerAdUnitId()!,
      // size: AdSize.banner,
      size: AdSize(width: 320, height: 600),
      listener: BannerAdListener(onAdLoaded: (ad) {
        isAdLoaded = true;
        print("Banner loaded");
      }, onAdFailedToLoad: (ad, error) {
        isAdLoaded = false;
        print("Error" + error.message);
      }),
      request: const AdRequest(),
      // request: AdRequest(keywords: adMobTestDevices),
    );
  }
}
