import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mighty_sort_news/models/CategoryData.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:screenshot/screenshot.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../main.dart';
import '../models/AdsModel.dart';
import '../models/NewsData.dart';
import '../screens/user/NewsDetailScreen.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/ModelKeys.dart';
import 'AdMobAdComponent.dart';
import 'AppWidgets.dart';
import 'FacebookAdComponent.dart';
import 'HtmlWidget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
class FeedComponent extends StatefulWidget {
  final NewsData? data;
  final int? id;
  final bool? isNotification;

  FeedComponent({this.data, this.id, this.isNotification = false});

  @override
  _FeedComponentState createState() => _FeedComponentState();
}

class _FeedComponentState extends State<FeedComponent> {
  ScreenshotController screenshotController = ScreenshotController();
  final GlobalKey screenshotKey = GlobalKey();
  final FlutterShareMe flutterShareMe = FlutterShareMe();
  double thumbnailHeight = 335;
  double? imgHeight;
  double? dataHeight;
  bool isPlayerReady = false;
  String videoId = '';

  AdsModel bannerAdsModel = AdsModel();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    if (widget.data!.image!.contains('youtube.com')) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      videoId = YoutubePlayer.convertUrlToId(widget.data!.image!)!;
      youtubePlayerController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(mute: false, showLiveFullscreenButton: false, autoPlay: true, disableDragSeek: false, loop: false, isLive: false, forceHD: false, enableCaption: true),
      )..addListener(listener);
      idController = TextEditingController();
      seekToController = TextEditingController();
      videoMetaData = const YoutubeMetaData();
      playerState = PlayerState.unknown;
    } else {
      //
    }
    // if (getBoolAsync(DISABLE_AD) == false) {
    //   if (getStringAsync(AD_TYPE) == Admob) {
    //     loadBannerAds();
    //   } else {
    //     loadFacebookBannerId();
    //   }
    // }
    newsService.newsDetail(widget.data!.id).then((value) {
      if (!postViewedList.contains(widget.data!.id)) {
        newsService.updatePostCount(widget.data!.id);
        postViewedList.add(widget.data!.id);
        setValue(POST_VIEWED_LIST, jsonEncode(postViewedList));
      }
    }).catchError((e) {
      toast(e.toString());
    });
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

  Future<void> loadBannerAds() {
    return adsService.getBannerAds().then((value) {
      bannerAdsModel = value;
    });
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
    if (widget.data!.image!.contains('youtube.com')) {
      youtubePlayerController.dispose();
      idController.dispose();
      seekToController.dispose();
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> bookmarkNews(NewsData data) async {
    if (appStore.isLoggedIn) {
      if (bookmarkList.contains(data.id)) {
        removeToBookmark(data);
      } else {
        addToBookmark(data);
      }

      toast(languages.save);
      setState(() {});
    } else {
      //
    }
  }

  Future<void> addToBookmark(NewsData data) async {
    bookmarkList.add(data.id);
    await setValue(BOOKMARKS, jsonEncode(bookmarkList));

    await userService.updateDocument({UserKeys.bookmarks: bookmarkList}, appStore.userId);
  }

  Future<void> removeToBookmark(NewsData data) async {
    bookmarkList.remove(data.id);
    await setValue(BOOKMARKS, jsonEncode(bookmarkList));

    await userService.updateDocument({UserKeys.bookmarks: bookmarkList}, appStore.userId);
  }

  Widget getPostCategoryTagWidget(BuildContext context, NewsData? newsData) {
    if (newsData != null && newsData.categoryRef != null) {
      return Container(
        child: Row(
          children: [
            FutureBuilder<CategoryData>(
              future: newsService.getNewsCategory(newsData.categoryRef!),
              builder: (_, snap) {
                if (snap.hasData) {
                  return Container(
                    padding: EdgeInsets.all(4),
                    decoration: boxDecorationWithRoundedCorners(backgroundColor: colorPrimary.withOpacity(0.5)),
                    child: Text(snap.data!.name!, style: boldTextStyle(size: 14, color: Colors.white, letterSpacing: 1)),
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
          ],
        ),
      );
    } else {
      return Offstage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomLeft,
          children: [
            widget.data!.image!.contains('youtube.com') ? youTubeComponent() : cachedImage(widget.data!.image, width: context.width(), height: context.height() * 0.4, fit: BoxFit.cover),
            widget.data!.categoryData == null ? SizedBox() : Positioned(
                bottom: -10,
                left: 16,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: boxDecorationWithRoundedCorners(backgroundColor: colorPrimary.withOpacity(0.5)),
                  child: Row(
                    children: [
                      cachedImage(widget.data!.categoryData!.image, width: 28, height: 28, fit: BoxFit.cover).cornerRadiusWithClipRRect(2),
                      8.width,
                      Text(widget.data!.categoryData!.name!, style: boldTextStyle(size: 14, color: Colors.white, letterSpacing: 1)),
                    ],
                  ),
                )

              // getPostCategoryTagWidget(context, widget.data)
              // Container(
              //   padding: EdgeInsets.all(4),
              //   decoration: boxDecorationWithRoundedCorners(backgroundColor: colorPrimary.withOpacity(0.5)),
              //   child: Text(appName, style: boldTextStyle(color: white)),
              // ),
            )
          ],
        ),
        16.height,
        SizedBox(
          height: getBoolAsync(DISABLE_AD) == false || bannerAdsModel.img == null || bannerAdsModel.img!.isEmpty || bannerAdsModel.url == null || bannerAdsModel.url!.isEmpty
              ? getDeviceTypePhone()
              ? context.height() * 0.57
              : context.height() * 0.58
              : getDeviceTypePhone()
              ? context.height() * 0.64
              : context.height() * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      AutoSizeText(
                        parseHtmlString(widget.data!.title.validate()),
                        style: boldTextStyle(size: !getDeviceTypePhone() ? 26 : 20, color: textPrimaryColorGlobal),
                        maxLines: 3,
                      ),
                      // Text(parseHtmlString(widget.data!.title.validate()), style: boldTextStyle(size: !getDeviceTypePhone() ? 26 : 20, color: textPrimaryColorGlobal), maxLines: 4),
                      8.height,
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: textSecondaryColorGlobal),
                          4.width,
                          if (widget.data!.createdAt != null) Text(widget.data!.createdAt!.timeAgo, style: secondaryTextStyle(size: !getDeviceTypePhone() ? 16 : 14)),
                          4.width,
                          Text('・', style: secondaryTextStyle()),
                          4.width,
                          // Text('${(parseHtmlString(widget.data!.shortContent).calculateReadTime()).ceilToDouble().toInt()} ${languages.minRead}', style: secondaryTextStyle(size: 12)),
                          if (widget.data!.createdAt != null) Text(DateFormat('dd-MM-yyyy').format(widget.data!.createdAt!), style: secondaryTextStyle(size: !getDeviceTypePhone() ? 16 : 14)),
                        ],
                      ),
                      8.height,
                    ],
                  ).paddingSymmetric(horizontal: 16),
                  HtmlWidget(postContent: widget.data!.shortContent.validate()).paddingSymmetric(horizontal: 12).expand(),
                ],
              ).expand(),
              Text(languages.readMore, style: boldTextStyle()).onTap(() {
                if (widget.data!.image!.contains('youtube.com')) {
                  youtubePlayerController.pause();
                }
                NewsDetailScreen(id: widget.data!.id).launch(context);
              }).paddingLeft(16),
              if (getBoolAsync(DISABLE_AD) == true || bannerAdsModel.img == null || bannerAdsModel.img!.isEmpty || bannerAdsModel.url == null || bannerAdsModel.url!.isEmpty) 16.height,
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    Icon(MaterialIcons.keyboard_arrow_up, size: 22, color: textSecondaryColorGlobal.withOpacity(0.7)),
                    Text(languages.swipeUp, style: secondaryTextStyle(size: 14, color: textSecondaryColorGlobal.withOpacity(0.7))),
                  ],
                ),
              ),
              // if (getBoolAsync(DISABLE_AD) == true) 16.height,
              // getBoolAsync(DISABLE_AD) == false
              //     ? getStringAsync(AD_TYPE) == Admob
              //         ? Container(child: AdWidget(ad: buildBannerAd()..load()), height: buildBannerAd().size.height.toDouble())
              //         : loadFacebookBannerId()
              //     : SizedBox(),
            ],
          ),
        ),
      ],
    );
    // return Screenshot(
    //   controller: screenshotController,
    //   key: screenshotKey,
    //   child: Column(
    //     children: [
    //       Stack(
    //         clipBehavior: Clip.none,
    //         alignment: Alignment.bottomLeft,
    //         children: [
    //           widget.data!.image!.contains('youtube.com') ? youTubeComponent() : cachedImage(widget.data!.image, width: context.width(), height: context.height() * 0.4, fit: BoxFit.cover),
    //           widget.data!.categoryData == null ? SizedBox() : Positioned(
    //             bottom: -10,
    //             left: 16,
    //             child: Container(
    //               padding: EdgeInsets.all(4),
    //               decoration: boxDecorationWithRoundedCorners(backgroundColor: colorPrimary.withOpacity(0.5)),
    //               child: Row(
    //                 children: [
    //                   cachedImage(widget.data!.categoryData!.image, width: 28, height: 28, fit: BoxFit.cover).cornerRadiusWithClipRRect(2),
    //                   8.width,
    //                   Text(widget.data!.categoryData!.name!, style: boldTextStyle(size: 14, color: Colors.white, letterSpacing: 1)),
    //                 ],
    //               ),
    //             )
    //
    //             // getPostCategoryTagWidget(context, widget.data)
    //             // Container(
    //             //   padding: EdgeInsets.all(4),
    //             //   decoration: boxDecorationWithRoundedCorners(backgroundColor: colorPrimary.withOpacity(0.5)),
    //             //   child: Text(appName, style: boldTextStyle(color: white)),
    //             // ),
    //           )
    //         ],
    //       ),
    //       16.height,
    //       SizedBox(
    //         height: getBoolAsync(DISABLE_AD) == false || bannerAdsModel.img == null || bannerAdsModel.img!.isEmpty || bannerAdsModel.url == null || bannerAdsModel.url!.isEmpty
    //             ? getDeviceTypePhone()
    //                 ? context.height() * 0.57
    //                 : context.height() * 0.58
    //             : getDeviceTypePhone()
    //                 ? context.height() * 0.64
    //                 : context.height() * 0.5,
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Column(
    //                   children: [
    //                     AutoSizeText(
    //                       parseHtmlString(widget.data!.title.validate()),
    //                       style: boldTextStyle(size: !getDeviceTypePhone() ? 26 : 20, color: textPrimaryColorGlobal),
    //                       maxLines: 3,
    //                     ),
    //                     // Text(parseHtmlString(widget.data!.title.validate()), style: boldTextStyle(size: !getDeviceTypePhone() ? 26 : 20, color: textPrimaryColorGlobal), maxLines: 4),
    //                     8.height,
    //                     Row(
    //                       children: [
    //                         Icon(Icons.access_time, size: 16, color: textSecondaryColorGlobal),
    //                         4.width,
    //                         if (widget.data!.createdAt != null) Text(widget.data!.createdAt!.timeAgo, style: secondaryTextStyle(size: !getDeviceTypePhone() ? 16 : 14)),
    //                         4.width,
    //                         Text('・', style: secondaryTextStyle()),
    //                         4.width,
    //                         // Text('${(parseHtmlString(widget.data!.shortContent).calculateReadTime()).ceilToDouble().toInt()} ${languages.minRead}', style: secondaryTextStyle(size: 12)),
    //                         if (widget.data!.createdAt != null) Text(DateFormat('dd-MM-yyyy').format(widget.data!.createdAt!), style: secondaryTextStyle(size: !getDeviceTypePhone() ? 16 : 14)),
    //                       ],
    //                     ),
    //                     8.height,
    //                   ],
    //                 ).paddingSymmetric(horizontal: 16),
    //                 HtmlWidget(postContent: widget.data!.shortContent.validate()).paddingSymmetric(horizontal: 12).expand(),
    //               ],
    //             ).expand(),
    //             Text(languages.readMore, style: boldTextStyle()).onTap(() {
    //               if (widget.data!.image!.contains('youtube.com')) {
    //                 youtubePlayerController.pause();
    //               }
    //               NewsDetailScreen(id: widget.data!.id).launch(context);
    //             }).paddingLeft(16),
    //             if (getBoolAsync(DISABLE_AD) == true || bannerAdsModel.img == null || bannerAdsModel.img!.isEmpty || bannerAdsModel.url == null || bannerAdsModel.url!.isEmpty) 16.height,
    //             Align(
    //               alignment: Alignment.bottomCenter,
    //               child: Column(
    //                 children: [
    //                   Icon(MaterialIcons.keyboard_arrow_up, size: 22, color: textSecondaryColorGlobal.withOpacity(0.7)),
    //                   Text(languages.swipeUp, style: secondaryTextStyle(size: 14, color: textSecondaryColorGlobal.withOpacity(0.7))),
    //                 ],
    //               ),
    //             ),
    //             // if (getBoolAsync(DISABLE_AD) == true) 16.height,
    //             // getBoolAsync(DISABLE_AD) == false
    //             //     ? getStringAsync(AD_TYPE) == Admob
    //             //         ? Container(child: AdWidget(ad: buildBannerAd()..load()), height: buildBannerAd().size.height.toDouble())
    //             //         : loadFacebookBannerId()
    //             //     : SizedBox(),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
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
