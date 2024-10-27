import 'dart:convert';
import 'package:flutter/material.dart';
import '../languages/AppLocalizations.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../main.dart';
import '../models/AudiencePollModel.dart';
import '../models/NewsData.dart';

part 'AppStore.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {
  @observable
  bool isLoggedIn = false;

  @observable
  bool isAdmin = false;

  @observable
  bool isTester = false;

  @observable
  bool isNotificationOn = true;

  @observable
  bool isDarkMode = true;

  @observable
  bool isLoading = false;

  @observable
  bool isUpDownHide = false;

  @observable
  int redirectIndex = 0;

  @observable
  String selectedLanguageCode = '';

  @observable
  String? userProfileImage = '';

  @observable
  bool isNetworkAvailable = false;

  @observable
  String? userFullName = '';

  @observable
  String? userEmail = '';

  @observable
  String? userId = '';

  @observable
  List<UserData> userDataList = [];

  @observable
  List<NewsData> notificationList = [];

  @observable
  bool? isUserInComment=false;

  @action
  Future<void> setNotificationList(List<NewsData> val) async {
    notificationList.clear();
    notificationList.addAll(val);
    await setValue(NOTIFICATION_LIST, jsonEncode(notificationList));
  }

  @action
  void setConnectionState(ConnectivityResult val) {
    isNetworkAvailable = val != ConnectivityResult.none;
  }

  @action
  void addNotificationData(NewsData val) {
    notificationList.add(val);
    setValue(NOTIFICATION_LIST, jsonEncode(notificationList));
  }

  @action
  void removeNotificationData(NewsData val) {
    notificationList.remove(val);
    setValue(NOTIFICATION_LIST, jsonEncode(notificationList));
  }

  @action
  void setUserProfile(String? image) {
    userProfileImage = image;
  }

  @action
  void setUserId(String? val) {
    userId = val;
  }

  @action
  void setUserEmail(String? email) {
    userEmail = email;
  }

  @action
  void setFullName(String? name) {
    userFullName = name;
  }

  @action
  Future<void> setLoggedIn(bool val) async {
    isLoggedIn = val;
    await setValue(IS_LOGGED_IN, val);
  }

  @action
  void setLoading(bool val, {String? toastMsg}) {
    isLoading = val;

    if (toastMsg != null) {
      log(toastMsg);
      toast(toastMsg);
    }
  }

  @action
  void setUpDownHide(bool val) {
    isUpDownHide = val;
  }

  @action
  void setAdmin(bool val) {
    isAdmin = val;
  }

  @action
  void setTester(bool val) {
    isTester = val;
  }

  @action
  void setRedirectIndex(int val) {
    redirectIndex = val;
    setValue(REDIRECT_INDEX, val);
  }

  @action
  void setNotification(bool val) {
    isNotificationOn = val;

    setValue(IS_NOTIFICATION_ON, val);

    if (isMobile) {
      OneSignal.shared.disablePush(!val);
    }
  }

  @action
  Future<void> setDarkMode(bool aIsDarkMode) async {
    isDarkMode = aIsDarkMode;

    if (isDarkMode) {
      textPrimaryColorGlobal = Colors.white;
      textSecondaryColorGlobal = textSecondaryColor;

      defaultLoaderBgColorGlobal = scaffoldSecondaryDark;
      appButtonBackgroundColorGlobal = appButtonColorDark;
      shadowColorGlobal = Colors.white12;
    } else {
      textPrimaryColorGlobal = textPrimaryColor;
      textSecondaryColorGlobal = textSecondaryColor;

      defaultLoaderBgColorGlobal = Colors.white;
      appButtonBackgroundColorGlobal = Colors.white;
      shadowColorGlobal = Colors.black12;
    }
  }

  @action
  Future<void> setLanguage(String aCode, {BuildContext? context}) async {
    selectedLanguageCode = aCode;
    selectedLanguageDataModel = getSelectedLanguageModel();
    language = localeLanguageList.firstWhere((element) => element.languageCode ==aCode);
    await setValue(SELECTED_LANGUAGE_CODE, selectedLanguageCode);

    languages = await AppLocalizations().load(Locale(selectedLanguageCode));
  }
}
