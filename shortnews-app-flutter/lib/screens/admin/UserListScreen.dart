import 'package:flutter/material.dart';
import '/../utils/Common.dart';
import '../../utils/Colors.dart';
import '/../main.dart';
import '/../models/UserModel.dart';
import '/../screens/admin/components/UserItemWidget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';

class UserListScreen extends StatelessWidget {
  static String tag = '/UserListScreen';

  @override
  Widget build(BuildContext context) {
    PaginateRefreshedChangeListener refreshChangeListener = PaginateRefreshedChangeListener();
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? context.scaffoldBackgroundColor : colorPrimary.withOpacity(0.0),
      body: RefreshIndicator(
        onRefresh: () async {
          refreshChangeListener.refreshed = true;
        },
        child: StreamBuilder<List<UserModel>>(
          stream: userService.users(),
          builder: (context, snap) {
            if (snap.hasData) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Align(
                  alignment: getStringAsync(SELECTED_LANGUAGE_CODE) == 'ar' ? Alignment.centerRight : Alignment.centerLeft,
                  child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                          children: snap.data!.map(
                            (e) {
                              return UserItemWidget(
                                  data: e,
                                  onTap: () {
                                    refreshChangeListener.refreshed = true;
                                  });
                            },
                          ).toList())
                     ,
                ),
              );
            }
            return snapWidgetHelper(snap, loadingWidget: loader());
          },
        ),
      ),
    );
  }
}
