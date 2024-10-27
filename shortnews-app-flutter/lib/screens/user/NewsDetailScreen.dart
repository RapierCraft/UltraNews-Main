import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:mighty_sort_news/components/FacebookAdComponent.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '/../screens/user/MyFeedScreen.dart';
import '/../screens/user/SignInScreen.dart';
import '/../utils/Colors.dart';
import '../../components/AdMobAdComponent.dart';
import '/../components/AppWidgets.dart';
import '/../components/HtmlWidget.dart';
import '/../models/NewsData.dart';
import '/../models/UserModel.dart';
import 'CommentScreen.dart';
import '/../screens/user/components/BreakingNewsListWidget.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import '/../utils/ModelKeys.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';

// ignore: must_be_immutable
class NewsDetailScreen extends StatefulWidget {
  static String tag = '/NewsDetailScreen';
  NewsData? data;
  String? id;

  NewsDetailScreen({this.data, this.id});

  @override
  _NewsDetailScreenState createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  BannerAd? myBanner;
  InterstitialAd? myInterstitial;

  /// Used to save edited image on storage
  bool? isBanner = false;

  String postContent = '';
  bool? isUpdate;
  String? authorName = '';

  double thumbnailHeight = 335;
  double? imgHeight;
  double? dataHeight;
  bool isPlayerReady = false;
  String videoId = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    isBanner = false;

    if (widget.data != null) {
      setPostContent(widget.data!.content.validate());

      widget.id = widget.data!.id.toString();
    }

    newsService.newsDetail(widget.id).then((value) {
      if (!postViewedList.contains(widget.id)) {
        newsService.updatePostCount(widget.id);

        /// Add to array
        postViewedList.add(widget.id);
        setValue(POST_VIEWED_LIST, jsonEncode(postViewedList));
      }
      widget.data = value;

      setPostContent(value.content);
    }).catchError((e) {
      toast(e.toString());
    });

    if (isMobile && !getBoolAsync(DISABLE_AD)) {
      if (getStringAsync(AD_TYPE) == Admob) {
        myBanner = buildBannerAd()..load();
        loadInterstitialAd();
      } else {
        loadFacebookInterstitialAd();
      }
    }

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    if(widget.data != null) {
      if (widget.data!.image!.contains('youtube.com')) {
        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
        videoId = YoutubePlayer.convertUrlToId(widget.data!.image!)!;
        youtubePlayerController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(mute: false,
              showLiveFullscreenButton: false,
              autoPlay: true,
              disableDragSeek: false,
              loop: false,
              isLive: false,
              forceHD: false,
              enableCaption: true),
        )
          ..addListener(listener);
        idController = TextEditingController();
        seekToController = TextEditingController();
        videoMetaData = const YoutubeMetaData();
        playerState = PlayerState.unknown;
      } else {
        //
      }
    }
  }

  Future<void> setPostContent(String? text) async {
    postContent = text
        .validate()
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('[embed]', '<embed>')
        .replaceAll('[/embed]', '</embed>')
        .replaceAll('[caption]', '<caption>')
        .replaceAll('[/caption]', '</caption>');

    setState(() {});
  }

  Future<void> bookmarkNews() async {
    if (appStore.isLoggedIn) {
      if (bookmarkList.contains(widget.data!.id)) {
        removeToBookmark();
      } else {
        addToBookmark();
      }
      await setValue(BOOKMARKS, jsonEncode(bookmarkList));
      toast(languages.save);
      setState(() {});
      isUpdate = true;
      LiveStream().emit(StreamRefreshBookmark, true);
    } else {
      SignInScreen(isNewTask: false).launch(context).then((value) {
        //bookmarkNews();
      });
    }
  }

  Future<void> addToBookmark() async {
    bookmarkList.add(widget.data!.id);

    await userService.updateDocument({UserKeys.bookmarks: bookmarkList}, appStore.userId).then((value) {
      //
    }).catchError((e) {
      bookmarkList.remove(widget.data!.id);
      setState(() {});
    });
  }

  Future<void> removeToBookmark() async {
    bookmarkList.remove(widget.data!.id);

    await userService.updateDocument({UserKeys.bookmarks: bookmarkList}, appStore.userId).then((value) {
      //
    }).catchError((e) {
      bookmarkList.add(widget.data!.id);
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void fullScreen() {
    if (MediaQuery.of(context).orientation == DeviceOrientation.portraitUp) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    }
  }

  void exitScreen() {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }
    finish(context);
  }

  void listener() {
    if (isPlayerReady && mounted && !youtubePlayerController.value.isFullScreen) {
      setState(() {
        playerState = youtubePlayerController.value.playerState;
        videoMetaData = youtubePlayerController.metadata;
      });
    }
  }

  @override
  void deactivate() {
    if (widget.data!.image!.contains('youtube.com')) {
      youtubePlayerController.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    // myInterstitial?.show();
    // myBanner?.dispose();
    // if (getStringAsync(AD_TYPE) == Admob) {
    //   showInterstitialAd();
    // } else {
    //   showFacebookInterstitialAd();
    // }
    if (widget.data!.image!.contains('youtube.com')) {
      youtubePlayerController.dispose();
      idController.dispose();
      seekToController.dispose();
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (isUpdate == true) {
          finish(context, true);
          return Future.value(true);
        } else {
          finish(context, false);
          return Future.value(false);
        }
      },
      child: Scaffold(
          body: widget.data != null
              ? Stack(
                  children: [
                    NestedScrollView(
                      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                        return [
                          SliverAppBar(
                            floating: true,
                            pinned: true,
                            titleSpacing: 0,
                            title: Text(innerBoxIsScrolled == true ? widget.data!.title! : '', style: primaryTextStyle(color: Colors.white)),
                            leading: BackButton(
                                color: Colors.white,
                                onPressed: () {
                                  if (isUpdate == true)
                                    return finish(context, true);
                                  else
                                    finish(context, false);
                                }),
                            actions: [
                              IconButton(
                                icon: Icon(bookmarkList.contains(widget.data!.id) ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
                                onPressed: () => bookmarkNews(),
                              )
                            ],
                            backgroundColor: colorPrimary,
                            expandedHeight: 320.0,
                            forceElevated: innerBoxIsScrolled,
                            flexibleSpace: FlexibleSpaceBar(
                              background: widget.data!.image != null && widget.data!.image!.isNotEmpty
                                  ? widget.data!.image!.contains('youtube.com')
                                      ? youTubeComponent()
                                      : cachedImage(widget.data!.image, width: context.width(), height: 350, fit: BoxFit.cover)
                                  : SizedBox(),
                            ),
                          )
                        ];
                      },
                      body: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [

                                        // widget.data!.categoryName == null ? SizedBox() : Container(
                                        //   padding: EdgeInsets.only(right: 8, top: 4, bottom: 4, left: 8),
                                        //   margin: EdgeInsets.only(right: 8, left: 8, bottom: 8),
                                        //   decoration: BoxDecoration(color: colorPrimary, borderRadius: radius()),
                                        //   child: Text(widget.data!.categoryName!, style: boldTextStyle(size: 12, color: Colors.white, letterSpacing: 1)),
                                        // ),
                                        getPostCategoryTagWidget(context, widget.data),
                                        // Spacer(),
                                        // Row(
                                        //   mainAxisAlignment: MainAxisAlignment.center,
                                        //   children: [
                                        //     Icon(Fontisto.comment, size: 16, color: textSecondaryColorGlobal),
                                        //     8.width,
                                        //     Text(widget.data!.commentCount.toString(), style: secondaryTextStyle()),
                                        //   ],
                                        // ).onTap(() async {
                                        //   bool res = await CommentScreen(newsId: widget.data!.id).launch(context);
                                        //   if (res = true) {
                                        //     init();
                                        //     setState(() {});
                                        //   }
                                        // }),
                                        // 12.width,
                                        // Row(
                                        //   mainAxisAlignment: MainAxisAlignment.center,
                                        //   children: [
                                        //     Icon(Icons.remove_red_eye_outlined, size: 18, color: textSecondaryColorGlobal),
                                        //     4.width,
                                        //     Text(widget.data!.postViewCount.toString(), style: secondaryTextStyle()),
                                        //   ],
                                        // ),
                                      ],
                                    ),
                                    Text(parseHtmlString(widget.data!.title.validate()), style: boldTextStyle(size: 18)).paddingOnly(left: 8, right: 8),
                                    8.height,
                                    Row(
                                      children: [
                                        Icon(Icons.access_time_rounded, color: textSecondaryColorGlobal, size: 14),
                                        2.width,
                                        if (widget.data!.updatedAt != null) Text(widget.data!.updatedAt!.timeAgo, style: secondaryTextStyle(size: 12)),
                                        2.width,
                                        Text('・', style: secondaryTextStyle()),
                                        if (widget.data!.updatedAt != null) Text(DateFormat('dd-MM-yyyy').format(widget.data!.updatedAt!), style: secondaryTextStyle(size: 12)),
                                        // Text('${(parseHtmlString(widget.data!.content).calculateReadTime()).ceilToDouble().toInt()} ${languages.minRead}', style: secondaryTextStyle(size: 12)),
                                      ],
                                    ).paddingSymmetric(horizontal: 8),
                                    // 8.height,
                                    // if (widget.data!.authorRef != null)
                                    //   FutureBuilder<UserModel>(
                                    //     future: newsService.getAuthor(widget.data!.authorRef!),
                                    //     builder: (_, snap) {
                                    //       if (snap.hasData) {
                                    //         authorName = snap.data!.name;
                                    //       }
                                    //       return Row(
                                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //         children: [
                                    //           Text(snap.hasData ? languages.newsBy + " " + snap.data!.name! : '', style: primaryTextStyle()).paddingLeft(8),
                                    //           Icon(Icons.arrow_forward_ios_rounded, size: 18, color: context.iconColor).onTap(() {
                                    //             appStore.setLoading(true);
                                    //
                                    //             newsService.newsByAuthor(widget.data!.authorRef).then((value) {
                                    //               appStore.setLoading(false);
                                    //               MyFeedScreen(ind: 0, name: '${languages.newsBy} $authorName', news: value).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                                    //             }).catchError((e) {
                                    //               appStore.setLoading(false, toastMsg: e.toString());
                                    //             });
                                    //           })
                                    //         ],
                                    //       );
                                    //     },
                                    //   ),
                                  ],
                                ).paddingSymmetric(horizontal: 12, vertical: 12),
                                HtmlWidget(postContent: postContent.validate().trim()).paddingOnly(left: 10, right: 10),
                                16.height,
                                Text('Source Link', style: secondaryTextStyle(color: Colors.blue))
                                    .paddingLeft(8)
                                    .onTap(() {
                                      launchUrlWidget(widget.data!.sourceUrl!, forceWebView: true);
                                    })
                                    .paddingSymmetric(horizontal: 12, vertical: 12)
                                    .visible(widget.data!.sourceUrl.validate().isNotEmpty),
                              ],
                            ),
                            16.height,
                            FutureBuilder<List<NewsData>>(
                              future: newsService.relatedNewsFuture(widget.data!.categoryRef, widget.data!.id),
                              builder: (_, snap) {
                                if (snap.hasData && snap.data!.isNotEmpty) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(languages.relatedNews, style: boldTextStyle()).paddingAll(16),
                                      BreakingNewsListWidget(snap.data),
                                      8.height,
                                    ],
                                  );
                                }
                                return SizedBox();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Observer(builder: (_) => loader().visible(appStore.isLoading)),
                  ],
                )
              : loader().visible(appStore.isLoading)),
    );
  }

  Widget youTubeComponent() {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: youtubePlayerController,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.white,
        bottomActions: [
          SizedBox(
            width: context.width() - 20,
            child: Row(
              children: [
                CurrentPosition(),
                ProgressBar(isExpanded: true, controller: youtubePlayerController),
                RemainingDuration(),
              ],
            ),
          ),
        ],
        aspectRatio: getBoolAsync(DISABLE_AD) == false
            ? getDeviceTypePhone()
                ? 1.4
                : 1.82
            : getDeviceTypePhone()
                ? 1.4
                : 1.84,
        progressColors: ProgressBarColors(playedColor: Colors.white, bufferedColor: Colors.grey.shade200, handleColor: Colors.white, backgroundColor: Colors.grey),
        onReady: () {
          isPlayerReady = true;
          setState(() {});
        },
        onEnded: (data) {
          //
        },
      ),
      builder: (context, player) => WillPopScope(
        onWillPop: () {
          exitScreen();
          return Future.value(true);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            player,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    icon: Icon(CupertinoIcons.gobackward_10, color: Colors.white, size: 30),
                    onPressed: () {
                      Duration currentPosition = youtubePlayerController.value.position;
                      Duration targetPosition = currentPosition - const Duration(seconds: 10);
                      youtubePlayerController.seekTo(targetPosition);
                    }).visible(!youtubePlayerController.value.isPlaying && isPlayerReady),
                GestureDetector(
                  onTap: () {
                    if (isPlayerReady) {
                      youtubePlayerController.value.isPlaying ? youtubePlayerController.pause() : youtubePlayerController.play();
                      setState(() {});
                    }
                  },
                  child: SizedBox(height: 50, width: 50),
                ),
                IconButton(
                    icon: Icon(CupertinoIcons.goforward_10, color: Colors.white, size: 30),
                    onPressed: () {
                      Duration currentPosition = youtubePlayerController.value.position;
                      Duration targetPosition = currentPosition + const Duration(seconds: 10);
                      youtubePlayerController.seekTo(targetPosition);
                    }).visible(!youtubePlayerController.value.isPlaying && isPlayerReady),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
