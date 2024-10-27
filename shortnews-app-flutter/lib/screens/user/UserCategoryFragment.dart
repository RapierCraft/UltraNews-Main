import 'package:flutter/material.dart';
import '/../utils/Colors.dart';
import '/../components/AppWidgets.dart';
import '/../models/CategoryData.dart';
import '/../screens/user/ViewAllNewsScreen.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import 'package:flutter/services.dart';


class UserCategoryFragment extends StatefulWidget {
  static String tag = '/UserCategoryFragment';

  @override
  State<UserCategoryFragment> createState() => _UserCategoryFragmentState();
}

class _UserCategoryFragmentState extends State<UserCategoryFragment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(languages.categories, showBack: true, color: colorPrimary,systemUiOverlayStyle: SystemUiOverlayStyle.light, textColor: Colors.white),
      body: Container(
        child: FutureBuilder<List<CategoryData>>(
          future: categoryService.categoriesFuture(),
          builder: (_, snap) {
            if (snap.hasData) {
              if (snap.data!.isEmpty) return noDataWidget();

              return SingleChildScrollView(
                padding: EdgeInsets.all(12),
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      runSpacing: 12,
                      spacing: 10,
                      children: snap.data!.map((e) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            cachedImage(e.image, height: 100, width: (context.width() - 48) / 3, fit: BoxFit.cover).cornerRadiusWithClipRRect(defaultRadius),
                            Container(height: 100, width: (context.width() - 48) / 3, decoration: boxDecorationWithRoundedCorners(backgroundColor: Colors.black26)),
                            Text(e.name!, style: boldTextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis).fit(),
                          ],
                        ).onTap(() {
                          ViewAllNewsScreen(title: e.name, filterBy: FilterByCategory, categoryRef: categoryService.ref!.doc(e.id)).launch(context);
                        });
                      }).toList(),
                    ),
                  ],
                ),
              );
            } else {
              return snapWidgetHelper(snap, loadingWidget: loader());
            }
          },
        ),
      ),
    );
  }
}
