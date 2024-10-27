import 'package:flutter/material.dart';
import '/../screens/admin/components/UserItemWidget.dart';
import '/../utils/Common.dart';
import '../../user/components/ViewAllHeadingWidget.dart';
import '/../main.dart';
import '/../models/UserModel.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

class RecentlyLoggedInUserWidget extends StatelessWidget {
  static String tag = '/RecentlyLoggedInUserWidget';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: userService.usersFuture(limit: DocLimit),
      builder: (_, snap) {
        if (snap.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ViewAllHeadingWidget(title:languages.recentLogin.toUpperCase(), isAdmin: true).paddingRight(8),
              HorizontalList(
                itemBuilder: (_, index) {
                  UserModel data = snap.data![index];
                  return UserItemWidget(data: data);
                },
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: snap.data!.length,
              ),
            ],
          );
        }
        return snapWidgetHelper(snap, loadingWidget: loader().center());
      },
    );
  }
}
