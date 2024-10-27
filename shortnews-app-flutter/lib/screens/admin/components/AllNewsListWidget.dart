import 'package:flutter/material.dart';
import '../../../utils/Colors.dart';
import '../../../utils/Common.dart';
import '/../components/AppWidgets.dart';
import '/../models/NewsData.dart';
import '/../screens/admin/components/NewsItemListWidget.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../../main.dart';
import '../UploadNewsScreen.dart';

class AllNewsListWidget extends StatefulWidget {
  static String tag = '/AllNewsListWidget';

  @override
  AllNewsListWidgetState createState() => AllNewsListWidgetState();
}

class AllNewsListWidgetState extends State<AllNewsListWidget> {

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? context.scaffoldBackgroundColor : colorPrimary.withOpacity(0.0),
      body: PaginateFirestore(
        itemBuilderType: PaginateBuilderType.listView,

        itemBuilder: (context, documentSnapshot, index) {
          NewsData data = NewsData.fromJson(documentSnapshot[index].data() as Map<String, dynamic>);

          return NewsItemListWidget(data: data).onTap(() async {
            bool res = await UploadNewsScreen(data: data).launch(context);
            if (res == true) setState(() {});
          }, highlightColor: transparentColor, splashColor: transparentColor, hoverColor: transparentColor);
        },
        shrinkWrap: true,isLive: true,
        padding: EdgeInsets.all(8),
        // orderBy is compulsory to enable pagination
        query: newsService.buildCommonQuery(),
        itemsPerPage: DocLimit,
        bottomLoader: loader(),
        initialLoader: loader(),
        onEmpty: noDataWidget(),
        onError: (e) => Text(e.toString(), style: primaryTextStyle()).center(),
      ).paddingOnly(left: 8,top: 8,right: 8),
    );
  }
}
