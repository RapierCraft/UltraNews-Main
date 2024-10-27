import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../utils/ResponsiveWidget.dart';
import '/../utils/Colors.dart';
import '/../main.dart';
import '/../screens/admin/components/MostViewedNewsWidget.dart';
import '/../screens/admin/components/RecentlyLoggedInUserWidget.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'RecentNewsWidget.dart';

class AdminStatisticsWidget extends StatefulWidget {
  static String tag = '/AdminStatisticsWidget';

  @override
  _AdminStatisticsWidgetState createState() => _AdminStatisticsWidgetState();
}

class _AdminStatisticsWidgetState extends State<AdminStatisticsWidget> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    Widget itemWidget(Color bgColor, Color textColor, String title, Widget desc, IconData icon, {Function? onTap}) {
      return Container(
        width:  ResponsiveWidget.isSmallScreen(context) ?context.width() * 0.35:context.width() * 0.18,
        height: 120,
        decoration: boxDecorationWithRoundedCorners(borderRadius: radius(16), backgroundColor: context.cardColor),
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                height: context.height() * 0.09,
                width: ResponsiveWidget.isSmallScreen(context) ?context.width() * 0.1:context.width() * 0.05,
                decoration: BoxDecoration(borderRadius: radius(16), color: bgColor.withOpacity(0.4)),
                child: Icon(icon, color: textColor, size: 35)),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                desc,
                Text(title, style: primaryTextStyle(color: textColor), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end).expand(),
              ],
            ).expand(),
          ],
        ),
      ).onTap(onTap, borderRadius: radius(16));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 16,
            children: [
              itemWidget(
                appStore.isDarkMode ? Colors.white : colorPrimary,
                appStore.isDarkMode ? Colors.white : colorPrimary,
                languages.totalNews,
                StreamBuilder<int>(
                  stream: newsService.getTotalNewsCount(),
                  builder: (_, snap) {
                    int? count = 0;
                    if (snap.hasError) log(snap.error);
                    if (snap.hasData) {
                      count = snap.data;
                    }
                    return Text(count.toString(), style: boldTextStyle(size: 30, color: appStore.isDarkMode ? Colors.white : colorPrimary));
                  },
                ),
                MaterialCommunityIcons.newspaper,
                onTap: () {
                  LiveStream().emit(StreamSelectItem, 2);
                },
              ),
              itemWidget(
                appStore.isDarkMode ? Colors.white : '#aafad7'.toColor(),
                appStore.isDarkMode ? Colors.white : '#099c5c'.toColor(),
                languages.totalCategories,
                StreamBuilder<int>(
                  stream: categoryService.totalCategoriesCount(),
                  builder: (_, snap) {
                    int? count = 0;
                    if (snap.hasError) log(snap.error);
                    if (snap.hasData) {
                      count = snap.data;
                    }
                    return Text(count.toString(), style: boldTextStyle(size: 30, color: appStore.isDarkMode ? Colors.white : '#099c5c'.toColor()));
                  },
                ),
                MaterialCommunityIcons.view_dashboard_outline,
                onTap: () {
                  LiveStream().emit(StreamSelectItem, 5);

                },
              ),
              itemWidget(
                appStore.isDarkMode ? Colors.white : '#ffb3c2'.toColor(),
                appStore.isDarkMode ? Colors.white : '#b30023'.toColor(),
                languages.totalUsers,
                StreamBuilder<int>(
                  stream: userService.totalUsersCount(),
                  builder: (_, snap) {
                    int? count = 0;
                    if (snap.hasError) log(snap.error);
                    if (snap.hasData) {
                      count = snap.data;
                    }
                    return Text(count.toString(), style: boldTextStyle(size: 30, color: appStore.isDarkMode ? Colors.white : '#b30023'.toColor()));
                  },
                ),
                FontAwesome.users,
                onTap: () {
                  LiveStream().emit(StreamSelectItem, 7);
                },
              ),
            ],
          ).paddingOnly(left: 16, top: 16,right: getStringAsync(SELECTED_LANGUAGE_CODE) == 'ar' ?16:0),
          //endregion
          30.height,
          MostViewedNewsWidget(),
          RecentNewsWidget(newsType:languages.recentNews,filterBy: NewsTypeRecent),
          RecentNewsWidget(newsType: languages.breakingNews,filterBy: NewsTypeBreaking),
          16.height,
          RecentlyLoggedInUserWidget(),
          16.height,
        ],
      ),
    );
  }
}
