import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../models/NewsData.dart';
import '../../../utils/Constants.dart';
import '../MyFeedScreen.dart';
import 'UserNewsItemWidget.dart';
import 'ViewAllHeadingWidget.dart';

class TrendingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NewsData>>(
      future: newsService.getMostViewedNewsFuture(limit: DocLimit),
      builder: (_, snap) {
        if (snap.hasData) {
          return Column(
            children: [
              16.height,
              ViewAllHeadingWidget(
                title: languages.lblTrendingNews.toUpperCase(),
                onTap: () {
                  if (snap.data!.validate().isNotEmpty) MyFeedScreen(news: snap.data!.validate(), name: languages.lblTrendingNews).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                },
                isAdmin: false,
              ),
              ListView.builder(
                shrinkWrap: true,
                primary: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snap.data!.length >= 3 ? snap.data!.take(3).length : snap.data!.length,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (_, index) {
                  NewsData data = snap.data![index];
                  if(userPreferenceCategoriesDocs.isNotEmpty && !userPreferenceCategoriesDocs.contains(data.categoryRef)){
                    return Container();
                  }
                  return UserNewsItemWidget(
                    newsData: data,
                    isTrending: true,
                    onTap: () {
                      MyFeedScreen(news: snap.data!, name: languages.trendingNews.toUpperCase(), ind: index).launch(context);
                    },
                  );
                },
              ),
            ],
          );
        }
        return snapWidgetHelper(snap, loadingWidget: SizedBox());
      },
    );
  }
}
