import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_sort_news/components/AppWidgets.dart';
import 'package:mighty_sort_news/models/UserPreferenceCategory.dart';
import 'package:mighty_sort_news/screens/user/MyFeedScreen.dart';
import 'package:mighty_sort_news/utils/Common.dart';
import '../models/CategoryData.dart';
import '../utils/AppImages.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../main.dart';
import 'admin/AdminDashboardScreen.dart';
import 'admin/AdminLoginScreen.dart';


class CategoryPreferenceScreen extends StatefulWidget {
  static String tag = '/CategoryPreferenceScreen';
  bool? isNewUser;
  CategoryPreferenceScreen({this.isNewUser});

  @override
  _CategoryPreferenceScreenState createState() => _CategoryPreferenceScreenState();
}

class _CategoryPreferenceScreenState extends State<CategoryPreferenceScreen> {
  late List<CategoryData> categories = [];

  List<CategoryData> selectedCategoriesList = [];
  List<CategoryData> existingSelectedCategoriesList = [];
  List<CategoryData> oldSelectedCategoriesList = [];


  @override
  void initState() {
    // TODO: implement initState
    fetchCategories();
    super.initState();
  }

  fetchCategories() async {
    appStore.setLoading(true);
    List<CategoryData> cats = await categoryService.categoriesFuture();
    // List<UserPreferenceCategory> preferences = await userPreferenceService.getPreferences();
    preferences = await userPreferenceService.getPreferences();

    /// Assigning existing interests
    preferences.forEach((element) {
      CategoryData temp = cats.firstWhere((cat) => cat.id == element.categoryId);
      existingSelectedCategoriesList.add(temp);
    });

    // if(existingSelectedCategoriesList.isNotEmpty){
    //   userPreferenceCategories.addAll(existingSelectedCategoriesList);
    //   print("userPreferenceCategories $userPreferenceCategories");
    //
    //   List<DocumentReference> t = categoryService.convertDataToReference(userPreferenceCategories);
    //   userPreferenceCategoriesDocs = t;
    //   print("userPreferenceCategoriesDocs $userPreferenceCategoriesDocs");
    // }

    oldSelectedCategoriesList.addAll(existingSelectedCategoriesList);
    selectedCategoriesList.addAll(existingSelectedCategoriesList);

    if(cats.length > 0){
      categories.addAll(cats);

      appCategories = [];
      appCategories.addAll(cats);
    }
    setState(() { });

    appStore.setLoading(false);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> submit() async {
    hideKeyboard(context);
    appStore.setLoading(true);
    List<UserPreferenceCategory> temp = [];
    selectedCategoriesList.forEach((element) {
      temp.add(UserPreferenceCategory(userId: appStore.userId, categoryId: element.id, categoryName: element.name));
    });

    bool categoriesUpdated = false;
    if(selectedCategoriesList.isEmpty && oldSelectedCategoriesList.isNotEmpty){
      categoriesUpdated = true;
    } else if(selectedCategoriesList.length < oldSelectedCategoriesList.length || selectedCategoriesList.length > oldSelectedCategoriesList.length){
      categoriesUpdated = true;
    } else {
      selectedCategoriesList.forEach((element) {
        if (!oldSelectedCategoriesList.contains(element)) {
          categoriesUpdated = true;
        }
      });
    }
    // print(selectedCategoriesList.length);
    // print(oldSelectedCategoriesList.length);
    // print(categoriesUpdated);


    if(categoriesUpdated) {
      await userPreferenceService.addPreferences(temp, temp).then((
          value) async {

        preferences.clear();
        preferences.addAll(temp);
        // Adding user categories to access it on other screens
        userPreferenceCategories.clear();
        userPreferenceCategories.addAll(selectedCategoriesList);
        userPreferenceCategoriesDocs.clear();
        List<DocumentReference> t = categoryService.convertDataToReference(userPreferenceCategories);
        userPreferenceCategoriesDocs = t;
        print("userPreferenceCategoriesDocs $userPreferenceCategoriesDocs");

        newsService.getNewsList().then((value) {

          newsDataDefault.clear();
          newsDataDefault.addAll(value);

          appStore.setLoading(false);
          // toast(languages.save);
          MyFeedScreen(news: value,
              name: languages.myFeed,
              isSplash: true,
              ind: 0).launch(
              context, isNewTask: true);
        });
      }).catchError((e) {
        appStore.setLoading(false);

        // log(e);
        toast(e.toString());
        toast(e.toString().splitAfter(']').trim());
      });
    } else {

      if(widget.isNewUser == true){
        appStore.setLoading(false);
        toast(languages.categorySelectionToContinue);
      } else if(newsDataDefault.isNotEmpty) {
        appStore.setLoading(false);
        MyFeedScreen(news: [...newsDataDefault],
            name: languages.myFeed,
            isSplash: true,
            // ind: getIntAsync(REDIRECT_INDEX)).launch(
            ind: 0).launch(
            context, isNewTask: true);
      } else {
        newsService.getNewsList().then((value) {
          newsDataDefault.clear();
          newsDataDefault.addAll(value);

          appStore.setLoading(false);
          // toast(languages.save);
          MyFeedScreen(news: value,
              name: languages.myFeed,
              isSplash: true,
              ind: 0).launch(
              context, isNewTask: true);
        }).catchError((e) {
          appStore.setLoading(false);

          log(e);
          toast(e.toString());
          toast(e.toString().splitAfter(']').trim());
        });
      }
    }

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: appBarWidget("Personalize News", elevation: 0, showBack: true,  systemUiOverlayStyle: SystemUiOverlayStyle.light,color: colorPrimary, textColor: Colors.white),

      body: SafeArea(
        child: Container(
          height: double.infinity,
          margin: EdgeInsets.only(top: 30),
          child: Stack(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 50,),
              MultiSelectChip(
                categories,
                existingSelectedCategoriesList,
                onSelectionChanged: (selectedList) {
                  setState(() {
                    selectedCategoriesList = selectedList;
                  });
                },
                // maxSelection: 2,
              ),
            Align(
                  alignment: Alignment.bottomCenter,
                    child:AppButton(
                      text: languages.submit,
                      textStyle: boldTextStyle(color: white),
                      color: colorPrimary,
                      onTap: () {
                        submit();
                      },
                      width: context.width(),
                    ),),
              Observer(builder: (_) => loader().visible(appStore.isLoading)),
            ],
          ),
        ),
      ),
    );
  }
}

class MultiSelectChip extends StatefulWidget {
  final List<CategoryData> choicesList;
  final Function(List<CategoryData>)? onSelectionChanged;
  final Function(List<CategoryData>)? onMaxSelected;
  final int? maxSelection;
  List<CategoryData> existingSelected;

  MultiSelectChip(this.choicesList, this.existingSelected, {this.onSelectionChanged, this.onMaxSelected, this.maxSelection});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  // String selectedChoice = "";
  List<CategoryData> selectedChoices = [];

  // List<CategoryData> temp = [
  //   CategoryData(id: '21212',name: 'sadasdasd',image: 'asdasdasdas'),
  //   CategoryData(id: '21212',name: 'sadasdasd',image: 'asdasdasdas'),
  //   CategoryData(id: '21212',name: 'sadasdasd',image: 'asdasdasdas'),
  //   CategoryData(id: '21212',name: 'sadasdasd',image: 'asdasdasdas'),
  //   CategoryData(id: '21212',name: 'sadasdasd',image: 'asdasdasdas'),
  //   CategoryData(id: '21212',name: 'sadasdasd',image: 'asdasdasdas'),
  //   CategoryData(id: '21212',name: 'sadasdasd',image: 'asdasdasdas'),
  //   CategoryData(id: '21212',name: 'sadasdasd',image: 'asdasdasdas'),
  //   CategoryData(id: '21212',name: 'sadasdasd',image: 'asdasdasdas'),
  // ];

  @override
  void initState() {
    selectedChoices = widget.existingSelected;
    // widget.choicesList.addAll(temp);
    super.initState();
  }

  _buildChoiceList() {
    if(selectedChoices.length <= 0 ){
      selectedChoices = widget.existingSelected;
    }
    List<Widget> choices = [];

    widget.choicesList.forEach((item) {

      choices.add(Container(
        padding: const EdgeInsets.symmetric(vertical: 4 , horizontal: 2),
        child: ChoiceChip(
          padding: EdgeInsets.all(8),
          backgroundColor: Colors.grey,
          selectedColor: colorPrimary,
          // labelPadding: EdgeInsets.all(8),
          label: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              cachedImage(item.image, width: 34, height: 34, fit: BoxFit.cover).cornerRadiusWithClipRRect(2),
              8.width,
              Text(item.name!, style: TextStyle(color: Colors.white),),
            ],
          ),

          selected: selectedChoices.contains(item),
          onSelected: (selected) {
            if(selectedChoices.length == (widget.maxSelection  ?? -1) && !selectedChoices.contains(item)) {
              widget.onMaxSelected?.call(selectedChoices);
            } else {
              setState(() {
                selectedChoices.contains(item)
                    ? selectedChoices.remove(item)
                    : selectedChoices.add(item);
                widget.onSelectionChanged?.call(selectedChoices);
              });
            }
          },
        ),
      ));
    });

    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: _buildChoiceList(),
      ),
    );
  }
}
