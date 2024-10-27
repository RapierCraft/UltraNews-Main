import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mighty_sort_news/models/NewsData.dart';
import 'package:mighty_sort_news/screens/CategoryPreferenceScreen.dart';
import 'package:mighty_sort_news/screens/user/SignInScreen.dart';
import 'package:mighty_sort_news/screens/user/WalkThroughScreen.dart';
import 'package:mighty_sort_news/services/UserPreferenceService.dart';
import '../screens/user/NoInternetConnection.dart';
import '../utils/CustomScrollBehaviour.dart';
import '../screens/SplashScreen.dart';
import '../services/AdsService.dart';
import '../services/AppSettingService.dart';
import '../services/AudiencePollService.dart';
import '../services/CategoryService.dart';
import '../services/NewsService.dart';
import '../services/NotificationService.dart';
import '../services/UserService.dart';
import '../store/AppStore.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'AppTheme.dart';
import 'languages/AppLocalizations.dart';
import 'languages/BaseLanguage.dart';
import 'models/BannerAdModel.dart';
import 'models/CategoryData.dart';
import 'models/FontSizeModel.dart';
import 'models/UserPreferenceCategory.dart';

AppStore appStore = AppStore();

FirebaseFirestore db = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

LanguageDataModel? language;
late BaseLanguage languages;
FontSizeModel? fontSize;
List<FontSizeModel> fontSizes = FontSizeModel.fontSizes();

NewsService newsService = NewsService();
CategoryService categoryService = CategoryService();
UserService userService = UserService();
UserPreferenceService userPreferenceService = UserPreferenceService();
AppSettingService appSettingService = AppSettingService();
AudiencePollService audiencePollService = AudiencePollService();
NotificationService notificationService = NotificationService();
AdsService adsService = AdsService();

AppLocalizations? appLocalizations;
bool isCurrentlyOnNoInternet = false;

late YoutubePlayerController youtubePlayerController;
late TextEditingController idController;
late TextEditingController seekToController;
late PlayerState playerState;
late YoutubeMetaData videoMetaData;

List<String?> bookmarkList = [];
List<String?> postViewedList = [];
List<NewsData> newsDataDefault = [];


int mAdShowCount = 0;

// BannerAdModel bannerAdModel = BannerAdModel();
List<CategoryData> userPreferenceCategories = [];
List<CategoryData> appCategories = [];
List<DocumentReference> userPreferenceCategoriesDocs = [];
List<UserPreferenceCategory> preferences = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (isMobile) {
    await initialize();
    await OneSignal.shared.setAppId(mOneSignalAppId);
    OneSignal.shared.consentGranted(true);
    OneSignal.shared.promptUserForPushNotificationPermission();

    OneSignal.shared.getDeviceState().then((value) {
      if (value!.userId != null) setValue(PLAYER_ID, value.userId.validate());
    });
  }
  defaultAppBarElevation = 2.0;

  desktopBreakpointGlobal = 700.0;

  defaultAppButtonTextColorGlobal = colorPrimary;
  appButtonBackgroundColorGlobal = colorPrimary;

  await initialize(
    aLocaleLanguageList: [
      LanguageDataModel(id: 0, name: 'English', languageCode: 'en', flag: 'assets/flags/ic_us.png', fullLanguageCode: 'en-EN'),
      LanguageDataModel(id: 1, name: 'हिंदी', languageCode: 'hi', flag: 'assets/flags/ic_india.png', fullLanguageCode: 'hi-IN'),
      LanguageDataModel(id: 2, name: 'français', languageCode: 'fr', flag: 'assets/flags/ic_french.png', fullLanguageCode: 'fr-FR'),
      LanguageDataModel(id: 3, name: 'عربى', languageCode: 'ar', flag: 'assets/flags/ic_ar.png', fullLanguageCode: 'ar-AR'),
      LanguageDataModel(id: 4, name: 'Türk', languageCode: 'tr', flag: 'assets/flags/ic_turkey.png', fullLanguageCode: 'tr-TR'),
      LanguageDataModel(id: 5, name: 'português', languageCode: 'pt', flag: 'assets/flags/ic_pt.png', fullLanguageCode: 'pt-PT'),
      LanguageDataModel(id: 6, name: 'Afrikaans', subTitle: 'Afrikaans', languageCode: 'af', fullLanguageCode: 'af-AF', flag: 'assets/flags/ic_af.png'),

    ],
    defaultLanguage: defaultValues.defaultLanguage,
  );

  appStore.setLanguage(getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: defaultValues.defaultLanguage));
  appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));

  if (appStore.isLoggedIn) {
    appStore.setUserId(getStringAsync(USER_ID));
    appStore.setAdmin(getBoolAsync(IS_ADMIN));
    appStore.setTester(getBoolAsync(IS_TESTER));
    appStore.setFullName(getStringAsync(FULL_NAME));
    appStore.setUserEmail(getStringAsync(USER_EMAIL));
    appStore.setUserProfile(getStringAsync(PROFILE_IMAGE));
  }

  fontSize = fontSizes.firstWhere((element) => element.fontSize == getIntAsync(FONT_SIZE_PREF, defaultValue: 18));
  setTheme();
  setPostViewsList();

  if (isWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyCCoBJ_Zd9lFjtXHJLWgz_SQ2mDi61Odr0",
          authDomain: "ultranews-3a7d6.firebaseapp.com",
          projectId: "ultranews-3a7d6",
          storageBucket: "$mFirebaseAppId",
          messagingSenderId: "414650446310",
          appId: "1:414650446310:web:9c383e0632e8f7c2d82627",
          measurementId: "G-0PF85DLPXC"),
    );
  } else {
    await Firebase.initializeApp();
  }

  if (isMobile) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    MobileAds.instance.initialize();
    // if(bannerAdModel.isAdLoaded == false){
    //   bannerAdModel.buildBannerAd()..load();
    // }
  }


  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((e) {
      if (e == ConnectivityResult.none) {
        log('not connected');
        isCurrentlyOnNoInternet = true;
        push(NoInternetConnection());
      } else {
        if (isCurrentlyOnNoInternet) {
          pop();
          isCurrentlyOnNoInternet = false;
          toast('Internet is connected.');
        }
        log('connected');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setOrientationPortrait();
    appStore.setDarkMode(true);
    // print("appStore.isDarkMode ${appStore.isDarkMode}");
    return Observer(
      builder: (_) => MaterialApp(
        title: appName,
        scrollBehavior: isMobile ? SBehavior() : CustomScrollBehavior(),
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        supportedLocales: LanguageDataModel.languageLocales(),
        localizationsDelegates: [
          AppLocalizations(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguageCode.validate(value: appStore.selectedLanguageCode)),
        home: SplashScreen(),
        // home: WalkThroughScreen(),
        // home: CategoryPreferenceScreen(),
      ),
    );
  }
}



