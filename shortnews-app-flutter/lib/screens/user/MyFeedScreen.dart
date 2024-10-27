import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:lottie/lottie.dart';
import 'package:mighty_sort_news/models/BannerAdModel.dart';
import 'package:mighty_sort_news/screens/user/BannerAdmob.dart';
import '../../components/AdMobAdComponent.dart';
import '../../components/FacebookAdComponent.dart';
import '../../utils/AppImages.dart';
import '/../components/AppWidgets.dart';
import '/../components/FeedComponent.dart';
import '/../models/AdsModel.dart';
import '/../models/NewsData.dart';
import '/../screens/user/HomeFragment.dart';
import '/../screens/user/WebViewScreen.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import '/../utils/ModelKeys.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import '../../components/HtmlWidget.dart';
import '../../main.dart';
import 'SignInScreen.dart';

// ignore: must_be_immutable
class MyFeedScreen extends StatefulWidget {
  static String tag = '/QuickReadScreen';
  List<NewsData>? news;
  String? name;
  int? ind;
  bool? isSplash;
  bool? isBookMark;
  bool? isDiscover;

  MyFeedScreen({this.news, this.name, this.ind = 0, this.isSplash = false, this.isBookMark = false, this.isDiscover = false});

  @override
  _MyFeedScreenState createState() => _MyFeedScreenState();
}

class _MyFeedScreenState extends State<MyFeedScreen> with SingleTickerProviderStateMixin {
  bool selected = false;
  PageController? pageController;
  ScreenshotController screenshotController = ScreenshotController();
  Uint8List? imageFile;

  final GlobalKey screenshotKey = GlobalKey();
  final GlobalKey imageKey = GlobalKey();
  final GlobalKey keyOne = GlobalKey();

  bool hasError = false;
  String error = '';
  bool? isLatest = false;

  final FlutterShareMe flutterShareMe = FlutterShareMe();
  List<NewsData> newsList = [];
  NewsData newsData = NewsData();
  List<NewsData> notificationNewsData = [];

  AdsModel adsModel = AdsModel();
  bool? isVisible = false;
  bool? afterFirestCom = false;
  bool bookMark=false;
  // bool isShowBookMark=false;
  bool isShowBookMark=true;

  DateTime? currentBackPressTime;

  int length = 0;
  int page = 1;
  int index = 0;
  int numPage = 1;
  bool? isupdate = false;
  bool? isNotofication = false;
  DateTime preBackpress = DateTime.now();

  final InAppReview inAppReview = InAppReview.instance;

  @override
  void initState() {
    super.initState();
    init();
    // confRating();
    // initializeAds();
    // loadInterstitialAd();
  }

  List<BannerAdModel?> bannerAds = [];

  confRating() async {
    if (await inAppReview.isAvailable() && getIntAsync(TIMES_OPENED, defaultValue: 1) % 7 == 0) {
      inAppReview.requestReview();
    }
  }

  Future<void> init() async {
    // await 3.seconds.delay.whenComplete(() {
    //   isShowBookMark=true;
    //   setState(() {});
    // });

    print("I am in init");

    pageController = PageController(initialPage: widget.ind!);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(pageController!.hasClients){
        await pageController!.animateToPage(widget.ind ?? 0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
      }
    });

    appSettingService.setAppSettings();
    if (isMobile) {
      OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult notification) async {
        appStore.setLoading(true);
        print("OneSignal Loading");
        print("Notid" + notification.notification.additionalData!["id"].toString());
        String? notId = notification.notification.additionalData!["id"];

        if (notId != null && notId.isNotEmpty) {
          newsList.clear();
          newsService.getNewsDetail(notId).then((value) {
            newsList.add(value);
            // log(value.id);
            isNotofication = true;
            // log(widget.news!.length);

            newsService.getNewsList().then((value) {
              value.forEachIndexed((element, index) {
                if (notId != element.id) {
                  newsList.add(element);
                }
                widget.news = newsList;
                pageController!.animateTo(0, duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);
              });

              setState(() {});
            });
            appStore.setLoading(false);
            setState(() {});
          });
        } else {
          newsService.getNewsList().then((value) {
            value.forEachIndexed((element, index) {
              if (notId != element.id) {
                newsList.add(element);
              }
              widget.news = newsList;
              pageController!.animateTo(0, duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);
            });

            setState(() {});
          });
          appStore.setLoading(false);
          setState(() {});
        }
        setState(() {});
        appStore.setLanguage(getStringAsync(LANGUAGE, defaultValue: DefaultLanguage), context: context);
      });
    }

    // print("bannerAdModel ${bannerAdModel.myBanner}");

    // if(bannerAdModel.isAdLoaded == false){
    //   bannerAdModel.buildBannerAd()..load();
    // }
    // if(bannerAdModel.isAdLoaded == true && widget.news != null) {

    widget.news!.forEach((element) {
      print(element.bannerAd);
    });
    if(widget.news != null) {

      for (int i = 1; i <= (widget.news!.length / 5).floor(); i++) {
        widget.news!.insert(i * 5, NewsData(bannerAd: true));
      }
    }
    setState(() { });

    isVisible = false;
    afterFirestCom = true;
    setState(() { });
    // await 2.seconds.delay.whenComplete(() {
    //   isVisible = true;
    //   setState(() {});
    // });
    // print("Here-2");
    // await 5.seconds.delay.whenComplete(() {
    //   isVisible = false;
    //   setState(() {});
    //   afterFirestCom = true;
    // });

    pageController!.addListener(() async {
      appStore.setUpDownHide(false);
      if (afterFirestCom == true) {
        await 2.milliseconds.delay.whenComplete(() {
          isVisible = true;
          setState(() {});
        });
        await 5.seconds.delay.whenComplete(() {
          isVisible = false;
          setState(() {});
          // setValue(IS_FIRST_TIME_SCREEN, true);
        });
      }
      if(pageController != null && pageController!.hasClients) {
        if ((pageController!.page!.toInt() + 1) == widget.news!.length) {
          if (page < numPage) {
            page++;
            // appStore.setLoading(true);
            loadNews();
          }
        }
      }
      // pageController!.animateTo(3, duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);

    });
    // if (getBoolAsync(DISABLE_AD) == false) {
    //   if (getStringAsync(AD_TYPE) == Admob) {
    //     loadInterstitialAd();
    //   } else {
    //     loadFacebookBannerId();
    //   }
    // }
    // if (widget.isBookMark == true) loadBookMarkNews();
  }

  loadBookMarkNews() {
    LiveStream().on(StreamRefreshBookmark, (s) {
      setState(() {});
    });
    widget.news!.clear();
    newsService.getBookmarkNewsFuture().then((value) {
      if (value.isNotEmpty) {
        value.forEachIndexed((e, index) {
          bookmarkList.forEachIndexed((e1, i) {
            if (e1!.contains(e.id.toString())) {
              widget.news!.add(e);
              appStore.setLoading(false);
              setState(() {});
              // log(widget.news!.length.toString());
            }
          });
        });
      } else {
        appStore.setLoading(false);
        setState(() {});
      }
    }).catchError((e) {
      appStore.setLoading(false);
    });
  }

  Future<void> loadNews() async {
    appStore.setLoading(true);
    print("loadNews Loading");
    // setState(() { });
    newsService.getNewsList().then((value) {
      widget.news!.clear();
      value.forEach((element) {
        widget.news!.add(element);
        // pageController!.animateTo(0, duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);
        // pageController!.animateTo(widget.ind!.toDouble(), duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);
        if (index == 0) {
          isLatest = true;
        }
      });
      for (int i = 1; i <= (widget.news!.length / 5).floor(); i++) {
        widget.news!.insert(i * 5, NewsData(bannerAd: true));
        // widget.news!.insert(i * 5, NewsData(bannerAd: bannerAdModel));
        // setState(() { });
      }

      pageController!.animateTo(0, duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);

      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
    });
    setState(() { });
  }

  Future<void> loadCustomAds() {
    return adsService.getCustomAds().then((value) {
      adsModel = value;
    });
  }

  Future<void> bookmarkNews(NewsData data) async {
    if (appStore.isLoggedIn) {
      if (bookmarkList.contains(data.id)) {
        removeToBookmark(data);
        toast(languages.removed);
      } else {
        addToBookmark(data);
        toast(languages.successSaved);
      }
      setState(() {});
    } else {
      SignInScreen(isNewTask: true).launch(context);
    }
  }

  Future<void> addToBookmark(NewsData data) async {
    bookmarkList.add(data.id);
    await setValue(BOOKMARKS, jsonEncode(bookmarkList));
    await userService.updateDocument({UserKeys.bookmarks: bookmarkList}, appStore.userId);
    isupdate = true;
    setState(() {});
  }

  Future<void> removeToBookmark(NewsData data) async {
    bookmarkList.remove(data.id);
    await setValue(BOOKMARKS, jsonEncode(bookmarkList));
    await userService.updateDocument({UserKeys.bookmarks: bookmarkList}, appStore.userId);
    isupdate = true;
    setState(() {});
  }

  @override
  void dispose() {
    pageController!.dispose();
    super.dispose();
  }

  Future<void> capture(String? url, NewsData e) async {
    appStore.setLoading(true);
    print("Capture Loading");
    setState(() {});
    await screenshotController
        .captureFromWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                children: [
                  cachedImage(e.image, width: context.width(), height: 335, fit: BoxFit.cover),
                  16.height,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(parseHtmlString(e.title.validate()), style: boldTextStyle(size: 20, color: black), maxLines: 4).onTap(() {
                        bookmarkNews(e);
                      }),
                      8.height,
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16),
                          4.width,
                          if (e.createdAt != null) Text(e.createdAt!.timeAgo),
                          4.width,
                          Text('・'),
                          4.width,
                          Text('${(parseHtmlString(e.shortContent).calculateReadTime()).ceilToDouble().toInt()} ${languages.minRead}'),
                        ],
                      ),
                      8.height,
                      HtmlWidget(postContent: e.shortContent.validate(), color: blackColor).expand(),
                      8.height,
                    ],
                  ).paddingSymmetric(horizontal: 16).expand(),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .then((Uint8List? image) async {
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/image.png').create();
        await imagePath.writeAsBytes(image);
        appStore.setLoading(false);
        PackageInfo.fromPlatform().then((value) async {
          await flutterShareMe.shareToWhatsApp(
              imagePath: imagePath.path,
              fileType: FileType.image,
              msg: isAndroid ? 'Download Short News app from Playstore:\n$playStoreBaseURL${value.packageName}' : 'Download Short News app from AppStore:\n$appStoreBaseURL${value.packageName}');
        });
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  int j = 0;

  // initializeAds() async {
  //   for( int i = 0; i < 1; i++){
  //     BannerAdModel bannerAdModel = BannerAdModel();
  //     bannerAdModel.buildBannerAd()..load();
  //     Future.delayed(Duration(seconds: 2),(){
  //       print("Is Banner Loaded: ${bannerAdModel.isAdLoaded}");
  //       if(bannerAdModel.isAdLoaded == true) {
  //         bannerAds.add(bannerAdModel);
  //         print("Is Banner Loaded: ${bannerAds[0]}");
  //       }
  //     });
  //   }
  // }

  showFeedScreen(int ind){

    if(widget.news![ind].bannerAd != null ){
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expanded(child: Container(child: AdWidget(key: UniqueKey(),ad: widget.news![ind].bannerAd!.myBanner!), height: widget.news![ind].bannerAd!.myBanner!.size.height.toDouble())),
              Expanded(child: BannerAdmob()),
              // Spacer(),
              Column(
                children: [
                  Icon(MaterialIcons.keyboard_arrow_up, size: 22, color: textSecondaryColorGlobal.withOpacity(0.7)),
                  Text(languages.swipeUp, style: secondaryTextStyle(size: 14, color: textSecondaryColorGlobal.withOpacity(0.7))),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return
    FeedComponent(data: widget.news![ind], isNotification: isNotofication).onTap(() {
      appStore.isUpDownHide = !appStore.isUpDownHide;
      setState(() {});
    });
  }

  Future<bool> onWillPop() {
    final timegap = DateTime.now().difference(preBackpress);
    final cantExit = timegap >= Duration(seconds: 2);
    preBackpress = DateTime.now();
    if (cantExit) {
      if (widget.isSplash == true) toast("Press Back button again to Exit");
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  double height = 800;
  bool isAd = false;

  @override
  Widget build(BuildContext context) {
    // print(widget.news);
    // appStore.setLoading(false);
    // print(appCategories);
    // print(appStore.isLoading);
    bookMark=bookmarkList.contains(newsData.id);

    setState(() { });
    return RefreshIndicator(
      color: colorPrimary,
      onRefresh: () async {
        /// If you want to update app setting every time when you refresh home page
        /// Uncomment the below line
        // setState(() {});
        await newsService.getNewsList().then((value) async {
          newsList.clear();
          value.forEach((element) {
            newsList.add(element);
          });
          widget.news!.clear();
          widget.news!.addAll(newsList);

          // print("bannerAdModel ${bannerAdModel.myBanner}");
          //
          // if(bannerAdModel.isAdLoaded == true && widget.news != null) {
          if(widget.news != null) {
            for (int i = 1; i <= (widget.news!.length / 5).floor(); i++) {
              widget.news!.insert(i * 5, NewsData(bannerAd: true));
            }
          }
          // await 1.seconds.delay;
          setState(() { });
        });

      },
      child: Observer(builder: (context) {
        return WillPopScope(
          onWillPop: () {
            return onWillPop();
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: pageController == null ? loader() : widget.news!.isEmpty ?
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(appStore.isDarkMode ? no_internet_dark : no_internet, height: 120),
                15.height,
                Text(languages.unableToFetchNews, style: boldTextStyle(size: 14)),
                // Spacer(),
              ],
            ).center()

            :Stack(
              children: [
                Container(
                  height: context.height(),
                  // height: isAd ? 700 : context.height(),
                  decoration: BoxDecoration(color: context.scaffoldBackgroundColor),
                  child: PageView.builder(
                      controller: pageController,
                      physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: widget.news!.length,
                      onPageChanged: (i) {
                        print("changed");
                        if (widget.isDiscover == true) appStore.setRedirectIndex(i);
                        if (i % 5 == 0 && i != 0) {
                          // Container(child: AdWidget(ad: buildBannerAd()..load()), height: buildBannerAd().size.height.toDouble());
                          // showInterstitialAd();
                        }
                        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
                      },
                      itemBuilder: (context, ind) {
                        newsData = widget.news![ind];
                        index = ind;
                        // return Container();
                        return GestureDetector(
                          onHorizontalDragEnd: (v) {

                            if (afterFirestCom == true) {
                              isVisible = false;
                              setValue(IS_FIRST_TIME_SCREEN, true);
                            } else {
                              isVisible = false;
                            }

                            if (v.velocity.pixelsPerSecond.dx.isNegative) {
                              print("Dragged-");
                              if(widget.news![ind].bannerAd == null) {
                                if (widget.news![ind].image!.contains(
                                    'youtube.com')) {
                                  youtubePlayerController.pause();
                                }
                                WebViewScreen(mInitialUrl: widget.news![ind].sourceUrl, name: widget.news![ind].title).launch(context);
                              }
                            } else if (v.velocity.pixelsPerSecond.dx.isFinite) {
                              print("Dragged+");
                                if(widget.news![ind].bannerAd == null) {
                                  if (widget.news![ind].image!.contains('youtube.com')) {
                                    youtubePlayerController.pause();
                                  }
                                }
                              if (widget.isSplash == true) {
                                print("Draggeds");
                                Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight, child: HomeFragment()));
                              } else {
                                print("FInish");
                                print(newsDataDefault.length);
                                finish(context, isupdate);
                              }
                            }
                          },
                          child:showFeedScreen(ind)

                          // index != 0 && index % 5 == 0 ?  Container(child: AdWidget(ad: buildBannerAd()..load()), height: buildBannerAd().size.height.toDouble()):
                          // widget.news![ind].bannerAd != null ?  Container(child: AdWidget(ad: widget.news![ind].bannerAd!.myBanner!), height: widget.news![ind].bannerAd!.myBanner!.size.height.toDouble()):
                          // FeedComponent(data: widget.news![ind], isNotification: isNotofication).onTap(() {
                          //   appStore.isUpDownHide = !appStore.isUpDownHide;
                          //   setState(() {});
                          // }),
                        );
                      }),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: PreferredSize(
                    preferredSize: Size(context.width(), 50),
                    child: Visibility(
                      visible: appStore.isUpDownHide,
                      child: AppBar(
                        title: Column(
                          children: [
                            Text(widget.name.validate(), style: boldTextStyle(size: 20)),
                            Container(margin: EdgeInsets.only(top: 8), height: 5, width: 40, decoration: boxDecorationDefault(color: colorPrimary))
                          ],
                        ),
                        backgroundColor: context.scaffoldBackgroundColor,
                        leadingWidth: 120,
                        centerTitle: true,
                        leading: TextIcon(
                          onTap: () async {
                            if (widget.isSplash == true) {
                              Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight, duration: Duration(milliseconds: 100), child: HomeFragment()));
                            } else {
                              finish(context, isupdate);
                            }
                            SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
                          },
                          text: languages.myFeed,
                          prefix: Icon(Icons.arrow_back_ios, color: context.iconColor, size: 18),
                        ),
                        actions: [
                          if (widget.isDiscover == true)
                            getIntAsync(REDIRECT_INDEX) == 0
                                ? TextIcon(
                                    onTap: () {
                                      loadNews();
                                      if (isLatest == true) {
                                        toast("Your feed is Up to Date");
                                      }
                                    },
                                    prefix: Icon(Icons.refresh, color: context.iconColor),
                                  )
                                : TextIcon(
                                    onTap: () {
                                      pageController!.animateTo(0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
                                    },
                                    prefix: Icon(Icons.arrow_upward, color: context.iconColor),
                                  ),
                          if (widget.isDiscover == false)
                            index == 0
                                ? TextIcon(
                                    onTap: () {
                                      loadNews();
                                      if (isLatest == true) {
                                        toast("Your feed is Up to Date");
                                      }
                                    },
                                    prefix: Icon(Icons.refresh, color: context.iconColor),
                                  )
                                : TextIcon(
                                    onTap: () {
                                      pageController!.animateTo(0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
                                    },
                                    prefix: Icon(Icons.arrow_upward, color: context.iconColor),
                                  )
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Visibility(
                    visible: appStore.isUpDownHide,
                    child: AnimatedContainer(
                      curve: Curves.fastOutSlowIn,
                      decoration: BoxDecoration(color: context.scaffoldBackgroundColor, boxShadow: [BoxShadow(blurRadius: 1, spreadRadius: 0.1, color: grey)]),
                      padding: EdgeInsets.all(6),
                      duration: Duration(seconds: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                              onPressed: () {
                                PackageInfo.fromPlatform().then((value) {
                                  String package = '';
                                  if (isAndroid) package = value.packageName;
                                  log('${languages.share} $mAppName\n\n${storeBaseURL()}$package${newsData.sourceUrl}');
                                  Share.share('${newsData.title}\n\n${storeBaseURL()}$package');
                                });
                              },
                              icon: Icon(Icons.share)),
                          isShowBookMark?IconButton(
                            onPressed: () {
                              bookmarkNews(newsData);
                            },
                            icon: Icon(
                              bookMark? Icons.bookmark : Icons.bookmark_outline,
                              color:bookMark ? colorPrimary : context.iconColor,
                            ),
                          ):Lottie.asset(appStore.isDarkMode ? ic_loader_dark : ic_loader, width: 48, height: 48).center(),
                          IconButton(
                              onPressed: () {
                                capture(newsData.sourceUrl, newsData);
                              },
                              icon: Icon(Ionicons.logo_whatsapp, color: greenColor))
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: isVisible == true && getBoolAsync(IS_FIRST_TIME_SCREEN) == false,
                  // visible: true,
                  child: GestureDetector(
                    onHorizontalDragEnd: (v) {
                      if (afterFirestCom == true) {
                        isVisible = false;
                        setValue(IS_FIRST_TIME_SCREEN, true);
                      } else {
                        isVisible = false;
                      }
                      setState(() {});
                      if (v.velocity.pixelsPerSecond.dx.isNegative) {
                        if (afterFirestCom == true) {
                          isVisible = false;
                          setValue(IS_FIRST_TIME_SCREEN, true);
                        } else {
                          isVisible = false;
                        }
                        setState(() {});
                        print("Dragged-");
                        if(widget.news![appStore.redirectIndex].bannerAd == null) {
                          if (widget.news![appStore.redirectIndex].image!.contains(
                              'youtube.com')) {
                            youtubePlayerController.pause();
                          }
                          WebViewScreen(mInitialUrl: widget.news![appStore.redirectIndex].sourceUrl, name: widget.news![appStore.redirectIndex].title).launch(context);
                        }
                      } else if (v.velocity.pixelsPerSecond.dx.isFinite) {
                        print("Dragged+");
                        if(widget.news![appStore.redirectIndex].bannerAd == null) {
                          if (widget.news![appStore.redirectIndex].image!.contains('youtube.com')) {
                            youtubePlayerController.pause();
                          }
                        }
                        if (widget.isSplash == true) {
                          print("Draggeds");
                          Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight, child: HomeFragment()));
                        } else
                          finish(context, isupdate);
                      }
                    },
                    onTap: () {

                      if (afterFirestCom == true) {
                        isVisible = false;
                        setValue(IS_FIRST_TIME_SCREEN, true);
                      } else {
                        isVisible = false;
                      }
                      setState(() {});
                    },
                    child: Container(
                      color: black.withOpacity(0.4),
                      // height: context.height(),
                      // width: context.width(),
                      alignment: afterFirestCom == true ? Alignment.bottomLeft : Alignment.bottomRight,
                      child: Column(
                        crossAxisAlignment: afterFirestCom == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset(afterFirestCom == true ? ic_leftToRight :ic_rightToLeft, height: 150, width: 150),
                          Container(
                            margin: afterFirestCom == true ? EdgeInsets.only(bottom: 150, left: 16) : EdgeInsets.only(bottom: 150, right: 16),
                            padding: EdgeInsets.all(8),
                            decoration: boxDecorationWithRoundedCorners(backgroundColor: context.scaffoldBackgroundColor),
                            child: Text(afterFirestCom == true ? languages.swipeLeft : languages.swipeRight, style: secondaryTextStyle()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (hasError) Text(error.validate()).center(),
                Observer(builder: (_) => loader().visible(appStore.isLoading && widget.news!.isEmpty)),
              ],
            ),
            // floatingActionButton: ElevatedButton(
            //   onPressed: () async {
            //
            //     showInterstitialAd();
            //     // await confRating();
            //   }, child: Text("Click Me!"),
            // ),
          ),
        );
      }),
    );
  }

  Future<String> getFileSavePath() async {
    Directory dir = await getFileSaveDirectory();
    log(dir.path);
    return dir.path;
  }

  Future<Directory> getFileSaveDirectory() async {
    return await getApplicationSupportDirectory();
  }
}
