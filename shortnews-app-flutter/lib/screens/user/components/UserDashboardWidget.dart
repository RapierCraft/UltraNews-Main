import 'dart:async';
import 'package:async/async.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '/../screens/user/MyFeedScreen.dart';
import '/../main.dart';
import '/../models/DashboardResponse.dart';
import '/../models/NewsData.dart';
import '/../screens/user/UserCategoryFragment.dart';
import '/../utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/AppWidgets.dart';
import '../../../models/CategoryData.dart';
import 'UserNewsListWidget.dart';
import 'BreakingNewsListWidget.dart';
import 'TrendingNewsWidget.dart';
import 'ViewAllHeadingWidget.dart';

class UserDashboardWidget extends StatefulWidget {
  final AsyncSnapshot<DashboardResponse> snap;

  UserDashboardWidget(this.snap);

  @override
  UserDashboardWidgetState createState() => UserDashboardWidgetState();
}

class UserDashboardWidgetState extends State<UserDashboardWidget> with SingleTickerProviderStateMixin {
  CarouselController controller = CarouselController();
  String mBreakingNewsMarquee = '';
  List<NewsData> categoryWiseData = [];

  AsyncMemoizer asyncMemoizer = AsyncMemoizer<List<String>>();
  List<String> json = [];
  int index = 0;
  int? selectedIndex = 1;
  String? selectedUi;
  String? name;
  List<NewsData> newsData = [];
  List<NewsData> notificationNewsData = [];
  List<NewsData> notificationData = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    selectedIndex = 1;
    mBreakingNewsMarquee = '';

    widget.snap.data!.breakingNews.validate().forEach((element) {
      mBreakingNewsMarquee = mBreakingNewsMarquee + ' | ' + element.title!;
    });
  }


  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget breakingNewsWidget() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          16.height,
          ViewAllHeadingWidget(
            title: languages.breakingNews.toUpperCase(),
            onTap: () {
              if (widget.snap.data!.breakingNews.validate().isNotEmpty)
                MyFeedScreen(news: widget.snap.data!.breakingNews.validate(), name: languages.breakingNews).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
            },
          ),
          8.height,
          BreakingNewsListWidget(widget.snap.data!.breakingNews),
        ],
      ).visible(widget.snap.data!.breakingNews.validate().isNotEmpty);
    }

    Widget recentNewsWidget() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          16.height,
          ViewAllHeadingWidget(
            title: languages.recentNews.toUpperCase(),
            onTap: () {
              if (widget.snap.data!.recentNews.validate().isNotEmpty) MyFeedScreen(news: widget.snap.data!.recentNews.validate(), name: languages.recentNews).launch(context);
            },
          ),
          UserNewsListWidget(list: widget.snap.data!.recentNews.validate(), name:languages.recentNews, len: widget.snap.data!.recentNews!.take(3).length),
        ],
      ).visible(widget.snap.data!.recentNews.validate().isNotEmpty);
    }


    Widget categoryWidget() {
      return FutureBuilder<List<CategoryData>>(
        future: categoryService.categoriesFuture(),
        builder: (_, snap) {
          if (snap.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                16.height,
                ViewAllHeadingWidget(
                  title: languages.myTopics.toUpperCase(),
                  onTap: () {
                    UserCategoryFragment().launch(context);
                  },
                ),
                CarouselSlider.builder(
                  carouselController: controller,
                  itemCount: snap.data!.length,
                  itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                    snap.data!.forEachIndexed((element, i) {
                      if (i == selectedIndex) {
                        selectedUi = element.id;
                      }
                    });

                    return GestureDetector(
                      onTap: () {
                        selectedIndex = itemIndex;
                        controller.animateToPage(selectedIndex!);
                        log(selectedIndex);
                        snap.data!.forEachIndexed((element, i) {
                          if (i == selectedIndex) {
                            selectedUi = element.id;
                            name = element.name;

                            log(name);
                            log(selectedUi);
                            newsService.getNewsOfCategory(categoryService.ref!.doc(selectedUi)).then((value) {
                              newsData = value;
                              MyFeedScreen(news: newsData, name: name).launch(context, pageRouteAnimation: PageRouteAnimation.Slide, duration: Duration(milliseconds: 100));
                            });
                            setState(() {});
                          }
                        });
                      },
                      child: Column(
                        children: [
                          cachedImage(snap.data![itemIndex].image, height: 130, width: 130, fit: BoxFit.fitHeight).cornerRadiusWithClipRRect(8).expand(),
                          8.height,
                          Text(snap.data![itemIndex].name.toString(),
                              style: boldTextStyle(
                                  color: itemIndex == selectedIndex
                                      ? appStore.isDarkMode
                                          ? textPrimaryColorGlobal
                                          : colorPrimary
                                      : textPrimaryColorGlobal),
                              maxLines: 1),
                        ],
                      ),
                    );
                  },
                  options: CarouselOptions(
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    onPageChanged: (i, v) {
                      selectedIndex = i;
                      log(selectedIndex);

                      snap.data!.forEachIndexed((element, i) {
                        if (i == selectedIndex) {
                          selectedUi = element.id;
                          name = element.name;

                          log(name);
                          log(selectedUi);
                          setState(() {});
                        }
                      });
                    },
                    initialPage: 1,
                    aspectRatio: 3.5,
                    viewportFraction: 0.28,
                  ),
                ),
                Container(margin: EdgeInsets.only(top: 8), height: 5, width: 40, decoration: boxDecorationDefault(color: appStore.isDarkMode ? textPrimaryColorGlobal : colorPrimary)).center(),
                StreamBuilder<List<NewsData>>(
                  stream: newsService.getNewsByCategory(categoryService.ref!.doc(selectedUi)),
                  builder: (_, snap) {
                    if (snap.hasData) {
                      if (snap.data!.isEmpty) {
                        return Column(
                          children: [
                            16.height,
                            noDataWidget(),
                          ],
                        );
                      }
                      newsData = snap.data!;
                      return Column(
                        children: [
                          UserNewsListWidget(name: name, list: newsData, len: newsData.take(3).length),
                          GestureDetector(
                              onTap: () {
                                MyFeedScreen(news: newsData, name: name).launch(context, pageRouteAnimation: PageRouteAnimation.Slide, duration: Duration(milliseconds: 100));
                              },
                              child: Text('View all', style: boldTextStyle(color: colorPrimary)).center().visible(snap.data!.length >= 4)),
                        ],
                      );
                    } else {
                      return snapWidgetHelper(snap);
                    }
                  },
                ),
              ],
            );
          }
          return SizedBox();
        },
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          breakingNewsWidget(),
          TrendingWidget(),
          if (widget.snap.data!.recentNews.validate().isNotEmpty) recentNewsWidget(),
          categoryWidget(),
          16.height,
        ],
      ),
    );
  }
}
