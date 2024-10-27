import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mighty_sort_news/main.dart';
import '/../screens/user/MyFeedScreen.dart';
import '/../models/NewsData.dart';
import '/../models/NotificationModel.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/AppWidgets.dart';
import '../../../utils/Colors.dart';
import '../../../utils/Common.dart';

Widget notificationComponent({NotificationClass? data, context, List<NewsData>? newsData, int? index}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data!.title.toString(), style: primaryTextStyle(), maxLines: 2, overflow: TextOverflow.ellipsis).expand(),
        12.width,
        data.img != null && data.img!.isNotEmpty
            ? data.img!.contains('youtube.com')
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      cachedImage(getYoutubeThumbnail(data.img!), fit: BoxFit.fill, height: 60, width: 60),
                      Icon(Fontisto.youtube_play, color: redColor, size: 16)
                    ],
                  ).cornerRadiusWithClipRRect(defaultRadius)
                : cachedImage(data.img.toString(), height: 60, width: 60, fit: BoxFit.cover).cornerRadiusWithClipRRect(4)
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: boxDecorationWithRoundedCorners(borderRadius: radius(8), backgroundColor: colorPrimary.withOpacity(0.1)),
                child: Icon(Feather.bell),
              ),
      ],
    ).paddingSymmetric(vertical: 8).onTap(() {
      if (data.newsId != null && data.newsId!.isNotEmpty) MyFeedScreen(news: newsData, name:languages.notifications, ind: index).launch(context);
    }, hoverColor: Colors.transparent, splashColor: transparentColor, highlightColor: transparentColor),
  );
}
