import 'package:flutter/material.dart';
import 'package:mighty_sort_news/main.dart';
import '/../screens/admin/components/MediaLibraryWidget.dart';
import '/../utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';

import 'FileUploadWidget.dart';

class PickImageDialog extends StatefulWidget {
  static String tag = '/FileUploadDialog';

  @override
  _PickImageDialogState createState() => _PickImageDialogState();
}

class _PickImageDialogState extends State<PickImageDialog> with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width() * 0.8,
      height: context.height() * 0.8,
      child: DefaultTabController(
        length: 2,
        initialIndex: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              controller: tabController,
              isScrollable: true,
              labelStyle: primaryTextStyle(),
              labelColor: colorPrimary,
              unselectedLabelColor: textSecondaryColorGlobal,
              indicatorColor: colorPrimary,
              tabs: [
                Tab(text: languages.media, icon: Icon(Icons.perm_media_outlined, color: Colors.black)),
                Tab(text: languages.upload, icon: Icon(Icons.upload_outlined, color: Colors.black)),
              ],
            ),
            TabBarView(
              controller: tabController,
              children: [
                MediaLibraryWidget(),
                FileUploadWidget(),
              ],
            ).expand(),
          ],
        ),
      ),
    );
  }
}
