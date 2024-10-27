import 'package:flutter/material.dart';
import '../../../components/AppWidgets.dart';
import '../../../utils/AppImages.dart';
import '../../../utils/ResponsiveWidget.dart';
import '/../models/UserModel.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';

class UserItemWidget extends StatefulWidget {
  static String tag = '/UserItemWidget';
  final UserModel? data;
  final Function? onTap;

  UserItemWidget({this.data, this.onTap});

  @override
  _UserItemWidgetState createState() => _UserItemWidgetState();
}

class _UserItemWidgetState extends State<UserItemWidget> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveWidget.isSmallScreen(context) ?context.width() * 0.32:context.width() * 0.12,
      decoration: boxDecorationWithRoundedCorners(borderRadius: radius(8), backgroundColor: context.cardColor),
      padding: EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
              alignment: Alignment.topRight,
              child: Icon(Icons.delete_outline_outlined, color: context.iconColor).onTap(() {
                if (appStore.isTester)
                  return toast(mTesterNotAllowedMsg);
                else
                  showConfirmDialog(context, languages.deleteUser, positiveText: languages.yes, negativeText: languages.no).then((value) {
                    if (value ?? false) {
                      userService.removeDocument(widget.data!.id).then((value) {
                        // widget.onTap!();
                        setState(() {});
                      }).catchError((e) {
                        toast(e.toString(), print: true);
                      });
                    }
                  });
              })).visible(appStore.isAdmin && appStore.userId != widget.data!.id),
          20.height.visible(appStore.isAdmin && appStore.userId == widget.data!.id),
          widget.data!.image.validate().isNotEmpty
              ? cachedImage(widget.data!.image.validate(), height: 60, width: 60, fit: BoxFit.cover).cornerRadiusWithClipRRect(30)
              : Image.asset(ic_profile, width: 60, height: 60, fit: BoxFit.cover).cornerRadiusWithClipRRect(30),
          8.height,
          Text(widget.data!.name.validate(), style: boldTextStyle(), overflow: TextOverflow.ellipsis),
          4.height,
          Text(widget.data!.email.validate(), style: secondaryTextStyle(), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis).visible(!appStore.isTester),
          Text(widget.data!.updatedAt!.timeAgo, style: secondaryTextStyle(size: 12), overflow: TextOverflow.ellipsis, maxLines: 2),
        ],
      ),
    );
  }
}
