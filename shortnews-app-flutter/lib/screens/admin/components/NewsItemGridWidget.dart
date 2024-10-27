import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../utils/Constants.dart';
import '../../../utils/ResponsiveWidget.dart';
import '/../components/AppWidgets.dart';
import '/../main.dart';
import '/../models/CategoryData.dart';
import '/../models/NewsData.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../user/CommentScreen.dart';

class NewsItemGridWidget extends StatefulWidget {
  static String tag = '/NewsItemGridWidget';
  final NewsData newsData;
  final Function? onTap;
  final bool? isGrid;

  NewsItemGridWidget(this.newsData, {this.onTap, this.isGrid = false});

  @override
  NewsItemGridWidgetState createState() => NewsItemGridWidgetState();
}

class NewsItemGridWidgetState extends State<NewsItemGridWidget> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.isGrid == true ?ResponsiveWidget.isSmallScreen(context) ?context.width() * 0.37: context.width() * 0.196 : ResponsiveWidget.isSmallScreen(context) ?context.width() * 0.4:context.width() * 0.18,
      decoration: boxDecorationWithRoundedCorners(borderRadius: radius(8), backgroundColor: context.cardColor),
      child: Column(
        crossAxisAlignment: isRTL?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              widget.newsData.image!.contains('youtube.com')

                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        cachedImage(getYoutubeThumbnail(widget.newsData.image!), fit: BoxFit.cover, width: widget.isGrid == true ? ResponsiveWidget.isSmallScreen(context) ?context.width() * 0.37:context.width() * 0.196 : ResponsiveWidget.isSmallScreen(context) ?context.width() * 0.4:context.width() * 0.18, height: 160),
                        Icon(Fontisto.youtube_play, color: redColor),
                      ],
                    ).cornerRadiusWithClipRRectOnly(topLeft: 8, topRight: 8)

                  : cachedImage(widget.newsData.image.validate(), fit: BoxFit.cover, width: widget.isGrid == true ? ResponsiveWidget.isSmallScreen(context) ?context.width() * 0.37:context.width() * 0.196 :ResponsiveWidget.isSmallScreen(context) ?context.width() * 0.4: context.width() * 0.18, height: 160)
                      .cornerRadiusWithClipRRectOnly(topLeft: 8, topRight: 8),
              Positioned(
                top: 0,
                left: 0,
                child: FutureBuilder<CategoryData>(
                  future: newsService.getNewsCategory(widget.newsData.categoryRef!),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(parseHtmlString(widget.newsData.title.validate()), maxLines: 2, style: primaryTextStyle(size: 14), overflow: TextOverflow.ellipsis).expand(),
                  6.width,
                  Container(
                    decoration: BoxDecoration(
                        color: getNewsStatusBgColor(widget.newsData.newsStatus).withOpacity(0.2), border: Border.all(color: getNewsStatusBgColor(widget.newsData.newsStatus)), borderRadius: radius()),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(widget.newsData.newsStatus.capitalizeFirstLetter(),style: secondaryTextStyle(color: getNewsStatusBgColor(widget.newsData.newsStatus), size: 10)),
                  ),
                ],
              ),
              8.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 16, color: textSecondaryColor),
                      4.width,
                      Text(widget.newsData.updatedAt!.timeAgo, maxLines: 1, style: secondaryTextStyle(size: 12), overflow: TextOverflow.ellipsis).expand(),
                    ],
                  ).expand(),
                  Icon(FontAwesome.comment_o, size: 16, color: textSecondaryColorGlobal).onTap(() {
                    CommentScreen(newsId: widget.newsData.id, isAdmin: true).launch(context);
                  }).visible(widget.newsData.allowComments.validate() && widget.newsData.commentCount != 0),
                  4.width,
                  Text(widget.newsData.commentCount.toString(), style: secondaryTextStyle()).visible(widget.newsData.allowComments.validate() && widget.newsData.commentCount != 0),
                ],
              ),
            ],
          ).paddingSymmetric(horizontal: 8, vertical: 8),
        ],
      ),
    ).onTap(() {
      widget.onTap?.call();
    }, hoverColor: Colors.transparent, splashColor: Colors.transparent, highlightColor: Colors.transparent);
  }
}
