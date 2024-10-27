import 'package:flutter/material.dart';
import '/../utils/Colors.dart';
import '/../components/AppWidgets.dart';
import '/../models/CategoryData.dart';
import '/../screens/admin/components/NewCategoryDialog.dart';
import '/../utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import 'components/CategoryItemWidget.dart';

class CategoryListScreen extends StatefulWidget {
  static String tag = '/CategoryListScreen';

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AppButton(
        textColor: Colors.white,
        color: colorPrimary,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white),
            Text(languages.addCategory, style: primaryTextStyle(color: Colors.white)),
          ],
        ),
        onTap: () {
          showInDialog(context, builder: (context) {
            return NewCategoryDialog();
          });
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: StreamBuilder<List<CategoryData>>(
          stream: categoryService.categories(),
          builder: (_, snap) {
            if (snap.hasData) {
              if (snap.data!.isEmpty) return noDataWidget();

              return Align(
                alignment:getStringAsync(SELECTED_LANGUAGE_CODE) == 'ar'?Alignment.centerRight:Alignment.centerLeft,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  spacing: 16,
                  runSpacing: 16,
                  children: snap.data.validate().map((e) {
                    return CategoryItemWidget(data: e);
                  }).toList(),
                ),
              );
            } else {
              return snapWidgetHelper(snap, loadingWidget: loader().center());
            }
          },
        ),
      ),
    );
  }
}
