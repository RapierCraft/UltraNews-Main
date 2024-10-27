import 'package:flutter/material.dart';
import 'package:mighty_sort_news/main.dart';
import '/../screens/user/MyFeedScreen.dart';
import '/../models/NewsData.dart';
import 'package:nb_utils/nb_utils.dart';
import 'BreakingNewsItemWidget.dart';

class BreakingNewsListWidget extends StatefulWidget {
  static String tag = '/BreakingNewsListWidget';
  final List<NewsData>? newsList;

  BreakingNewsListWidget(this.newsList);

  @override
  BreakingNewsListWidgetState createState() => BreakingNewsListWidgetState();
}

class BreakingNewsListWidgetState extends State<BreakingNewsListWidget> {

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return HorizontalList(
      padding: EdgeInsets.only(left: 16, right: 16),
      physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        NewsData newsData = widget.newsList![index];

        if(userPreferenceCategoriesDocs.isNotEmpty && !userPreferenceCategoriesDocs.contains(newsData.categoryRef)){
          return Container();
        }

        return BreakingNewsItemWidget(
          newsData,
          onTap: () => MyFeedScreen(ind: index, name: 'Breaking News'.toUpperCase(), news: widget.newsList).launch(context, pageRouteAnimation: PageRouteAnimation.Slide),
        );
      },
      itemCount: widget.newsList!.length,
    );
  }
}
