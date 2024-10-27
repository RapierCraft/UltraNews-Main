import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mighty_sort_news/screens/user/SettingScreen.dart';
import '/../screens/user/MyFeedScreen.dart';
import '/../screens/user/NotificationScreen.dart';
import '/../models/DashboardResponse.dart';
import '/../screens/user/SearchScreen.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:page_transition/page_transition.dart';
import '../../main.dart';
import '../../models/NewsData.dart';
import 'components/UserDashboardWidget.dart';

class HomeFragment extends StatefulWidget {
  static String tag = '/HomeFragment';

  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> with AutomaticKeepAliveClientMixin {
  var begin = Offset(2.0, 0.0);
  var end = Offset.zero;
  var curve = Curves.linear;
  var tween;

  List<NewsData> list = [];

  @override
  void initState() {
    super.initState();
    // init();
  }

  Future<void> init() async {
    list.clear();
    list.addAll(newsDataDefault);
    setState(() {});
    // await Future.delayed(Duration(milliseconds: 400));
    //
    // await newsService.getNewsList().then((value) {
    //
    //   newsDataDefault.clear();
    //   newsDataDefault.addAll(value);
    //
    //   list.addAll(value);
    //   // value.forEach((element) {
    //   //   list.add(element);
    //   // });
    // });

  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // print(appCategories);
    // print(userPreferenceCategories);
    super.build(context);
    if (getIntAsync(THEME_MODE_INDEX) == ThemeModeSystem) {
      appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.dark);
    }
    window.onPlatformBrightnessChanged = () {
      if (getIntAsync(THEME_MODE_INDEX) == ThemeModeSystem) {
        appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.dark);
      }
    };
    return RefreshIndicator(
      color: colorPrimary,
      onRefresh: () async {
        /// If you want to update app setting every time when you refresh home page
        /// Uncomment the below line
        appSettingService.setAppSettings();
        setState(() {});
        newsService.getNewsList().then((value) {
          value.forEach((element) {
            list.add(element);
          });
        });

        await 2.seconds.delay;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(languages.discover, style: boldTextStyle(size: 20)),
              Container(margin: EdgeInsets.only(top: 8), height: 5, width: 40, decoration: boxDecorationDefault(color: appStore.isDarkMode ? textPrimaryColorGlobal : colorPrimary)),
            ],
          ),
          backgroundColor: context.scaffoldBackgroundColor,
          centerTitle: true,
          leadingWidth: 160,
          elevation: 1,
          leading: Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context, PageTransition(type: getStringAsync(SELECTED_LANGUAGE_CODE) == 'ar' ? PageTransitionType.rightToLeft : PageTransitionType.leftToRight, child: SettingScreen()));
                  },
                  icon: Icon(Ionicons.settings_outline),
                  color: appStore.isDarkMode ? context.iconColor : colorPrimary),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context, PageTransition(type: getStringAsync(SELECTED_LANGUAGE_CODE) == 'ar' ? PageTransitionType.rightToLeft : PageTransitionType.leftToRight, child: NotificationScreen()));
                  },
                  icon: Icon(Ionicons.notifications_outline),
                  color: appStore.isDarkMode ? context.iconColor : colorPrimary)
            ],
          ),
          actions: [
            TextIcon(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    duration: Duration(milliseconds: 200),
                    type: getStringAsync(SELECTED_LANGUAGE_CODE) == 'ar' ? PageTransitionType.rightToLeft : PageTransitionType.rightToLeft,
                    child: MyFeedScreen(news: [...list], name: languages.myFeed, ind: getIntAsync(REDIRECT_INDEX), isDiscover: true),
                  ),
                );
              },
              text: languages.myFeed,
              suffix: Icon(Icons.arrow_forward_ios_rounded, color: context.iconColor, size: 18),
            )
          ],
        ),
        body: GestureDetector(
          onHorizontalDragEnd: (v) {
            if (v.velocity.pixelsPerSecond.dx.isNegative) {
              if(list.isEmpty){
                list.clear();
                list.addAll(newsDataDefault);
              }
              print("dragged negative");
              print("Home List: ${list.length}");
              print("Home List default: ${newsDataDefault.length}");
              MyFeedScreen(news: [...newsDataDefault], name: languages.myFeed, ind: getIntAsync(REDIRECT_INDEX), isDiscover: true)
                  .launch(context, pageRouteAnimation: PageRouteAnimation.Slide, duration: Duration(milliseconds: 100));
            }
          },
          child: FutureBuilder<DashboardResponse>(
            initialData: newsService.getCachedUserDashboardData(),
            future: newsService.getUserDashboardData(),
            builder: (_, snap) {
              if (snap.hasData) {
                return UserDashboardWidget(snap);
              }
              return snapWidgetHelper(snap,
                  errorWidget: Container(child: Text(errorSomethingWentWrong, style: primaryTextStyle()).paddingAll(16).center(), height: context.height() - 180, width: context.width()),
                  loadingWidget: loader());
            },
          ),
        ),
        floatingActionButton: GestureDetector(
          onTap: () {
            SearchScreen().launch(context);
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: boxDecorationWithShadow(backgroundColor: colorPrimary, boxShape: BoxShape.circle),
            child: Icon(Ionicons.search_outline, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
