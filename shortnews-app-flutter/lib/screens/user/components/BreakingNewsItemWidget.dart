import 'package:flutter/material.dart';
import '/../models/NewsData.dart';
import '/../components/AppWidgets.dart';
import '/../utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';

class BreakingNewsItemWidget extends StatefulWidget {
  static String tag = '/BreakingNewsItemWidget';
  final NewsData newsData;
  final Function? onTap;

  BreakingNewsItemWidget(this.newsData, {this.onTap});

  @override
  BreakingNewsItemWidgetState createState() => BreakingNewsItemWidgetState();
}

class BreakingNewsItemWidgetState extends State<BreakingNewsItemWidget> {

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.0,
      width: context.width() * 0.75,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          cachedImage(widget.newsData.image.validate(), height: 200, width: context.width() * 0.75, fit: BoxFit.cover).cornerRadiusWithClipRRect(defaultRadius),
          Container(color: Colors.black26).cornerRadiusWithClipRRect(defaultRadius),
          Text(parseHtmlString(widget.newsData.title.validate()), maxLines: 2, style: boldTextStyle(size: 18, color: Colors.white)).paddingAll(8),
        ],
      ).onTap(() {
        widget.onTap?.call();
        // NewsDetailScreen(newsData: widget.newsData, heroTag: heroTag).launch(context);
      }),
    );
  }
}
