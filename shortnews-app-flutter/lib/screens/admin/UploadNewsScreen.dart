import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mighty_sort_news/utils/ResponsiveWidget.dart';
import '../../components/AppWidgets.dart';
import '../../utils/Colors.dart';
import '/../components/HtmlWidget.dart';
import '/../main.dart';
import '/../models/CategoryData.dart';
import '/../models/NewsData.dart';
import '/../network/RestApis.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../models/NotificationModel.dart';
import '../user/CommentScreen.dart';

class UploadNewsScreen extends StatefulWidget {
  static String tag = '/UploadNewsScreen';
  final NewsData? data;

  UploadNewsScreen({this.data});

  @override
  _UploadNewsScreenState createState() => _UploadNewsScreenState();
}

class _UploadNewsScreenState extends State<UploadNewsScreen> {
  var formKey = GlobalKey<FormState>();
  AsyncMemoizer categoryMemoizer = AsyncMemoizer<List<CategoryData>>();
  bool isUpdate = false;

  TextEditingController titleCont = TextEditingController();
  TextEditingController imageCont = TextEditingController();
  TextEditingController sourceUrlCont = TextEditingController();

  TextEditingController contentCont = TextEditingController();
  TextEditingController shortContentCont = TextEditingController();

  String? newsStatus = NewsStatusDraft;
  String? newsType = NewsTypeRecent;

  List<String> newsStatusList = [NewsStatusPublished, NewsStatusUnpublished, NewsStatusDraft];
  List<String> newsTypeList = [NewsTypeRecent, NewsTypeBreaking];

  CategoryData? selectedCategory;

  bool? sendNotification = true;
  bool? allowComments = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    isUpdate = widget.data != null;

    // Don't send push notifications when updating by default.
    sendNotification = !isUpdate;
    print(isUpdate);

    if (isUpdate) {
      titleCont.text = widget.data!.title.validate();
      imageCont.text = widget.data!.image.validate();
      sourceUrlCont.text = widget.data!.sourceUrl.validate();
      contentCont.text = widget.data!.content.validate();
      shortContentCont.text = widget.data!.shortContent.validate();

      newsStatus = widget.data!.newsStatus;
      newsType = widget.data!.newsType;
    }
  }

  Future<void> save() async {
    if (appStore.isTester) return toast(mTesterNotAllowedMsg);

    if (selectedCategory == null) return toast(languages.selectCategory);

    if (formKey.currentState!.validate()) {
      NewsData newsData = NewsData();

      newsData.title = titleCont.text.trim();
      newsData.caseSearch = titleCont.text.trim().setSearchParam();
      newsData.image = imageCont.text.trim();
      newsData.sourceUrl = sourceUrlCont.text.trim();
      newsData.content = contentCont.text.trim();
      newsData.shortContent = shortContentCont.text.trim();

      newsData.newsStatus = newsStatus;
      newsData.newsType = newsType;
      newsData.allowComments = allowComments;

      if (selectedCategory != null) {
        newsData.categoryRef = db.collection('categories').doc(selectedCategory!.id);
      }
      newsData.authorRef = db.collection('users').doc(appStore.userId);

      newsData.updatedAt = DateTime.now();

      if (isUpdate) {
        /// Set default value when updating document
        newsData.id = widget.data!.id;
        newsData.createdAt = widget.data!.createdAt;
        newsData.postViewCount = widget.data!.postViewCount.validate();
        newsData.commentCount = widget.data!.commentCount.validate();

        ///
        notificationService.getNotification().then((v) {
          v.forEach((e) {
            if (widget.data!.id == e.newsId) {
              print("old =========notifi title ${e.title}");

              // NotificationClass data = NotificationClass();
              // data.title = titleCont.text.trim();
              // data.img = imageCont.text.trim();
              // print("new title = ${ titleCont.text.trim()}");
              // print("new img = ${imageCont.text.trim()}");
             notificationService.updateNotification(e.id,{'title': titleCont.text.trim(), 'img': imageCont.text.trim()});
              // notificationService.updateDocument({'title': titleCont.text.trim(), 'img': imageCont.text.trim()}, e.id).then((value) {
                // print("new new ===== ${data.title }");
                // print("new =========notifi title ${e.title}");
              // }).catchError(onError);
            }
          });
        });
        await newsService.updateDocument(newsData.toJson(), newsData.id).then((value) {
          toast(languages.save);

          finish(context, true);
        });
      } else {
        newsData.postViewCount = 0;
        newsData.commentCount = 0;
        newsData.createdAt = DateTime.now();

        ///
        await newsService.addDocument(newsData.toJson()).then((value) async {
          toast(languages.save);

          if (sendNotification!) {
            //Send push notification
            NotificationClass data = NotificationClass();
            data.title = parseHtmlString(titleCont.text.trim());
            data.img = parseHtmlString(imageCont.text.trim());
            data.dec = parseHtmlString(shortContentCont.text.trim());
            data.createdAt = DateTime.now();
            data.newsId = value.id;
            //   data.sourceUrl = parseHtmlString(sourceUrlCont.text.trim());

            try {
              await notificationService.addNotification(data).then((v) async {
                sendPushNotifications(parseHtmlString(titleCont.text.trim()),
                    parseHtmlString(shortContentCont.text.trim()), id: value.id,
                    image: imageCont.text.trim());
              });
            } catch(e){
              toast(e.toString());
              print("Notificaton error: ${e.toString()}");
            }
          }
          finish(context, true);
        });
      }
    } else {
      //
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? Colors.black : Colors.white,
      // backgroundColor: appStore.isDarkMode ? context.scaffoldBackgroundColor : colorPrimary.withOpacity(0.0),
      appBar: isUpdate
          ? appBarWidget(
              "",
              color: colorPrimary,
              textColor: Colors.white,
              titleWidget: Text(parseHtmlString(widget.data!.title), style: primaryTextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
              actions: [
                IconButton(
                  icon: Icon(FontAwesome.comment_o, color: Colors.white),
                  onPressed: () {
                    CommentScreen(newsId: widget.data!.id, isAdmin: true).launch(context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_outlined, color: Colors.white),
                  onPressed: () {
                    print(widget.data!.id);
                    showConfirmDialog(context, languages.deletePost, positiveText: languages.yes, negativeText: languages.no).then((value) {
                      if (value ?? false) {
                        if (appStore.isTester) return toast(mTesterNotAllowedMsg);
                        appStore.setLoading(true);
                        notificationService.getNotification().then((value) {
                          value.forEach((element) {
                            if (element.newsId == widget.data!.id) {
                              notificationService.removeNotification(element.id);
                              // notificationService.removeDocument(element.id);
                            }
                          });
                          newsService.removeDocument(widget.data!.id).then((value) {
                            appStore.setLoading(false);
                            finish(context, true);
                          });
                        });
                      }
                    });
                  },
                ),
              ],
            )
          : null,
      body: Row(

        children: [
          SizedBox(
            width: context.width() * 0.5,
            height: context.height(),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 50),
              child: Form(
                key: formKey,
                onChanged: () {
                  if (formKey.currentState!.validate()) {
                    newsStatus = NewsStatusPublished;

                    setState(() {});
                  }
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(languages.category, style: secondaryTextStyle()),
                        8.height,
                        FutureBuilder<List<CategoryData>>(
                          future: categoryMemoizer.runOnce(() => categoryService.categoriesFuture()).then((value) => value as List<CategoryData>),
                          builder: (_, snap) {
                            if (snap.hasData) {
                              if (snap.data!.isEmpty) return SizedBox();

                              if (selectedCategory == null) {
                                if (isUpdate) {
                                  selectedCategory = snap.data!.firstWhere((element) => element.id == widget.data!.categoryRef!.id);
                                } else {
                                  selectedCategory = snap.data!.first;
                                }
                              }
                              return Container(
                                width: double.infinity,
                                decoration: BoxDecoration(borderRadius: radius(), color: appStore.isDarkMode ? context.cardColor : Colors.grey.shade200),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: DropdownButton(
                                  dropdownColor: context.cardColor,
                                  underline: Offstage(),
                                  items: snap.data!.map((e) {
                                    return DropdownMenuItem(child: Text(e.name.validate(), style: primaryTextStyle()), value: e);
                                  }).toList(),
                                  isExpanded: true,
                                  value: selectedCategory,
                                  onChanged: (dynamic c) {
                                    selectedCategory = c;
                                    setState(() {});
                                  },
                                ),
                              );
                            } else {
                              return snapWidgetHelper(snap);
                            }
                          },
                        ),
                        16.height,
                        AppTextField(
                          controller: titleCont,
                          textFieldType: TextFieldType.MULTILINE,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 2,
                          minLines: 1,
                          onChanged: (s) {
                            setState(() {});
                          },
                          decoration: inputDecoration(labelText: languages.title),
                          validator: (s) {
                            if (s!.trim().isEmpty) return errorThisFieldRequired;
                            return null;
                          },
                        ),
                        16.height,
                        Stack(
                          children: [
                            AppTextField(
                              controller: imageCont,
                              textFieldType: TextFieldType.OTHER,
                              onChanged: (s) {
                                setState(() {});
                              },
                              decoration: inputDecoration(labelText: languages.featuredImageUrl).copyWith(),
                              keyboardType: TextInputType.url,
                              validator: (s) {
                                if (s!.isEmpty) return errorThisFieldRequired;
                                if (!s.validateURL()) return languages.urlInvalid;
                                return null;
                              },
                            ),
                          ],
                        ),
                        16.height,
                        AppTextField(
                          controller: sourceUrlCont,
                          textFieldType: TextFieldType.MULTILINE,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: inputDecoration(labelText: languages.sourceUrl),
                          maxLines: 2,
                          minLines: 1,
                          keyboardType: TextInputType.url,
                          validator: (s) {
                            if (s!.isNotEmpty && !s.validateURL()) return languages.urlInvalid;
                            return null;
                          },
                          onChanged: (s) {
                            setState(() {});
                          },
                        ),
                        16.height,
                        AppTextField(
                          controller: shortContentCont,
                          textFieldType: TextFieldType.MULTILINE,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: inputDecoration(labelText: languages.shortContent),
                          maxLines: 2,
                          minLines: 1,
                          maxLength: 360,
                          validator: (s) {
                            if (newsType == NewsTypeStory && s!.trim().isEmpty) return 'Short content is required when you add a story';
                            return null;
                          },
                        ),
                        16.height,
                        AppTextField(
                          controller: contentCont,
                          textFieldType: TextFieldType.MULTILINE,
                          decoration: inputDecoration(labelText: languages.contentHtml),
                          minLines: 4,
                          validator: (s) {
                            if (s!.trim().isEmpty) return errorThisFieldRequired;
                            return null;
                          },
                          onChanged: (s) {
                            setState(() {});
                          },
                        ),
                        16.height,
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(languages.type, style: boldTextStyle()).withWidth(80),
                            Wrap(
                              children: newsTypeList.map((e) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio(
                                      value: e,
                                      groupValue: newsType,
                                      onChanged: (dynamic s) {
                                        newsType = s;
                                        setState(() {});
                                      },
                                    ),
                                    Text(e.capitalizeFirstLetter(), style: secondaryTextStyle()).withWidth(100).paddingAll(8).onTap(() {
                                      newsType = e;
                                      setState(() {});
                                    }),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        16.height,
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(languages.status, style: boldTextStyle()).withWidth(80),
                            Wrap(
                              children: newsStatusList.map((e) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio(
                                      value: e,
                                      groupValue: newsStatus,
                                      onChanged: (dynamic s) {
                                        newsStatus = s;
                                        setState(() {});
                                      },
                                    ),
                                    Text(e.capitalizeFirstLetter(), style: secondaryTextStyle()).withWidth(100).paddingAll(8).onTap(() {
                                      newsStatus = e;
                                      setState(() {});
                                    }),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ).paddingOnly(top: 16, left: 16, right: 16, bottom: 16),
                    CheckboxListTile(
                      value: sendNotification,
                      contentPadding: EdgeInsets.only(left: 16, right: 16),
                      title: Text(languages.sendNotification, style: boldTextStyle()),
                      onChanged: (s) async {
                        log(sendNotification);
                        sendNotification = s;
                        setState(() {});
                      },
                    ).visible(widget.data == null),
                    CheckboxListTile(
                      value: allowComments,
                      contentPadding: EdgeInsets.only(left: 16, right: 16),
                      title: Text(languages.allowComments, style: boldTextStyle()),
                      onChanged: (s) {
                        allowComments = s;

                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
          ).expand(),
          VerticalDivider(color: colorPrimary),
          ResponsiveWidget.isSmallScreen(context)?SizedBox():SizedBox(
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    children: [
                      Text(languages.preview, style: boldTextStyle()).expand(),
                      AppButton(
                        color: context.cardColor,
                        textColor: textPrimaryColorGlobal,
                        margin: EdgeInsets.all(8),
                        text: languages.save,
                        padding: EdgeInsets.all(20),
                        onTap: () {
                          save();
                        },
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (imageCont.text.isNotEmpty)
                        cachedImage(imageCont.text.validate(), height: 300, fit: BoxFit.cover, width: context.width(), alignment: Alignment.topCenter).cornerRadiusWithClipRRect(defaultRadius).paddingOnly(top: 8, bottom: 8, left: 8, right: 8),
                      if (widget.data != null && widget.data!.postViewCount != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            getPostCategoryTagWidget(context, widget.data),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.comment, size: 18, color: textSecondaryColorGlobal),
                                    4.width,
                                    Text(widget.data!.commentCount.toString(), style: secondaryTextStyle()),
                                  ],
                                ),
                                4.width,
                                Row(
                                  children: [
                                    Icon(Icons.remove_red_eye_outlined, size: 18, color: textSecondaryColorGlobal),
                                    4.width,
                                    Text(widget.data!.postViewCount.toString(), style: secondaryTextStyle()),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ).paddingOnly(top: 4, right: 8),
                      8.height,
                      if (titleCont.text.isNotEmpty) Text(parseHtmlString(titleCont.text.validate()), style: boldTextStyle(size: 18)).paddingOnly(left: 8, right: 8),
                      if (widget.data != null)
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, color: textSecondaryColorGlobal, size: 14),
                            2.width,
                            if (widget.data!.updatedAt != null) Text(widget.data!.updatedAt!.timeAgo, style: secondaryTextStyle(size: 12)),
                            2.width,
                            Text('・', style: secondaryTextStyle()),
                            Text('${(parseHtmlString(widget.data!.content).calculateReadTime()).ceilToDouble().toInt()} ${languages.minRead}', style: secondaryTextStyle(size: 12)),
                          ],
                        ).paddingSymmetric(horizontal: 8),
                      if (!contentCont.text.isEmptyOrNull) HtmlWidget(postContent: contentCont.text.validate()),
                      16.height,
                      if (sourceUrlCont.text.isNotEmpty)
                        Text(languages.sourceUrl, style: secondaryTextStyle(color: Colors.blue)).paddingLeft(8).onTap(() {
                          launchUrlWidget(sourceUrlCont.text, forceWebView: true);
                        }).visible(sourceUrlCont.text.validate().isNotEmpty),
                      30.height,
                    ],
                  ).paddingOnly(top: 8, left: 8, right: 8, bottom: 30),
                ).expand(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
