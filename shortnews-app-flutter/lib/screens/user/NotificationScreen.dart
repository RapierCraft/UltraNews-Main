import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/Common.dart';
import '/../models/NewsData.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/AppWidgets.dart';
import '../../main.dart';
import '../../models/NotificationModel.dart';
import '../../utils/Colors.dart';
import 'components/NotificationWidget.dart';

class NotificationScreen extends StatefulWidget {
  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  List<String> newsId = [];
  List<NewsData> newsData = [];
  List<NewsData> notificationNewsData = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    loadNews();
  }

  loadNews() {
    notificationService.getNotification().then((value) {
      value.forEach((element) {
        // log(element.newsId);
        if (element.newsId != null && element.newsId!.isNotEmpty) {
          newsService.getNewsDetail(element.newsId).then((value) {

            notificationNewsData.add(value);
            log(value.title);
            notificationNewsData.sort((a, b) {
              return b.createdAt!.compareTo(a.createdAt!);
            });
            notificationNewsData.forEach((element) {
              log(element.title);
              newsData.add(element);
            });
          });
        }
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(languages.notifications, elevation: 0, color: colorPrimary,textColor: Colors.white,
          systemUiOverlayStyle: SystemUiOverlayStyle.light,showBack: true),
      body: FutureBuilder<List<NotificationClass>>(
        future: notificationService.getNotification(),
        builder: (_, snap) {
          if (snap.hasData) {
            if (snap.data != null && snap.data!.isNotEmpty)
              return ListView.separated(
                itemCount: snap.data!.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(height: 0, thickness: 1);
                },
                itemBuilder: (context, index) {
                  NotificationClass data = snap.data![index];
                  return notificationComponent(data: data, context: context, newsData: notificationNewsData, index: index);
                },
              );
            else
              return noDataWidget();
          } else {
            return snapWidgetHelper(snap, loadingWidget: loader());
          }
        },
      ),
    );
  }
}
