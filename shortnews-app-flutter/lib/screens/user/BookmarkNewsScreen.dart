import 'package:flutter/material.dart';
import '/../components/AppWidgets.dart';
import '/../models/NewsData.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter/services.dart';

import '../../main.dart';
import 'components/UserNewsListWidget.dart';

class BookmarkNewsScreen extends StatefulWidget {
  static String tag = '/BookmarkNewsScreen';

  @override
  _BookmarkNewsScreenState createState() => _BookmarkNewsScreenState();
}

class _BookmarkNewsScreenState extends State<BookmarkNewsScreen> with AutomaticKeepAliveClientMixin {
  List<NewsData> data = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> init() async {
    appStore.setLoading(true);
    loadBookMarkNews();
  }

  loadBookMarkNews() {
    LiveStream().on(StreamRefreshBookmark, (s) {
      setState(() {});
    });
    log(data.length);
    data.clear();
    newsService.getBookmarkNewsFuture().then((value) {
      if (value.isNotEmpty) {
        value.forEachIndexed((e, index) {
          bookmarkList.forEachIndexed((e1, i) {
            if (e1!.contains(e.id.toString())) {
              data.add(e);
              appStore.setLoading(false);
              setState(() {});
              log(data.length.toString());
              log(e.id.toString());
            }
          });
        });
      }
      appStore.setLoading(false);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      setState(() {});
    });
  }

  @override
  void dispose() {
    LiveStream().dispose(StreamRefreshBookmark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: appBarWidget(
        languages.bookmarks,
        color: colorPrimary,
        textColor: Colors.white,
        systemUiOverlayStyle: SystemUiOverlayStyle.light,
        backWidget: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: UserNewsListWidget(
                list: data,
                name: languages.bookmarks,
                onTap: () {
                  init();
                  setState(() {});
                }),
          ),
          if (data.isEmpty && !appStore.isLoading) noDataWidget(),
          if (appStore.isLoading) loader().center()
        ],
      ),
    );
  }
}
