import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '/../screens/user/MyFeedScreen.dart';
import '/../utils/Colors.dart';
import '../../components/AdMobAdComponent.dart';
import '../../components/FacebookAdComponent.dart';
import '/../models/NewsData.dart';
import '/../components/AppWidgets.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import '../../main.dart';
import 'components/UserNewsItemWidget.dart';
import 'package:flutter/services.dart';

class ViewAllNewsScreen extends StatefulWidget {
  static String tag = '/ViewAllNewsScreen';
  final String? title;
  final String? newsType;

  final String filterBy;
  final DocumentReference? categoryRef;

  ViewAllNewsScreen({this.title, this.newsType, this.filterBy = FilterByPost, this.categoryRef});

  @override
  _ViewAllNewsScreenState createState() => _ViewAllNewsScreenState();
}

class _ViewAllNewsScreenState extends State<ViewAllNewsScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {}

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: getBoolAsync(DISABLE_AD) == false
          ? getStringAsync(AD_TYPE) == Admob
              ? Container(child: AdWidget(ad: buildBannerAd()..load()), height: buildBannerAd().size.height.toDouble())
              : loadFacebookBannerId()
          : SizedBox(),
      appBar: appBarWidget(widget.title.validate(), color: colorPrimary, systemUiOverlayStyle: SystemUiOverlayStyle.light, textColor: Colors.white),
      body: PaginateFirestore(
        itemBuilderType: PaginateBuilderType.listView,
        itemBuilder: (context, documentSnapshot, index) {
          NewsData data = NewsData.fromJson(documentSnapshot[index].data() as Map<String, dynamic>);

          return UserNewsItemWidget(
            newsData: data,
            onTap: () {
              MyFeedScreen(news: [data], ind: index, name: languages.myFeed).launch(context);
            },
          );
        },
        shrinkWrap: true,
        padding: EdgeInsets.all(16),
        // orderBy is compulsory to enable pagination
        query: widget.filterBy == FilterByPost ? newsService.buildCommonQuery(newsType: widget.newsType) : newsService.buildNewsByCategoryQuery(widget.categoryRef),
        itemsPerPage: DocLimit,
        bottomLoader: loader(),
        initialLoader: loader(),
        onEmpty: noDataWidget(),
        onError: (e) => Text(e.toString(), style: primaryTextStyle()).center(),
      ),
    );
  }
}
