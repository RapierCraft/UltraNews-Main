import 'package:flutter/material.dart';
import 'package:mighty_sort_news/screens/user/SignInScreen.dart';
import '../../utils/AppImages.dart';
import '/../models/WalkThroughModel.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';

class WalkThroughScreen extends StatefulWidget {
  static String tag = '/WalkThroughScreen';

  @override
  WalkThroughScreenState createState() => WalkThroughScreenState();
}

class WalkThroughScreenState extends State<WalkThroughScreen> {
  PageController pageController = PageController();

  List<WalkThroughModel> list = [];
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //setStatusBarColor(colorPrimary);
    list.add(
      WalkThroughModel(
        image:ic_Walk1,
        title: appName,
        subTitle: 'Get your news under 75 words, save time and be notified!',
        color: colorPrimary,
      ),
    );
    list.add(
      WalkThroughModel(
        image: ic_Walk2,
        title: 'Choose your category',
        subTitle: 'UltraNews is a complete set of incredible, easily importable UI and get regular updates by subscribing to it!',
        color: Color(0xFF6BD19B),
      ),
    );
    list.add(
      WalkThroughModel(
        image: ic_Walk3,
        title: 'Daily Notifications',
        subTitle: 'Notify your users with the latest news with a daily push notification feature. They are highly interactive and useful.',
        color: Color(0xFFA79BFC),
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            color: colorPrimary,
            child: PageView(
              controller: pageController,
              children: list.map((e) {
                return Container(
                  height: context.height() * 0.1,
                  width: context.width() * 0.2,
                  margin: EdgeInsets.only(left: 40, right: 40, top: 90),
                  padding: EdgeInsets.all(6),
                  decoration: boxDecorationWithShadow(border: Border.all(width: 10), backgroundColor: context.scaffoldBackgroundColor, borderRadius: radiusOnly(topLeft: 30, topRight: 30)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(ic_logo, height: 120),
                      // 0.height,
                      Image.asset(e.image!, width: context.width() * 0.8, fit: BoxFit.fitWidth),
                    ],
                  ),
                );
              }).toList(),
              onPageChanged: (i) {
                currentPage = i;
                setState(() {});
              },
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              dotIndicator(list, currentPage),
              16.height,
              Container(
                height: context.height() * 0.35,
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: boxDecorationWithShadow(backgroundColor: context.scaffoldBackgroundColor),
                child: Column(
                  children: [
                    24.height,
                    Text(list[currentPage].title!, style: boldTextStyle(size: 24), textAlign: TextAlign.center),
                    16.height,
                    Text(list[currentPage].subTitle!, style: primaryTextStyle(), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: context.statusBarHeight + 4,
            right: 20,
            child: Text(languages.skip, style: secondaryTextStyle(size: 16, color: Colors.white)).onTap(() async {
              await setValue(IS_FIRST_TIME, false);
              appStore.setRedirectIndex(0);
              SignInScreen(isNewTask: true).launch(context);
              // newsService.getNewsList().then((value) {
              //   MyFeedScreen(news: value, name: languages.myFeed, isSplash: true, ind: getIntAsync(REDIRECT_INDEX)).launch(context, isNewTask: true);
              // });
            }),
          ),
          Positioned(
            bottom: 30,
            right: 16,
            child: Container(
              child: Icon(Icons.arrow_forward_ios, color: Colors.white),
              decoration: boxDecorationWithShadow(boxShape: BoxShape.circle, backgroundColor: colorPrimary),
              padding: EdgeInsets.all(16),
            ).onTap(() async {
              if (currentPage == 2) {
                await setValue(IS_FIRST_TIME, false);
                appStore.setRedirectIndex(0);
                SignInScreen(isNewTask: true).launch(context);
                //
                // newsService.getNewsList().then((value) {
                //   MyFeedScreen(news: value, name: languages.myFeed, isSplash: true, ind: getIntAsync(REDIRECT_INDEX)).launch(context, isNewTask: true);
                // });
              } else {
                pageController.animateToPage(currentPage + 1, duration: Duration(milliseconds: 300), curve: Curves.linear);
              }
            }).paddingOnly(left: 16, right: 16),
          ),
        ],
      ),
    );
  }
}
