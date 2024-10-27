import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';

BannerAd? myBanner;
bool? isAdLoaded = false;
InterstitialAd? myInterstitial;

BannerAd buildBannerAd() {
  return BannerAd(
    adUnitId: getBannerAdUnitId()!,
    // size: AdSize.banner,
    size: AdSize(width: 320, height: 400),
    listener: BannerAdListener(onAdLoaded: (ad) {
      isAdLoaded = true;
    }, onAdFailedToLoad: (ad, error) {
      isAdLoaded = false;
      print("Error" + error.message);
    }),
    request: const AdRequest(),
    // request: AdRequest(keywords: adMobTestDevices),
  );
}

void loadInterstitialAd() {
  InterstitialAd.load(
    adUnitId: getInterstitialAdUnitId()!,
    request: AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        print('$ad loaded');
        myInterstitial = ad;
      },
      onAdFailedToLoad: (LoadAdError error) {
        print('InterstitialAd failed to load: $error.');
        myInterstitial = null;
      },
    ),
  );
}

void showInterstitialAd() {
  if (myInterstitial == null) {
    print('Warning: attempt to show interstitial before loaded.');
    return;
  }
  myInterstitial!.fullScreenContentCallback = FullScreenContentCallback(
    onAdShowedFullScreenContent: (InterstitialAd ad) => print('ad onAdShowedFullScreenContent.'),
    onAdDismissedFullScreenContent: (InterstitialAd ad) {
      ad.dispose();
      loadInterstitialAd();
    },
    onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
      ad.dispose();
      loadInterstitialAd();
    },
  );
  myInterstitial!.show();
  myInterstitial = null;
}
