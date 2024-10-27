import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mighty_sort_news/models/NewsData.dart';
import 'package:mighty_sort_news/models/UserPreferenceCategory.dart';
import 'package:mighty_sort_news/screens/user/MyFeedScreen.dart';
import 'package:mighty_sort_news/screens/user/SignInScreen.dart';
import 'package:mighty_sort_news/screens/user/WalkThroughScreen.dart';
import 'package:mighty_sort_news/services/AuthService.dart';
import 'package:video_player/video_player.dart';
import '../models/BannerAdModel.dart';
import '../models/CategoryData.dart';
import '../utils/AppImages.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../main.dart';
import 'admin/AdminDashboardScreen.dart';
import 'admin/AdminLoginScreen.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  VideoPlayerController? _controller;
  String localCategories = '';
  bool showLoader = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if(isWeb) {
      await 10.milliseconds.delay;
    } else {
      print(getBoolAsync(IS_FIRST_TIME, defaultValue: true));
      print("IS_FIRST_TIME");
      if(getBoolAsync(IS_FIRST_TIME, defaultValue: true)) {
        _controller = VideoPlayerController.asset('assets/splash_loader.mp4')
          ..initialize().then((_) {
            if (isMobile && (getBoolAsync(IS_FIRST_TIME, defaultValue: true))) {
              _controller!.play();
            }
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });
        await 3.seconds.delay;
      }
    }

    // List<CategoryData> cats = await categoryService.categoriesFuture();

    // List<UserPreferenceCategory> cats = await userPreferenceService.getPreferences();
    //
    // List<DocumentReference> catReferences = [];
    //
    // cats.forEach((element) {
    //     // catReferences.add(categoryService.ref!.doc(element.id));
    //     catReferences.add(categoryService.ref!.doc(element.categoryId));
    // });

    /// Setting times app is opened
    int val = getIntAsync(TIMES_OPENED, defaultValue: 1);
    setValue(TIMES_OPENED, (val + 1));

    /// Getting preferences list

    setStatusBarColor(transparentColor, statusBarIconBrightness: appStore.isDarkMode ? Brightness.dark : Brightness.light);
    // await appSettingService.setAppSettings();

    if (!isMobile) {
      /// For Web & MacOS
      if (appStore.isLoggedIn) {
        AdminDashboardScreen().launch(context, isNewTask: true);
      } else {
        AdminLoginScreen().launch(context, isNewTask: true);
      }
    } else {
      /// For Mobile
      await setBookmarkList();


      // localCategories = getStringAsync(APP_CATEGORIES_LOCAL, defaultValue: '');
      //
      // if(localCategories != ''){
      //
      // } else {
      //   appCategories = await categoryService.categoriesFuture();
      //   setValue(APP_CATEGORIES_LOCAL, jsonEncode(appCategories));
      // }

      appCategories = await categoryService.categoriesFuture();

      // if (getBoolAsync(IS_FIRST_TIME, defaultValue: true)) {
      //   WalkThroughScreen().launch(context, isNewTask: true);
      // } else {
        // print(catReferences);
        /// TO DO
        /// Call News List by categories
        // newsService.getNewsList().then((value) async {
        //   print("Is banner loaded: ${bannerAdModel.isAdLoaded}");
          appStore.setRedirectIndex(0);

          // if(value.isNotEmpty){
          //   newsData.addAll(value);
          // }
          if(appStore.isLoggedIn){
            setState(() {
              showLoader = true;
            });

            // Assigning categories and preferences for users to user in the app
            // appCategories = await categoryService.categoriesFuture();
            // print("appCategories $appCategories");
            // List<UserPreferenceCategory> preferences = await userPreferenceService.getPreferences();
            print(getStringAsync(APP_CATEGORIES_LOCAL, defaultValue: ''));
            preferences = await userPreferenceService.getPreferences();
            //
            preferences.forEach((element) {
              CategoryData temp = appCategories.firstWhere((cat) => cat.id == element.categoryId);
              userPreferenceCategories.add(temp);
            });

            // print("userPreferenceCategories $userPreferenceCategories");


            List<DocumentReference> t = categoryService.convertDataToReference(userPreferenceCategories);
            userPreferenceCategoriesDocs = t;
            // print("userPreferenceCategoriesDocs $userPreferenceCategoriesDocs");


            await newsService.getNewsList().then((value) async {

              print("News List: $value");
              setState(() {
                showLoader = false;
              });
              newsDataDefault.clear();
              newsDataDefault.addAll(value);
              MyFeedScreen(news: value, name: languages.myFeed, isSplash: true, isDiscover: true, ind: 0).launch(context, isNewTask: true);
            });
            // MyFeedScreen(news: value, name: languages.myFeed, isSplash: true, isDiscover: true, ind: getIntAsync(REDIRECT_INDEX)).launch(context, isNewTask: true);
            // MyFeedScreen(news: value, name: languages.myFeed, isSplash: true, isDiscover: true, ind: 0).launch(context, isNewTask: true);
          } else{

            if (getBoolAsync(IS_FIRST_TIME, defaultValue: true)) {
              WalkThroughScreen().launch(context, isNewTask: true);
            } else {
              SignInScreen(isNewTask: true).launch(context);
            }
            // WalkThroughScreen().launch(context, isNewTask: true);
          }
        // });
      // }
    }


    if (getBoolAsync(DISABLE_AD) == false) {
      if (getStringAsync(AD_TYPE) == Admob) {
        adsService.getAdMobAds().then((value) {
          setValue(ADMOB_BANNER_ID, value.adMobBannerAd);
          setValue(ADMOB_INTERSTITIAL_ID, value.adMobInterstitialAd);
          setValue(ADMOB_BANNER_ID_IOS, value.adMobBannerIos);
          setValue(ADMOB_INTERSTITIAL_ID_IOS, value.adMobInterstitialIos);
        });
      } else {
        adsService.getFacebookAds().then((value) {
          setValue(FACEBOOK_BANNER_ID, value.faceBookBannerAd);
          setValue(FACEBOOK_INTERSTITIAL_ID, value.faceBookInterstitialAd);
          setValue(FACEBOOK_BANNER_ID_IOS, value.faceBookBannerIos);
          setValue(FACEBOOK_INTERSTITIAL_ID_IOS, value.faceBookInterstitialIos);
        });
      }
    } else {
      setValue(ADMOB_BANNER_ID, '');
      setValue(ADMOB_INTERSTITIAL_ID, '');
      setValue(ADMOB_BANNER_ID_IOS, '');
      setValue(ADMOB_INTERSTITIAL_ID_IOS, '');
      setValue(FACEBOOK_BANNER_ID, "");
      setValue(FACEBOOK_INTERSTITIAL_ID, "");
      setValue(FACEBOOK_BANNER_ID_IOS, "");
      setValue(FACEBOOK_INTERSTITIAL_ID_IOS, "");
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    if(_controller != null) {
      _controller!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkMode
      // ? scaffoldSecondaryDark
          ? Colors.black
          : isWeb
          ? colorPrimary.withOpacity(0.1)
          : context.scaffoldBackgroundColor,
      body:
      isWeb || !(getBoolAsync(IS_FIRST_TIME, defaultValue: true)) ?
      // isWeb ?
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
            Image.asset(ic_logo, height: 120),
            Text(appName, style: boldTextStyle(size: 22)),
          ],)),
          // Spacer(),
          Expanded(
            child: Visibility(
              visible: showLoader,
                child: loader()),
          )
        ],
      ).center() :
      Center(
        child: _controller!.value.isInitialized
            ? AspectRatio(
          aspectRatio: 0.54,
          child: VideoPlayer(_controller!),
        )
            : Container(),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isWeb
              ? Text('V ${getStringAsync(FLUTTER_WEB_BUILD_VERSION, defaultValue: '1.0.0')}')
              : Container(),
          // FutureBuilder<PackageInfo>(
          //         future: PackageInfo.fromPlatform(),
          //         builder: (_, snap) {
          //           if (snap.hasData) {
          //             return Text('V ${snap.data!.version.validate()}', style: secondaryTextStyle()).paddingBottom(8);
          //           }
          //           return SizedBox();
          //         },
          //       ),
          8.height,
        ],
      ),
    );
  }
}
