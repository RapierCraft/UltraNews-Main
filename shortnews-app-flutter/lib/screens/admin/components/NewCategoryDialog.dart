import 'package:flutter/material.dart';
import '../../../utils/Colors.dart';
import '/../models/CategoryData.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import 'PickImageDialog.dart';

class NewCategoryDialog extends StatefulWidget {
  static String tag = '/NewCategoryDialog';
  final CategoryData? categoryData;

  NewCategoryDialog({this.categoryData});

  @override
  _NewCategoryDialogState createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<NewCategoryDialog> {
  TextEditingController nameCont = TextEditingController();
  TextEditingController imageCont = TextEditingController();

  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    isUpdate = widget.categoryData != null;

    if (isUpdate) {
      nameCont.text = widget.categoryData!.name!;
      imageCont.text = widget.categoryData!.image!;
    }
  }

  Future<void> save() async {
    if (appStore.isTester) return toast(mTesterNotAllowedMsg);

    CategoryData categoryData = CategoryData();

    categoryData.name = nameCont.text.trim();
    categoryData.image = imageCont.text.trim();
    categoryData.updatedAt = DateTime.now();

    if (isUpdate) {
      categoryData.id = widget.categoryData!.id;
      categoryData.createdAt = widget.categoryData!.createdAt;
    } else {
      categoryData.createdAt = DateTime.now();
    }

    if (isUpdate) {
      await categoryService.updateDocument(categoryData.toJson(), categoryData.id).then((value) {
        finish(context);
      }).catchError((e) {
        toast(e.toString());
      });
    } else {
      await categoryService.addDocument(categoryData.toJson()).then((value) {
        finish(context);
      }).catchError((e) {
        toast(e.toString());
      });
    }
  }

  Future<void> delete() async {
    if (appStore.isTester) return toast(mTesterNotAllowedMsg);

    await categoryService.removeDocument(widget.categoryData!.id).then((value) {
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
      width: 500,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: nameCont,
              textFieldType: TextFieldType.NAME,
              decoration: inputDecoration(labelText: languages.name),
              autoFocus: true,
            ),
            16.height,
            AppTextField(
              controller: imageCont,
              textFieldType: TextFieldType.OTHER,
              decoration: inputDecoration(labelText: languages.featuredImageUrl),
              keyboardType: TextInputType.url,
              validator: (s) {
                if (s!.isEmpty) return errorThisFieldRequired;
                if (!s.validateURL()) return languages.urlInvalid;
                return null;
              },
            ),
            8.height,
            AppButton(
              text: languages.upload,
              onTap: () {
                showInDialog(context, builder: (context) {
                  return PickImageDialog();
                }, contentPadding: EdgeInsets.zero)
                    .then((value) {
                  if (value != null && value.toString().isNotEmpty) {
                    imageCont.text = value.toString();
                  }
                });
              },
            ).visible(false),
            // 30.height,
            // AppButton(
            //   text: languages.delete,
            //   padding: EdgeInsets.all(20),
            //   onTap: () {
            //     showConfirmDialog(context, languages.deleteCategory, positiveText: languages.yes, negativeText: languages.no).then((value) {
            //       delete();
            //     }).catchError((e) {
            //       toast(e.toString());
            //     });
            //   },
            // ).visible(isUpdate),
            16.height,
            AppButton(
              text: languages.save,
              textColor: Colors.white,
              color: colorPrimary,
              width: context.width(),
              padding: EdgeInsets.all(20),
              onTap: () {
                save();
              },
            ),
          ],
        ),
      ),
    );
  }
}
