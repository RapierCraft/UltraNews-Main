import 'package:flutter/material.dart';
import '../../../models/CategoryData.dart';
import '../../../utils/ResponsiveWidget.dart';
import '../../user/components/ViewAllHeadingWidget.dart';
import '/../components/AppWidgets.dart';
import '/../main.dart';
import '/../models/NewsData.dart';
import '/../screens/admin/UploadNewsScreen.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

class MostViewedNewsWidget extends StatelessWidget {
  static String tag = '/MostViewedNewsWidget';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NewsData>>(
      future: newsService.getMostViewedNewsFuture(limit: DocLimit),
      builder: (_, snap) {
        if (snap.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ViewAllHeadingWidget(title: languages.mostViewedNews.toUpperCase(), isAdmin: true),
              HorizontalList(
                itemCount: snap.data!.length,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (_, index) {
                  NewsData data = snap.data![index];
                  return Container(
                    width: ResponsiveWidget.isSmallScreen(context) ?context.width() * 0.4: context.width() * 0.18,
                    decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, borderRadius: radius(8)),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            cachedImage(data.image.validate(), fit: BoxFit.cover, height: 170, width:  ResponsiveWidget.isSmallScreen(context) ?context.width() * 0.4:context.width() * 0.18).cornerRadiusWithClipRRectOnly(topLeft: 8, topRight: 8),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: FutureBuilder<CategoryData>(
                                future: newsService.getNewsCategory(data.categoryRef!),
                                builder: (_, snap) {
                                  if (snap.hasData) {
                                    return Container(
                                      margin: EdgeInsets.all(6),
                                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(color: colorPrimary.withOpacity(0.8), borderRadius: radius(8), border: Border.all(color: colorPrimary)),
                                      child: Text(snap.data!.name!, maxLines: 1, style: secondaryTextStyle(size: 12, color: Colors.white)),
                                    );
                                  } else {
                                    return Offstage();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(parseHtmlString(data.title!), style: primaryTextStyle(size: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                            4.width,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 16, color: textSecondaryColor),
                                    4.width,
                                    Text(data.updatedAt!.timeAgo.toString(), maxLines: 1, style: secondaryTextStyle(size: 12)).expand(),
                                  ],
                                ).expand(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey),
                                    4.width,
                                    Text(data.postViewCount.validate().toString(), style: primaryTextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ).paddingSymmetric(horizontal: 8, vertical: 8),
                      ],
                    ),
                  ).onTap(() {
                    UploadNewsScreen(data: data).launch(context);
                  }, hoverColor: Colors.transparent, splashColor: Colors.transparent, highlightColor: Colors.transparent);
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
