import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mighty_sort_news/models/BannerAdModel.dart';
import 'package:mighty_sort_news/models/UserPreferenceCategory.dart';
import '../models/CategoryData.dart';
import '../models/DashboardResponse.dart';
import '../models/NewsData.dart';
import '../models/UserModel.dart';
import '../utils/Constants.dart';
import '../utils/ModelKeys.dart';
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';
import 'BaseService.dart';

const batches = [];

class NewsService extends BaseService {

  List<DocumentReference>? categoriesDocs;
  List<List<DocumentReference>>? sublist;

  NewsService() {
    ref = db.collection('news');
  }

  Future<DashboardResponse> getUserDashboardData() async {
    DashboardResponse dashboardResponse = DashboardResponse();

    dashboardResponse.breakingNews = await getNewsFuture(newsType: NewsTypeBreaking);
    dashboardResponse.story = await getNewsFuture(newsType: NewsTypeStory);
    dashboardResponse.recentNews = await getNewsFuture(newsType: NewsTypeRecent);

    setValue(DASHBOARD_DATA, jsonEncode(dashboardResponse.toJson(toStore: false)));

    return dashboardResponse;
  }

  DashboardResponse? getCachedUserDashboardData() {
    String data = getStringAsync(DASHBOARD_DATA);

    if (data.isNotEmpty) {
      return DashboardResponse.fromJson(jsonDecode(data));
    } else {
      return null;
    }
  }

  Query buildCommonQuery({String? newsType = '', String? searchText, List<DocumentReference>? subCatList}) {
    Query query;

    if (newsType == NewsTypeBreaking) {
      query = ref!.where(NewsKeys.newsType, isEqualTo: newsType).orderBy(CommonKeys.updatedAt, descending: true);
    } else if (newsType == NewsTypeStory) {
      query = ref!.where(NewsKeys.newsType, isEqualTo: newsType).where(CommonKeys.createdAt, isGreaterThan: DateTime.now().subtract(Duration(days: 1)));
    } else if (newsType == NewsTypeRecent) {
      query = ref!.where(NewsKeys.newsType, isEqualTo: newsType).orderBy(CommonKeys.updatedAt, descending: true);
    } else {
      query = ref!.where(NewsKeys.caseSearch, arrayContains: searchText).orderBy(CommonKeys.updatedAt, descending: true);
    }

    // query = query.where(NewsKeys.categoryRef, whereIn: subCatList);
    return query.where(NewsKeys.newsStatus, whereIn: appStore.isAdmin ? [NewsStatusPublished, NewsStatusUnpublished, NewsStatusDraft] : [NewsStatusPublished]);
  }

  getCategories() async {
    categoriesDocs = [];

    if(appStore.isLoggedIn) {
      List<UserPreferenceCategory> cats = await userPreferenceService
          .getPreferences();

      cats.forEach((element) {
        // catReferences.add(categoryService.ref!.doc(element.id));
        categoriesDocs!.add(categoryService.ref!.doc(element.categoryId));
      });
    }
    return categoriesDocs;
  }

  getCategoriesSublist() async {
    sublist = [];

    int i = 0;
    // print(categoriesDocs);
    // if(categoriesDocs == null){
    if(categoriesDocs == null || categoriesDocs!.isEmpty){
      await getCategories();
    }

    if(categoriesDocs!.length > 10) {
      while (i < categoriesDocs!.length) {
        if ((i + 9) > categoriesDocs!.length) {
          print("Start: $i - End: ${i + (categoriesDocs!.length - i)}");
          sublist!.add(
              categoriesDocs!.sublist(i, i + (categoriesDocs!.length - i)));
          break;
        } else {
          print("Start: $i - End: ${i + 10}");
          sublist!.add(categoriesDocs!.sublist(i, i + 10));
        }
        i = i + 10;
      }
    }

    return sublist;
  }

  Future<List<NewsData>> getNewsFuture({String newsType = '', String? searchText, int limit = DocLimit}) async {
    Query query;

    if (searchText.validate().isNotEmpty) {
      query = buildCommonQuery(newsType: newsType, searchText: searchText);
    } else {
      query = buildCommonQuery(newsType: newsType, searchText: searchText).limit(limit);
    }

    return await query.get().then((x) {
      return x.docs.map((y) => NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<List<NewsData>> getNewsFutureCategories({String newsType = '', String? searchText, int limit = DocLimit}) async {

    List<NewsData> newsData = [];
    Query query;

    await getCategoriesSublist();


    if(sublist!.isNotEmpty) {
      await Future.forEach(sublist!, (element) async {
        if (searchText
            .validate()
            .isNotEmpty) {
          query = buildCommonQuery(newsType: newsType,
              searchText: searchText,
              subCatList: element as List<DocumentReference>);
        } else {
          query = buildCommonQuery(newsType: newsType,
              searchText: searchText,
              subCatList: element as List<DocumentReference>).limit(limit);
        }

        List<NewsData> temp = await query.get().then((x) {
          return x.docs.map((y) =>
              NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
        });
        newsData.addAll(temp);
      });

      return newsData;
    }

    print(categoriesDocs);
    if (searchText.validate().isNotEmpty) {
      query = buildCommonQuery(newsType: newsType, searchText: searchText, subCatList: categoriesDocs);
    } else {
      query = buildCommonQuery(newsType: newsType, searchText: searchText, subCatList: categoriesDocs).limit(limit);
    }

    return await query.get().then((x) {
      return x.docs.map((y) => NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
    });
  }


  Future<List<NewsData>> getMostViewedNewsFuture({int limit = DocLimit}) async {
    Query query = ref!.orderBy(NewsKeys.postViewCount, descending: true).limit(limit);

    return await query.get().then((x) {
      return x.docs.map((y) => NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
    });
  }

  Stream<List<NewsData>> getNews({String newsType = '', String? searchText}) {
    Query query;

    if (searchText.validate().isNotEmpty) {
      query = buildCommonQuery(newsType: newsType, searchText: searchText);
    } else {
      query = buildCommonQuery(newsType: newsType, searchText: searchText).limit(DocLimit);
    }

    return query.snapshots().map((x) {
      return x.docs.map((y) => NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
    });
  }

  Stream<int> getTotalNewsCount() {
    return ref!.snapshots().map((x) => x.docs.length);
  }

  Future<List<NewsData>> getBookmarkNewsFuture() async {
    if (bookmarkList.isNotEmpty) {
      Query query = ref!.where(CommonKeys.id).orderBy(CommonKeys.updatedAt, descending: true);

      return await query.get().then((x) {
        return x.docs.map((y) => NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
      });


    } else {
      return [];
    }
  }

  Query buildNewsByCategoryQuery(DocumentReference? doc) {
    return ref!
        .where(NewsKeys.newsStatus, whereIn: appStore.isAdmin ? [NewsStatusPublished, NewsStatusUnpublished, NewsStatusDraft] : [NewsStatusPublished])
        .where(NewsKeys.categoryRef, isEqualTo: doc)
        .orderBy(CommonKeys.updatedAt, descending: true);
  }

  Query buildNewsByCategoriesQuery(List<DocumentReference?> docs) {
    return ref!
        // .where(NewsKeys.newsStatus, whereIn: appStore.isAdmin ? [NewsStatusPublished, NewsStatusUnpublished, NewsStatusDraft] : [NewsStatusPublished])
        .where(NewsKeys.categoryRef, whereIn: docs)
        .orderBy(CommonKeys.updatedAt, descending: true);
  }

  Future<List<NewsData>> getNewsByCategoriesFuture(List<DocumentReference?> docs) async {
    Query query = buildNewsByCategoriesQuery(docs);

    return await query.get().then((x) {
      return x.docs.map((y) => NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<List<NewsData>> getNewsByCategoryFuture(DocumentReference doc) async {
    Query query = buildNewsByCategoryQuery(doc);

    return await query.get().then((x) {
      return x.docs.map((y) => NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
    });
  }

  Stream<List<NewsData>> getNewsByCategory(DocumentReference? doc) {
    Query query = ref!
        .where(NewsKeys.newsStatus, whereIn: appStore.isAdmin ? [NewsStatusPublished, NewsStatusUnpublished, NewsStatusDraft] : [NewsStatusPublished])
        .where(NewsKeys.categoryRef, isEqualTo: doc)
        .orderBy(CommonKeys.updatedAt, descending: true);

    return query.snapshots().map((x) {
      return x.docs.map((y) => NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<List<NewsData>> getNewsOfCategory(DocumentReference? doc) {
    Query query = ref!
        .where(NewsKeys.newsStatus, whereIn: appStore.isAdmin ? [NewsStatusPublished, NewsStatusUnpublished, NewsStatusDraft] : [NewsStatusPublished])
        .where(NewsKeys.categoryRef, isEqualTo: doc)
        .orderBy(CommonKeys.updatedAt, descending: true);
    return query.get().then((value) {
      // log(value);
      return value.docs.map((y) => NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<NewsData> newsDetail(String? id) async {
    return await ref!.doc(id).get().then((value) => NewsData.fromJson(value.data() as Map<String, dynamic>));
  }

  Future<List<NewsData>> relatedNewsFuture(DocumentReference? doc, String? newsId) async {
    Query query = ref!
        .where(NewsKeys.newsStatus, whereIn: appStore.isAdmin ? [NewsStatusPublished, NewsStatusUnpublished, NewsStatusDraft] : [NewsStatusPublished])
        .where(NewsKeys.categoryRef, isEqualTo: doc)
        .limit(10);

    var data = await query.get().then((x) {
      return x.docs.map((y) => NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
    });

    data.removeWhere((element) => element.id == newsId);

    return data;
  }

  Future<List<NewsData>> newsByAuthor(DocumentReference? doc) async {
    Query query = ref!.where(NewsKeys.authorRef, isEqualTo: doc);

    var data = await query.get().then((x) {
      return x.docs.map((y) => NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
    });

    return data;
  }

  Future<CategoryData> getNewsCategory(DocumentReference doc) async {
    return await doc.get().then((value) => CategoryData.fromJson(value.data() as Map<String, dynamic>));
  }

  Future<UserModel> getAuthor(DocumentReference doc) async {
    return await doc.get().then((value) => UserModel.fromJson(value.data() as Map<String, dynamic>));
  }

  Future<void> updatePostCount(String? id) async {
    await updateDocument({NewsKeys.postViewCount: FieldValue.increment(1)}, id);
  }

  Future<void> updatePostCommentCount(String? id,count) async {
    await updateDocument({NewsKeys.commentCount: count}, id);
  }

  /// categoryService.ref!.doc(widget.data!.id)
  Future<List<NewsData>> getNewsListByCategories(List<DocumentReference> docs) async {
    List<List<DocumentReference>> sublist = [];
    List<NewsData> newsData = [];
    int i = 0;

    if(docs.length > 10) {
      while (i < docs.length) {
        if ((i + 9) > docs.length) {
          print("Start: $i - End: ${i + (docs.length - i)}");
          sublist.add(docs.sublist(i, i + (docs.length - i)));
          break;
        } else {
          print("Start: $i - End: ${i + 10}");
          sublist.add(docs.sublist(i, i + 10));
        }
        i = i + 10;
      }

      await Future.forEach(sublist, (element) async {
        Query query = buildNewsByCategoriesQuery(element as List<DocumentReference>);

        List<NewsData> temp = await query.get().then((x) {
          return x.docs.map((y) =>
              NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
        });
        newsData.addAll(temp);
      });

      return newsData;
    } else {
      Query query = buildNewsByCategoriesQuery(docs);

      return await query.get().then((x) {
        return x.docs.map((y) =>
            NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
      });
    }
  }

  List<BannerAdModel?> bannerAds = [];
  initializeAds(int length) async {
    bannerAds = [];

    // if(bannerAdModel.isAdLoaded == false){
    //   bannerAdModel.buildBannerAd()..load();
    // }
    // for(int i = 0; i < length; i++){
    //   BannerAdModel bannerAdModel = BannerAdModel();
    //   bannerAdModel.buildBannerAd()..load();
    //   await Future.delayed(Duration(seconds: 2),(){
    //     print("Is Banner Loaded: ${bannerAdModel.isAdLoaded}");
    //     if(bannerAdModel.isAdLoaded == true) {
    //       bannerAds.add(bannerAdModel);
    //     }
    //   });
    // }
  }

  Future<List<NewsData>> getNewsList() async {

    List<NewsData> newsData = [];

    if(appStore.isLoggedIn) {

      if(preferences.isEmpty){
        preferences = await userPreferenceService
            .getPreferences();
      }
      // List<UserPreferenceCategory> cats = await userPreferenceService
      //     .getPreferences();

      List<DocumentReference> docs = [];
      CategoryData? temp;

      // cats.forEach((element) {
      preferences.forEach((element) {
        // catReferences.add(categoryService.ref!.doc(element.id));
        docs.add(categoryService.ref!.doc(element.categoryId));

        temp = appCategories.firstWhere((cat) => cat.id == element.categoryId);
        if(temp != null) {
          userPreferenceCategories.add(temp!);
        }

      });
      List<List<DocumentReference>> sublist = [];

      int i = 0;

      if(docs.length > 10) {
        while (i < docs.length) {
          if ((i + 9) > docs.length) {
            print("Start: $i - End: ${i + (docs.length - i)}");
            sublist.add(docs.sublist(i, i + (docs.length - i)));
            break;
          } else {
            print("Start: $i - End: ${i + 10}");
            sublist.add(docs.sublist(i, i + 10));
          }
          i = i + 10;
        }

        await Future.forEach(sublist, (element) async {
          Query query = buildNewsByCategoriesQuery(element as List<DocumentReference>);

          List<NewsData> temp = await query.get().then((x) {
            return x.docs.map((y) =>
                NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
          });
          newsData.addAll(temp);
        });

        // return newsData;
      } else if(docs.length > 0) {
        Query query = buildNewsByCategoriesQuery(docs);

        newsData = await query.get().then((x) {
          return x.docs.map((y) =>
              NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
        });
        // return await query.get().then((x) {
        //   return x.docs.map((y) =>
        //       NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
        // });
      }
    }

    if(newsData.length <= 0) {
      Query query = ref!.orderBy(CommonKeys.updatedAt, descending: true);

      newsData = await query.get().then((x) {
        return x.docs.map((y) =>
            NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
      });

      // return await query.get().then((x) {
      //   return x.docs.map((y) => NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
      // });
    }

    // print("Total News: ${newsData.length}");
    // print("Total Ads to Show: ${(newsData.length / 5).floor()}");
    // initializeAds((newsData.length / 5).floor());
    // for(int i = 1; i <= bannerAds.length; i = i + 1){
    //   newsData.insert(i * 5, NewsData(bannerAd: bannerAds[i - 1]));
    // }

    for(int i = 0; i < newsData.length; i++){
      if(newsData[i].bannerAd == null) {
        await newsData[i].setCategoryName();
      }
    }

    return newsData;
  }

  Future<NewsData> getNewsDetail(id) async {
    NewsData doc = NewsData();
    return ref!.doc(id).get().then((x) {
      if (x.data() != null) {
        doc = NewsData.fromJson(x.data() as Map<String, dynamic>);
        return doc;
      } else {
        print("sorry");
        return doc;
      }
    });
  }

  // Future<List<NewsData>> getAllNews({String newsType = '', String? searchText}) {
  //   List<NewsData> doc;
  //   return ref!.orderBy('updatedAt', descending: true).get().then((value) {
  //      doc= NewsData.fromJson(value.docs as Map<String, dynamic> );
  //   });
  // }

  Future<List<NewsData>> getAllNews() async {
    List<NewsData> newsData = [];

    if(appStore.isLoggedIn) {
      List<UserPreferenceCategory> cats = await userPreferenceService
          .getPreferences();

      List<DocumentReference> docs = [];

      cats.forEach((element) {
        // catReferences.add(categoryService.ref!.doc(element.id));
        docs.add(categoryService.ref!.doc(element.categoryId));
      });
      List<List<DocumentReference>> sublist = [];

      print(docs);
      int i = 0;

      if(docs.length > 10) {
        while (i < docs.length) {
          if ((i + 9) > docs.length) {
            print("Start: $i - End: ${i + (docs.length - i)}");
            sublist.add(docs.sublist(i, i + (docs.length - i)));
            break;
          } else {
            print("Start: $i - End: ${i + 10}");
            sublist.add(docs.sublist(i, i + 10));
          }
          i = i + 10;
        }

        await Future.forEach(sublist, (element) async {
          Query query = buildNewsByCategoriesQuery(element as List<DocumentReference>);

          List<NewsData> temp = await query.get().then((x) {
            return x.docs.map((y) =>
                NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
          });
          newsData.addAll(temp);
        });

        // return newsData;
      } else if(docs.length > 0) {
        Query query = buildNewsByCategoriesQuery(docs);

        newsData = await query.get().then((x) {
          return x.docs.map((y) =>
              NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
        });
      }

    }

    if(newsData.length <= 0) {
      Query query = ref!.orderBy(CommonKeys.updatedAt, descending: true);

      newsData = await query.get().then((x) {
        return x.docs.map((y) =>
            NewsData.fromJson(y.data() as Map<String, dynamic>)).toList();
      });
    }

    for(int i = 0; i < newsData.length; i++){
      if(newsData[i].bannerAd == null) {
        await newsData[i].setCategoryName();
      }
    }

    return newsData;
  }
}
