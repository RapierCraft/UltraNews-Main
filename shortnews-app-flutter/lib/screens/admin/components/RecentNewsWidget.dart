import 'package:flutter/material.dart';
import '../../user/components/ViewAllHeadingWidget.dart';
import '/../main.dart';
import '/../models/NewsData.dart';
import '/../screens/admin/UploadNewsScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import 'NewsItemGridWidget.dart';

class RecentNewsWidget extends StatefulWidget {
  final String? newsType;
  final String? filterBy;

  RecentNewsWidget({this.filterBy, this.newsType});

  static String tag = '/MostViewedNewsWidget';

  @override
  State<RecentNewsWidget> createState() => _RecentNewsWidgetState();
}

class _RecentNewsWidgetState extends State<RecentNewsWidget> {
  List<NewsData> data = [];

  @override
  Widget build(BuildContext context) {
    // log(widget.newsType.toString());
    return StreamBuilder<List<NewsData>>(
      stream: newsService.getNews(newsType: widget.filterBy.validate()),
      builder: (_, snap) {
        if (snap.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (snap.data != null && snap.data!.isNotEmpty) 16.height,
              if (snap.data != null && snap.data!.isNotEmpty) ViewAllHeadingWidget(title: (widget.newsType.capitalizeFirstLetter()).toUpperCase(), isAdmin: true),
              HorizontalList(
                  itemCount: snap.data!.length,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, i) {
                    return NewsItemGridWidget(
                      snap.data![i],
                      onTap: () {
                        UploadNewsScreen(data: snap.data![i]).launch(context);
                      },
                    );
                  })
            ],
          );
        } else {
          return snapWidgetHelper(snap, loadingWidget: SizedBox());
        }
      },
    );
  }
}
