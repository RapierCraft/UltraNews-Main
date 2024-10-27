import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '/../screens/user/SignInScreen.dart';
import '/../utils/Colors.dart';
import '/../components/AppWidgets.dart';
import '/../models/CommentData.dart';
import '/../services/CommentService.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter/services.dart';

import '../../main.dart';

class CommentScreen extends StatefulWidget {
  static String tag = '/CommentScreen';
  final String? newsId;
  final bool? isAdmin;

  CommentScreen({required this.newsId, this.isAdmin = false});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  TextEditingController commentCont = TextEditingController();
  FocusNode commentFocus = FocusNode();

  CommentService? commentService;
  bool? isUser = false;

  bool isUpdate = false;
  String? id;
  String? comment;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    commentService = CommentService(widget.newsId);
    if (!isMobile) 1.seconds.delay.then((value) => context.requestFocus(commentFocus));
    appStore.isUserInComment = false;
  }

  Future<void> saveComment() async {
    if (appStore.isTester) return toast(mTesterNotAllowedMsg);

    if (commentCont.text.trim().isEmpty) return toast(languages.commentRequired);
    hideKeyboard(context);

    CommentData commentData = CommentData();

    commentData.newsId = widget.newsId;
    commentData.comment = commentCont.text.trim();
    commentData.userId = getStringAsync(USER_ID);
    commentData.userName = getStringAsync(FULL_NAME);
    commentData.createdAt = DateTime.now();
    commentData.updatedAt = DateTime.now();

    await commentService!.addDocument(commentData.toJson()).then((value) {
      commentCont.clear();
      commentService!.ref!.get().then((value) {
        newsService.updatePostCommentCount(widget.newsId, value.docs.length);
      });

      if (!isMobile) context.requestFocus(commentFocus);

      setState(() {});
    });
  }

  Future<void> editComment(String? id) async {
    if (appStore.isTester) return toast(mTesterNotAllowedMsg);
    appStore.isUserInComment = true;
    await commentService!.updateDocument({'comment': commentCont.text.trim()}, id);
  }

  Future<void> deleteComment(String? id) async {
    if (appStore.isTester) return toast(mTesterNotAllowedMsg);

    await commentService!.removeDocument(id).then((value) {
      commentCont.clear();
      commentService!.ref!.get().then((value) {
        newsService.updatePostCommentCount(widget.newsId, value.docs.length);
      });
      isUpdate = false;
      appStore.isUserInComment = false;
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(languages.comment, color: colorPrimary, systemUiOverlayStyle: SystemUiOverlayStyle.light, backWidget: BackButton(onPressed: () {
        finish(context, true);
      }), textColor: Colors.white),
      body: Observer(builder: (context) {
        return SizedBox(
          height: context.height(),
          child: Stack(
            children: [
              StreamBuilder<List<CommentData>>(
                stream: commentService?.comments(),
                builder: (BuildContext context, snap) {
                  if (snap.hasData) {
                    if (snap.data!.isNotEmpty) {
                      return ListView.builder(
                        itemCount: snap.data!.length,
                        shrinkWrap: true,
                        itemBuilder: (_, index) {
                          CommentData data = snap.data![index];
                          log("user id " + data.userId.toString());
                          log("same " + appStore.userId.toString());
                          if (data.userId == appStore.userId) {
                            isUser = true;
                            if (isUpdate == false) {
                              appStore.isUserInComment = true;
                            } else {
                              appStore.isUserInComment = false;
                            }
                          }
                          return Container(
                            margin: EdgeInsets.all(8),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              width: context.width(),
                              decoration: BoxDecoration(border: Border.all(color: context.dividerColor), borderRadius: radius()),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(data.comment.validate(), style: primaryTextStyle()).expand(),
                                      InkWell(
                                        onTap: () {
                                          // editComment(data.id);
                                          appStore.isUserInComment = false;
                                          setState(() {
                                            isUpdate = true;
                                            id = data.id;
                                            commentCont.text = data.comment!;
                                          });
                                        },
                                        child: Icon(Icons.edit),
                                      ).visible(data.userId == appStore.userId),
                                      SizedBox(width: 10),
                                      InkWell(
                                        onTap: () {
                                          deleteComment(data.id);
                                        },
                                        child: Icon(Icons.delete_outline_outlined),
                                      ).visible(data.userId == appStore.userId),
                                      // IconButton(
                                      //   icon: Icon(Icons.delete_outline_outlined),
                                      //   onPressed: () {
                                      //     deleteComment(data.id);
                                      //   },
                                      // ).visible(data.userId == appStore.userId),
                                      SizedBox(width: 8),
                                      // IconButton(
                                      //   icon: Icon(Icons.edit),
                                      //   onPressed: () {
                                      //     // editComment(data.id);
                                      //     appStore.isUserInComment = false;
                                      //     setState(() {
                                      //       isUpdate = true;
                                      //       id = data.id;
                                      //       commentCont.text = data.comment!;
                                      //     });
                                      //   },
                                      // ).visible(data.userId == appStore.userId),
                                    ],
                                  ),
                                  Text(data.updatedAt!.timeAgo, style: secondaryTextStyle(size: 14)),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return noDataWidget();
                    }
                  } else {
                    return snapWidgetHelper(snap);
                  }
                },
              ),
              !isWeb
                  ? Positioned(
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(border: Border(top: BorderSide(color: context.dividerColor))),
                        padding: EdgeInsets.only(bottom: 8, left: 16, right: 16),
                        width: context.width(),
                        height: 60,
                        child: AppTextField(
                          controller: commentCont,
                          autoFocus: isUpdate,
                          focus: commentFocus,
                          textFieldType: TextFieldType.OTHER,
                          decoration:
                              InputDecoration(hintText: languages.writeHere, border: InputBorder.none, hintStyle: secondaryTextStyle(color: appStore.isDarkMode ? textPrimaryColorGlobal : textSecondaryColorGlobal), enabledBorder: InputBorder.none),
                          suffix: Icon(Icons.send, color: appStore.isDarkMode ? context.iconColor : colorPrimary).paddingAll(4).onTap(() {
                            appStore.isUserInComment = true;
                            isUpdate ? editComment(id) : saveComment();
                          }),
                          onFieldSubmitted: (s) {
                            saveComment();
                          },
                        ),
                      ).visible(appStore.isLoggedIn || widget.isAdmin == false),
                    ).visible(appStore.isUserInComment == false)
                  : SizedBox(),
              AppButton(
                text: languages.login,
                width: context.width() - 16,
                onTap: () async {
                  await SignInScreen(isNewTask: false).launch(context);
                  setState(() {});
                },
              ).paddingAll(8).visible(!appStore.isLoggedIn),
            ],
          ),
        );
      }),
    );
  }
}
