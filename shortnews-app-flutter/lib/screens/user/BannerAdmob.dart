import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../utils/Common.dart';

class BannerAdmob extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _BannerAdmobState();
  }
}

class _BannerAdmobState extends State<BannerAdmob>{

  late BannerAd _bannerAd;
  bool isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: getBannerAdUnitId()!,
      request: const AdRequest(),
      size: AdSize(width: 320, height: 600),
      listener: BannerAdListener(
        onAdLoaded: (_) {

          setState(() {
            isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          setState(() {
            isAdLoaded = false;
          });
          ad.dispose();
        },
      ),
    );
    _bannerAd.load();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isAdLoaded?SizedBox(
      width: _bannerAd.size.width.toDouble(),
      height: _bannerAd.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd),
    ):Container();
  }
}