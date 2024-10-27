import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view.dart';
import '../models/AudiencePollModel.dart';
import '../utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../main.dart';
import 'AppImages.dart';
import 'Constants.dart';
import 'package:any_link_preview/any_link_preview.dart';

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

String parseDocumentDate(DateTime dateTime, [bool includeTime = false]) {
  if (includeTime) {
    return DateFormat('dd MMM, yyyy hh:mm a').format(dateTime);
  } else {
    return DateFormat('dd MMM, yyyy').format(dateTime);
  }
}

InputDecoration inputDecoration({String? labelText, String? hintText}) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: secondaryTextStyle(),
    hintText: hintText,
    filled: true,
    hintStyle: secondaryTextStyle(),
    fillColor: Colors.grey.withOpacity(0.15),
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary.withOpacity(0.5)), borderRadius: BorderRadius.circular(defaultRadius)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary), borderRadius: BorderRadius.circular(defaultRadius)),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(defaultRadius)),
    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(defaultRadius)),
    alignLabelWithHint: true,
  );
}

Future<void> launchUrlWidget(String url, {bool forceWebView = false}) async {
  log(url);
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication).catchError((e) {
    log(e);
    toast('Invalid URL: $url');
  });
}

double newsListWidgetSize(BuildContext context) => isWeb ? 300 : context.width() * 0.6;

bool isLoggedInWithGoogle() {
  return appStore.isLoggedIn && getStringAsync(LOGIN_TYPE) == LoginTypeGoogle;
}

bool isLoggedInWithApp() {
  return appStore.isLoggedIn && getStringAsync(LOGIN_TYPE) == LoginTypeApp;
}

bool isLoggedInWithApple() {
  return appStore.isLoggedIn && getStringAsync(LOGIN_TYPE) == LoginTypeApple;
}

bool isLoggedInWithOTP() {
  return appStore.isLoggedIn && getStringAsync(LOGIN_TYPE) == LoginTypeOTP;
}

String storeBaseURL() {
  return isAndroid ? playStoreBaseURL : appStoreBaseUrl;
}

// void setDynamicStatusBarColor({int delay = 200}) {
//   if (appStore.isDarkMode) {
//     //setStatusBarColor(scaffoldSecondaryDark, delayInMilliSeconds: delay);
//   } else {
//     //setStatusBarColor(Colors.white, delayInMilliSeconds: delay);
//   }
// }

// Color getAppBarWidgetBackGroundColor() {
//   return appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white;
// }
//
// Color getAppBarWidgetTextColor() {
//   return appStore.isDarkMode ? white : black;
// }

void setTheme() {
  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);

  if (themeModeIndex == ThemeModeLight) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == ThemeModeDark) {
    appStore.setDarkMode(true);
  }
}

void setPostViewsList() {
  String s = getStringAsync(POST_VIEWED_LIST);

  if (s.isNotEmpty) {
    Iterable it = jsonDecode(s);

    postViewedList.clear();
    postViewedList.addAll(it.map((e) => e.toString()).toList());
  }
}

List<LanguageDataModel> list = [
  LanguageDataModel(id: 0, name: 'English', languageCode: 'en', flag: 'assets/flags/ic_us.png', fullLanguageCode: 'en-EN'),
  LanguageDataModel(id: 1, name: 'हिंदी', languageCode: 'hi', flag: 'assets/flags/ic_india.png', fullLanguageCode: 'hi-IN'),
  LanguageDataModel(id: 2, name: 'français', languageCode: 'fr', flag: 'assets/flags/ic_french.png', fullLanguageCode: 'fr-FR'),
  LanguageDataModel(id: 3, name: 'عربى', languageCode: 'ar', flag: 'assets/flags/ic_ar.png', fullLanguageCode: 'ar-AR'),
];

double getPollPercentage({List<UserData>? answerList, String? answer}) {
  double percentage = 0.0;
  if (answerList!.isNotEmpty) {
    int count = 0;
    answerList.forEach((e) {
      if (answer == e.pollAnswer) {
        count++;
      }
    });

    percentage = (count / answerList.length) * 100;
    return percentage;
  } else {
    return percentage;
  }
}

class CustomBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

List<String> filterSearchResults(String query, List<String> tagList) {
  List<String> dummySearchList = [];
  dummySearchList.addAll(tagList);
  if (query.isNotEmpty) {
    List<String> dummyListData = [];
    dummySearchList.forEach((item) {
      if (item.toLowerCase().contains(query.toLowerCase())) {
        dummyListData.add(item);
      }
    });
    return dummyListData;
  } else {
    return tagList;
  }
}

List<String> pollDurationList = ['6 Hour', '12 Hour', '24 Hour'];

List<String> tagList = [
  '#Politics',
  '#Sport',
  '#Business',
  '#Economy',
  '#Education',
  '#Government',
  '#Police',
  '#Bollywood',
  '#Food',
  '#Electricity',
];

String getYoutubeThumbnail(String url) {
  String thumbnail = '';
  String? videoId = YoutubePlayer.convertUrlToId(url);
  thumbnail = "https://img.youtube.com/vi/$videoId/maxresdefault.jpg";
  return thumbnail;
}

String? getBannerAdUnitId() {
  if (Platform.isIOS) {
    return getStringAsync(ADMOB_BANNER_ID_IOS);
  } else if (Platform.isAndroid) {
    return getStringAsync(ADMOB_BANNER_ID);
  }
  return null;
}

String? getInterstitialAdUnitId() {
  if (Platform.isIOS) {
    return getStringAsync(ADMOB_INTERSTITIAL_ID_IOS);
  } else if (Platform.isAndroid) {
    return getStringAsync(ADMOB_INTERSTITIAL_ID);
  }
  return null;
}

bool mConfirmationDialog({Function? onTap, BuildContext? context}) {
  showConfirmDialogCustom(context!,
      transitionDuration: Duration(microseconds: 1),
      dialogType: DialogType.CONFIRMATION,
      primaryColor: colorPrimary,
      negativeText: languages.no,
      positiveText: languages.yes,
      customCenterWidget: Icon(Icons.logout, color: colorPrimary, size: 40),
      title: languages.exitMsg, onAccept: (c) {
    exit(0);
  });
  return true;
}

bool getDeviceTypePhone() {
  final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  return data.size.shortestSide < 600 ? true : false;
}

Widget dotIndicator(list, i) {
  return SizedBox(
    height: 16,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        list.length,
        (ind) {
          return Container(
            height: 4,
            width: 20,
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: i == ind
                    ? appStore.isDarkMode == true
                        ? Colors.white
                        : colorPrimary
                    : Colors.grey.withOpacity(0.5),
                borderRadius: radius(4)),
          );
        },
      ),
    ),
  );
}

Widget loader() {
  return Lottie.asset(appStore.isDarkMode ? ic_loader_dark : ic_loader, width: 60, height: 60).center();
}


void openPhotoViewer(BuildContext context, ImageProvider imageProvider) {
  Scaffold(
    body: Stack(
      children: <Widget>[
        PhotoView(
          imageProvider: imageProvider,
          minScale: PhotoViewComputedScale.contained,
          maxScale: 1.0,
        ),
        Positioned(top: 35, left: 16, child: BackButton(color: Colors.white)),
      ],
    ),
  ).launch(context);
}

