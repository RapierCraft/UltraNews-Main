import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '/../models/NewsData.dart';
import '../MyFeedScreen.dart';
import 'UserNewsItemWidget.dart';

class UserNewsListWidget extends StatelessWidget {
  static String tag = '/UserNewsListWidget';
  final List<NewsData>? list;
  final Function? onTap;
  final int? len;
  final String? name;

  UserNewsListWidget({this.list, this.onTap, this.len, this.name});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        if(userPreferenceCategoriesDocs.isNotEmpty && !userPreferenceCategoriesDocs.contains(list![index].categoryRef)){
          return Container();
        }

        return UserNewsItemWidget(
          newsData: list![index],
          onTap: () async {
            bool res = await MyFeedScreen(news: list!, name: name, ind: index, isBookMark: name == languages.bookmarks ? true : false).launch(context);
            if (res == true && onTap != null) onTap!();
          },
        );
      },
      itemCount: len ?? list!.length,
      shrinkWrap: true,
    );
  }
}
