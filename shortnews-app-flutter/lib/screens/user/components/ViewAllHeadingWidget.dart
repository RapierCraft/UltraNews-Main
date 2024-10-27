import 'package:flutter/material.dart';
import '../../../main.dart';
import '/../utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';

class ViewAllHeadingWidget extends StatelessWidget {
  static String tag = '/ViewAllHeadingWidget';
  final String? title;
  final Color? backgroundColor;
  final Color? textColor;
  final Function? onTap;
  final bool? isAdmin;

  ViewAllHeadingWidget({this.title, this.onTap, this.backgroundColor, this.textColor, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        VerticalDivider(color: appStore.isDarkMode ? textPrimaryColorGlobal : colorPrimary, thickness: 4).withHeight(14),
        4.width,
        Text(title.validate(), style: boldTextStyle(color: appStore.isDarkMode ? textPrimaryColorGlobal : colorPrimary, size: 18)).expand(),
        InkWell(
          onTap: () {
            onTap?.call();
          },
          child: Icon(Icons.arrow_forward_ios, size: 20),
        ).visible(onTap != null && isAdmin == false)
      ],
    ).paddingOnly(left: 10, right: 16, top: 8, bottom: 8);
  }
}
