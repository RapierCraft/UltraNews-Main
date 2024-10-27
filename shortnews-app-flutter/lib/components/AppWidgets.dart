import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../main.dart';
import '../models/CategoryData.dart';
import '../models/NewsData.dart';
import '../utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';

Widget cachedImage(String? url, {double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment, bool usePlaceholderIfUrlEmpty = true, double? radius}) {
  if (url.validate().isEmpty) {

    return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
  } else if (url.validate().startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: url!,
      height: height,
      width: width,
      fit: fit,
      alignment: alignment as Alignment? ?? Alignment.center,
      filterQuality: FilterQuality.high,
      errorWidget: (_, s, d) {
        return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
      },
      placeholder: (_, s) {
        if (!usePlaceholderIfUrlEmpty) return SizedBox();
        return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
      },
    );
  } else {
    return Image.asset(url!, height: height, width: width, fit: fit, alignment: alignment ?? Alignment.center).cornerRadiusWithClipRRect(radius ?? defaultRadius);
  }
}

Widget placeHolderWidget({double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment, double? radius}) {
  return Image.asset('assets/placeholder.png', height: height, width: width, fit: fit ?? BoxFit.cover, alignment: alignment ?? Alignment.center);
}

Widget noDataWidget() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Lottie.asset('assets/ic_noData.json', height: 80, fit: BoxFit.fitHeight),
      8.height,
      Text(languages.noData, style: boldTextStyle()).center(),
    ],
  ).center();
}

Widget getPostCategoryTagWidget(BuildContext context, NewsData? newsData) {
  if (newsData != null && newsData.categoryRef != null) {
    return Container(
      child: Row(
        children: [
          FutureBuilder<CategoryData>(
            future: newsService.getNewsCategory(newsData.categoryRef!),
            builder: (_, snap) {
              if (snap.hasData) {
                return Container(
                  padding: EdgeInsets.only(right: 8, top: 4, bottom: 4, left: 8),
                  margin: EdgeInsets.only(right: 8, left: 8, bottom: 8),
                  decoration: BoxDecoration(color: colorPrimary, borderRadius: radius()),
                  child: Row(
                    children: [
                      cachedImage(snap.data!.image, width: 28, height: 28, fit: BoxFit.cover).cornerRadiusWithClipRRect(2),
                      8.width,
                      Text(snap.data!.name!, style: boldTextStyle(size: 12, color: Colors.white, letterSpacing: 1)),
                    ],
                  ),
                );
              } else {
                return SizedBox();
              }
            },
          ),
        ],
      ),
    );
  } else {
    return Offstage();
  }
}

Widget titleWidget(String title) {
  return Container(
    padding: EdgeInsets.all(16),
    color:  colorPrimary.withOpacity(0.3),
    child: Row(
      children: [
        VerticalDivider(color: appStore.isDarkMode ? Colors.white54 :colorPrimary, thickness: 4).withHeight(10),
        8.width,
        Text(title, style: boldTextStyle(size: 12, color:appStore.isDarkMode ? Colors.white54 : colorPrimary)),
      ],
    ),
  );
}
