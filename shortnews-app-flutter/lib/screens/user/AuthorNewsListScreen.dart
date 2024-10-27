import 'package:flutter/material.dart';
import '/../utils/Colors.dart';
import '/../models/NewsData.dart';
import 'package:flutter/services.dart';

import 'package:nb_utils/nb_utils.dart';

import 'components/UserNewsListWidget.dart';

class AuthorNewsListScreen extends StatefulWidget {
  static String tag = '/AuthorNewsListScreen';
  final String title;
  final List<NewsData> news;

  AuthorNewsListScreen({required this.title, required this.news});

  @override
  State<AuthorNewsListScreen> createState() => _AuthorNewsListScreenState();
}

class _AuthorNewsListScreenState extends State<AuthorNewsListScreen> {
  List<String> newsList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    lodeList();
  }

  lodeList() {
    widget.news.sort((a, b) {
      return b.createdAt!.compareTo(a.createdAt!);
    });
    widget.news.forEach((element) {
      newsList.add(element.newsType.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(widget.title.validate(), color: colorPrimary,systemUiOverlayStyle: SystemUiOverlayStyle.light, textColor: Colors.white),
      body: SingleChildScrollView(child: UserNewsListWidget(list: widget.news)),
    );
  }
}
