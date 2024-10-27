import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../utils/Colors.dart';
import '/../components/AppWidgets.dart';
import '/../models/NewsData.dart';
import '/../screens/admin/UploadNewsScreen.dart';
import '/../screens/admin/components/NewsItemGridWidget.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';

class IndependentNewsGridWidget extends StatefulWidget {
  static String tag = '/IndependentNewsGridWidget';

  final String? newsType;
  final bool? showAppBar;

  final String filterBy;
  final DocumentReference? categoryRef;

  IndependentNewsGridWidget({this.newsType, this.showAppBar, this.filterBy = FilterByPost, this.categoryRef});

  @override
  _IndependentNewsGridWidgetState createState() => _IndependentNewsGridWidgetState();
}

class _IndependentNewsGridWidgetState extends State<IndependentNewsGridWidget> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? context.scaffoldBackgroundColor : colorPrimary.withOpacity(0.0),
      appBar: widget.showAppBar.validate() ? appBarWidget(languages.allNews) : null,
      body: StreamBuilder<List<NewsData>>(
        stream: widget.filterBy == FilterByPost ? newsService.getNews(newsType: widget.newsType.validate()) : newsService.getNewsByCategory(widget.categoryRef),
        builder: (_, snap) {
          if (snap.hasData) {
            if (snap.data!.isEmpty) {
              return noDataWidget();
            }
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment:getStringAsync(SELECTED_LANGUAGE_CODE) == 'ar'?Alignment.centerRight:Alignment.centerLeft,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  spacing: 16,
                  runSpacing: 16,
                  children: snap.data.validate().map((e) {
                    return NewsItemGridWidget(e, onTap: () {
                      UploadNewsScreen(data: e).launch(context);
                    },isGrid: true);
                  }).toList(),
                ),
              ),
            );
          } else {
            return snapWidgetHelper(snap, loadingWidget: SizedBox());
          }
        },
      ),
    );
  }
}
