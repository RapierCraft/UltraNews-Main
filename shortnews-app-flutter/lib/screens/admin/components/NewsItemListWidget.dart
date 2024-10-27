import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../main.dart';
import '/../components/AppWidgets.dart';
import '/../models/NewsData.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';

class NewsItemListWidget extends StatelessWidget {
  final NewsData data;

  NewsItemListWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        data.image!.contains('youtube.com')
            ? Stack(
                alignment: Alignment.center,
                children: [cachedImage(getYoutubeThumbnail(data.image.validate()), fit: BoxFit.fill, width: 100, height: 80), Icon(Fontisto.youtube_play, color: redColor, size: 16)],
              ).cornerRadiusWithClipRRect(defaultRadius)
            : cachedImage(data.image.validate(), fit: BoxFit.cover, height: 80, width: 100).cornerRadiusWithClipRRect(defaultRadius),
        16.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: EdgeInsets.only(bottom:  8),
              decoration: BoxDecoration(color: colorPrimary.withOpacity(0.1), borderRadius: radius()),
              child: Text('${data.newsType.capitalizeFirstLetter()} ${languages.news}', maxLines: 1, style: secondaryTextStyle(size: 12)),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(parseHtmlString(data.title.validate()), maxLines: 2, style: boldTextStyle(size: 14), overflow: TextOverflow.ellipsis).expand(),
                8.width,
                Text(data.newsStatus.capitalizeFirstLetter(), maxLines: 1, style: boldTextStyle(size: 12, color: getNewsStatusBgColor(data.newsStatus))),
              ],
            ),
            8.height,
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 16, color: textSecondaryColor),
                4.width,
                Text(data.updatedAt!.timeAgo, maxLines: 1, style: secondaryTextStyle(size: 12)),
                4.width,
                Text('・', style: secondaryTextStyle()),
                4.width,
                Text(
                  '${(parseHtmlString(data.shortContent).calculateReadTime()).ceilToDouble().toInt()} ${languages.minRead}',
                  style: secondaryTextStyle(size: 12),
                ),
                8.width,
                Text('・', style: secondaryTextStyle()),
                8.width,
                Icon(Icons.remove_red_eye_outlined, size: 16, color: textSecondaryColor),
                4.width,
                Text(data.postViewCount.validate().toString(), style: secondaryTextStyle()),
              ],
            ),
            8.height,
          ],
        ).expand(),
      ],
    );
  }
}
