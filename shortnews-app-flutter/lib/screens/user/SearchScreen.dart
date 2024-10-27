import 'package:flutter/material.dart';
import '/../components/AppWidgets.dart';
import '/../main.dart';
import '/../models/NewsData.dart';
import '/../utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'components/UserNewsListWidget.dart';

class SearchScreen extends StatefulWidget {
  static String tag = '/SearchFragment';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin {
  TextEditingController searchCont = TextEditingController();

  FocusNode searchFocus = FocusNode();
  List<NewsData> news = [];
  List<NewsData> searchList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    200.milliseconds.delay.then((value) => context.requestFocus(searchFocus));
    loadNews();
  }

  void loadNews() {
    newsService.getAllNews().then((value) {
      // print("News $value");
      // log(value);
      news = value;
      if (searchCont.text.isNotEmpty) {
        searchList.clear();
        for (int i = 0; i <= searchCont.text.length; i++) {
          String data = news[i].title.validate();
          if (data.toLowerCase().contains(searchCont.text.toLowerCase())) {
            searchList.add(news[i]);
            setState(() {});
          }
        }
      }
    }).catchError((e) {
      log(e);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    print(searchList);
    return Scaffold(
      appBar: AppBar(
        title: Text(languages.searchHintText, style: boldTextStyle()),
        backgroundColor: context.cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: context.iconColor),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          8.height,
          AppTextField(
            controller: searchCont,
            textFieldType: TextFieldType.OTHER,
            autoFocus: true,
            focus: searchFocus,
            decoration: inputDecoration(labelText: languages.searchHere),
            onChanged: (v) async {
              setState(() {
                searchList = news.where((u) => (u.title!.toLowerCase().contains(v.toLowerCase()) || u.title!.toLowerCase().contains(v.toLowerCase()))).toList();
              });
            },
            onFieldSubmitted: (c) {
              loadNews();
              setState(() {});
            },
          ).paddingSymmetric(horizontal: 16),
          searchList.isEmpty ? noDataWidget().center().expand() : SingleChildScrollView(child: UserNewsListWidget(list: searchList, name: languages.searchHintText)).expand(),
        ],
      ),
    );
  }
}
