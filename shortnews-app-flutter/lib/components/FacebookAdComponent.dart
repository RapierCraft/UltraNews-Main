import 'dart:io';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/Constants.dart';

bool _isInterstitialAdLoaded = false;

// Load InterstitialAd
void loadFacebookInterstitialAd() {
  FacebookInterstitialAd.loadInterstitialAd(
    placementId: kReleaseMode
        ? getInterstitialFacebookAdUnitId()!
        : isAndroid
            ? fbInterstitialId
            : fbInterstitialIdIos,
    listener: (result, value) {
      print(">> FAN > Interstitial Ad: $result --> $value");
      if (result == InterstitialAdResult.LOADED) _isInterstitialAdLoaded = true;

      if (result == InterstitialAdResult.DISMISSED && value["invalidated"] == true) {
        _isInterstitialAdLoaded = false;
        loadFacebookInterstitialAd();
      }
    },
  );
}

// Show InterstitialAd
void showFacebookInterstitialAd() {
  if (_isInterstitialAdLoaded == true)
    FacebookInterstitialAd.showInterstitialAd();
  else
    print("Interstial Ad not yet loaded!");
}

String? getBannerFacebookAdUnitId() {
  if (Platform.isIOS) {
    return getStringAsync(FACEBOOK_BANNER_ID_IOS).isNotEmpty ? getStringAsync(FACEBOOK_BANNER_ID_IOS) : fbBannerIdIos;
  } else if (Platform.isAndroid) {
    return getStringAsync(FACEBOOK_BANNER_ID).isNotEmpty ? getStringAsync(FACEBOOK_BANNER_ID) : fbBannerId;
  }
  return null;
}

String? getInterstitialFacebookAdUnitId() {
  if (Platform.isIOS) {
    return getStringAsync(FACEBOOK_INTERSTITIAL_ID_IOS).isNotEmpty ? getStringAsync(FACEBOOK_INTERSTITIAL_ID_IOS) : fbInterstitialIdIos;
  } else if (Platform.isAndroid) {
    return getStringAsync(FACEBOOK_INTERSTITIAL_ID).isNotEmpty ? getStringAsync(FACEBOOK_INTERSTITIAL_ID) : fbInterstitialId;
  }
  return null;
}

Widget loadFacebookBannerId() {
  return FacebookBannerAd(
    placementId: kReleaseMode
        ? getBannerFacebookAdUnitId()!
        : isAndroid
            ? fbBannerId
            : fbBannerIdIos,
    bannerSize: BannerSize.STANDARD,
    listener: (result, value) {
      print("Banner Ad: $result -->  $value");
    },
  );
}
