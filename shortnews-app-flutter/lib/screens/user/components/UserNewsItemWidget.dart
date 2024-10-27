import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../main.dart';
import '/../components/AppWidgets.dart';
import '/../models/NewsData.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

class UserNewsItemWidget extends StatelessWidget {
  static String tag = '/UserNewsItemWidget';
  final NewsData? newsData;
  final Function? onTap;
  final bool? isTrending;

  UserNewsItemWidget({this.newsData, this.onTap, this.isTrending = false});

  @override
  Widget build(BuildContext context) {
    // log(newsData);
    return getIntAsync(POST_LAYOUT, defaultValue: 1) == 0
        ? Container(
                width: context.width(),
                height: 200,
                decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt()),
                child: Stack(
                  children: [
                    newsData!.image!.contains('youtube.com')
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              cachedImage(getYoutubeThumbnail(newsData!.image!), fit: BoxFit.fill, width: context.width(), height: context.height()),
                              Icon(Fontisto.youtube_play, color: redColor, size: 16)
                            ],
                          ).cornerRadiusWithClipRRect(defaultRadius)
                        : cachedImage(newsData!.image.validate(), fit: BoxFit.cover, width: context.width(), height: context.height()).cornerRadiusWithClipRRect(defaultRadius),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        width: context.width(),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black54, Colors.black],
                            stops: [0.0, 0.3, 1.0],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            tileMode: TileMode.clamp,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(parseHtmlString(newsData!.title.validate()), style: boldTextStyle(color: Colors.white), maxLines: 3),
                            8.height,
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded, size: 18, color: Colors.white),
                                4.width,
                                if (newsData!.updatedAt != null) Text(newsData!.updatedAt!.timeAgo, maxLines: 1, style: secondaryTextStyle(size: 12, color: Colors.white)),
                                4.width,
                                Text('・', style: secondaryTextStyle()),
                                4.width,
                                Text(
                                  '${(parseHtmlString(newsData!.shortContent).calculateReadTime()).ceilToDouble().toInt()} ${languages.minRead}',
                                  style: secondaryTextStyle(size: 12, color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).cornerRadiusWithClipRRect(defaultRadius))
            .onTap(() {
            onTap?.call();
          }, borderRadius: radius()).paddingAll(8)
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(parseHtmlString(newsData!.title.validate()), maxLines: 3, style: primaryTextStyle(), overflow: TextOverflow.ellipsis),
                  8.height,
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: textSecondaryColor),
                      4.width,
                      if (newsData!.updatedAt != null) Text(newsData!.updatedAt!.timeAgo, maxLines: 1, style: secondaryTextStyle(size: 12)),
                      4.width,
                      Text('・', style: secondaryTextStyle()),
                      4.width,
                      Text('${(parseHtmlString(newsData!.shortContent).calculateReadTime()).ceilToDouble().toInt()} ${languages.minRead}',
                              style: secondaryTextStyle(size: 12), overflow: TextOverflow.ellipsis)
                          .expand(),
                      if (isTrending == true && false)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.grey),
                            4.width,
                            Text(newsData!.postViewCount.validate().toString(), style: secondaryTextStyle()),
                          ],
                        ),
                    ],
                  ),
                ],
              ).expand(),
              8.width,
              newsData!.image!.contains('youtube.com')
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        cachedImage(getYoutubeThumbnail(newsData!.image!), fit: BoxFit.cover, height: 100, width: 100).cornerRadiusWithClipRRect(defaultRadius),
                        Icon(Fontisto.youtube_play, color: redColor)
                      ],
                    )
                  : cachedImage(newsData!.image.validate(), fit: BoxFit.cover, height: 100, width: 100).cornerRadiusWithClipRRect(defaultRadius),
            ],
          ).onTap(() {
            onTap?.call();
          }, borderRadius: radius(),highlightColor: transparentColor,splashColor: transparentColor,hoverColor: transparentColor).paddingSymmetric(vertical: 8);
  }
}
