import 'package:flutter/material.dart';
import '../../../utils/ResponsiveWidget.dart';
import '/../components/AppWidgets.dart';
import '/../models/CategoryData.dart';
import '/../screens/admin/components/NewCategoryDialog.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import 'IndependentNewsGridWidget.dart';

class CategoryItemWidget extends StatefulWidget {
  static String tag = '/CategoryItemWidget';
  final CategoryData? data;

  CategoryItemWidget({this.data});

  @override
  _CategoryItemWidgetState createState() => _CategoryItemWidgetState();
}

class _CategoryItemWidgetState extends State<CategoryItemWidget> {
  Future<void> delete(String? id) async {
    if (appStore.isTester) return toast(mTesterNotAllowedMsg);

    await categoryService.removeDocument(id).then((value) {
      finish(context);
    }).catchError((e) {
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveWidget.isSmallScreen(context) ?context.width() * 0.35:context.width() * 0.26,
      // height: ResponsiveWidget.isSmallScreen(context) ?context.height() * 0.35:context.height() * 0.22,

      decoration: boxDecorationWithShadow(borderRadius: radius(8), backgroundColor: context.scaffoldBackgroundColor),
      child: Column(
        children: [
          cachedImage(widget.data!.image, height: 120, width: ResponsiveWidget.isSmallScreen(context) ?context.width() * 0.35:context.width() * 0.14, fit: BoxFit.cover).cornerRadiusWithClipRRectOnly(topRight: 8, topLeft: 8),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.data!.name!, style: primaryTextStyle(size: 14), maxLines: 2).expand(),
                Icon(Icons.edit, color: context.iconColor, size: 18).onTap(() {
                  if (appStore.isTester) return toast(mTesterNotAllowedMsg);
                  showInDialog(context, builder: (context) {
                    return NewCategoryDialog(categoryData: widget.data);
                  }).then((value) {
                    //
                  });
                }),
                8.width,
                Icon(Icons.delete, color: Colors.red, size: 18).onTap(() {
                  if (appStore.isTester) return toast(mTesterNotAllowedMsg);
                  showConfirmDialog(context, languages.deleteCategory, positiveText: languages.yes, negativeText: languages.no, onAccept: () {
                    print(" my category key => ${widget.data!.id}");
                    // print();
                    // print(newsService.getNewsByCategory(categoryService.ref!.doc(widget.data!.id)));
                    // notificationService.getNotification().then((value) {
                    //   if(){
                    //     print("title ${value.first.title}");
                    //     print("newsid ${value.first.newsId}");
                    //     print("id ${value.first.id}");
                    //   }
                    // });
                    showConfirmDialog(context, "If You Delete this Category News under that category will be deleted", positiveText: "Agree", negativeText: "Disagree", onAccept: () {
                      newsService.getNewsByCategoryFuture(categoryService.ref!.doc(widget.data!.id)).then((value){
                        appStore.setLoading(true);
                        value.forEach((element) {
                          notificationService.getNotification().then((v){
                            v.forEach((e) {
                              if(element.id==e.newsId){
                                print("my =========notifi news id ${e.newsId}");
                                print("my =========noti id ${e.id}");
                                notificationService.removeNotification(e.id);
                              }
                            });
                          });
                          newsService.removeDocument(element.id).then((value){
                            appStore.setLoading(false);
                          });
                        });
                      });
                      // newsService.getNewsByCategoryFuture(categoryService.ref!.doc(widget.data!.id)).then((value) {
                      //   value.forEach((element) {
                      //     if (appStore.isTester) return toast(mTesterNotAllowedMsg);
                      //     appStore.setLoading(true);
                      //     newsService.removeDocument(element.id).then((value) {
                      //       notificationService.getNotification().then((value) {
                      //         value.forEach((e) {
                      //           if (e.newsId ==element.id) {
                      //             notificationService.removeDocument(e.id).then((value) {
                      //               appStore.setLoading(false);
                      //             });
                      //           }
                      //         });
                      //       });
                      //     });
                      //   });
                      // });
                      print("delete");
                      delete(widget.data!.id);
                    });
                  });
                }),
              ],
            ),
          ),
        ],
      ).onTap(() {
        IndependentNewsGridWidget(showAppBar: true, filterBy: FilterByCategory, categoryRef: categoryService.ref!.doc(widget.data!.id)).launch(context);
      }, hoverColor: Colors.transparent, splashColor: transparentColor, highlightColor: transparentColor),
    );
  }
}
