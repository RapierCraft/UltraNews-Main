// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AppStore on _AppStore, Store {
  late final _$isLoggedInAtom =
      Atom(name: '_AppStore.isLoggedIn', context: context);

  @override
  bool get isLoggedIn {
    _$isLoggedInAtom.reportRead();
    return super.isLoggedIn;
  }

  @override
  set isLoggedIn(bool value) {
    _$isLoggedInAtom.reportWrite(value, super.isLoggedIn, () {
      super.isLoggedIn = value;
    });
  }

  late final _$isAdminAtom = Atom(name: '_AppStore.isAdmin', context: context);

  @override
  bool get isAdmin {
    _$isAdminAtom.reportRead();
    return super.isAdmin;
  }

  @override
  set isAdmin(bool value) {
    _$isAdminAtom.reportWrite(value, super.isAdmin, () {
      super.isAdmin = value;
    });
  }

  late final _$isTesterAtom =
      Atom(name: '_AppStore.isTester', context: context);

  @override
  bool get isTester {
    _$isTesterAtom.reportRead();
    return super.isTester;
  }

  @override
  set isTester(bool value) {
    _$isTesterAtom.reportWrite(value, super.isTester, () {
      super.isTester = value;
    });
  }

  late final _$isNotificationOnAtom =
      Atom(name: '_AppStore.isNotificationOn', context: context);

  @override
  bool get isNotificationOn {
    _$isNotificationOnAtom.reportRead();
    return super.isNotificationOn;
  }

  @override
  set isNotificationOn(bool value) {
    _$isNotificationOnAtom.reportWrite(value, super.isNotificationOn, () {
      super.isNotificationOn = value;
    });
  }

  late final _$isDarkModeAtom =
      Atom(name: '_AppStore.isDarkMode', context: context);

  @override
  bool get isDarkMode {
    _$isDarkModeAtom.reportRead();
    return super.isDarkMode;
  }

  @override
  set isDarkMode(bool value) {
    _$isDarkModeAtom.reportWrite(value, super.isDarkMode, () {
      super.isDarkMode = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_AppStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$isUpDownHideAtom =
      Atom(name: '_AppStore.isUpDownHide', context: context);

  @override
  bool get isUpDownHide {
    _$isUpDownHideAtom.reportRead();
    return super.isUpDownHide;
  }

  @override
  set isUpDownHide(bool value) {
    _$isUpDownHideAtom.reportWrite(value, super.isUpDownHide, () {
      super.isUpDownHide = value;
    });
  }

  late final _$redirectIndexAtom =
      Atom(name: '_AppStore.redirectIndex', context: context);

  @override
  int get redirectIndex {
    _$redirectIndexAtom.reportRead();
    return super.redirectIndex;
  }

  @override
  set redirectIndex(int value) {
    _$redirectIndexAtom.reportWrite(value, super.redirectIndex, () {
      super.redirectIndex = value;
    });
  }

  late final _$selectedLanguageCodeAtom =
      Atom(name: '_AppStore.selectedLanguageCode', context: context);

  @override
  String get selectedLanguageCode {
    _$selectedLanguageCodeAtom.reportRead();
    return super.selectedLanguageCode;
  }

  @override
  set selectedLanguageCode(String value) {
    _$selectedLanguageCodeAtom.reportWrite(value, super.selectedLanguageCode,
        () {
      super.selectedLanguageCode = value;
    });
  }

  late final _$userProfileImageAtom =
      Atom(name: '_AppStore.userProfileImage', context: context);

  @override
  String? get userProfileImage {
    _$userProfileImageAtom.reportRead();
    return super.userProfileImage;
  }

  @override
  set userProfileImage(String? value) {
    _$userProfileImageAtom.reportWrite(value, super.userProfileImage, () {
      super.userProfileImage = value;
    });
  }

  late final _$isNetworkAvailableAtom =
      Atom(name: '_AppStore.isNetworkAvailable', context: context);

  @override
  bool get isNetworkAvailable {
    _$isNetworkAvailableAtom.reportRead();
    return super.isNetworkAvailable;
  }

  @override
  set isNetworkAvailable(bool value) {
    _$isNetworkAvailableAtom.reportWrite(value, super.isNetworkAvailable, () {
      super.isNetworkAvailable = value;
    });
  }

  late final _$userFullNameAtom =
      Atom(name: '_AppStore.userFullName', context: context);

  @override
  String? get userFullName {
    _$userFullNameAtom.reportRead();
    return super.userFullName;
  }

  @override
  set userFullName(String? value) {
    _$userFullNameAtom.reportWrite(value, super.userFullName, () {
      super.userFullName = value;
    });
  }

  late final _$userEmailAtom =
      Atom(name: '_AppStore.userEmail', context: context);

  @override
  String? get userEmail {
    _$userEmailAtom.reportRead();
    return super.userEmail;
  }

  @override
  set userEmail(String? value) {
    _$userEmailAtom.reportWrite(value, super.userEmail, () {
      super.userEmail = value;
    });
  }

  late final _$userIdAtom = Atom(name: '_AppStore.userId', context: context);

  @override
  String? get userId {
    _$userIdAtom.reportRead();
    return super.userId;
  }

  @override
  set userId(String? value) {
    _$userIdAtom.reportWrite(value, super.userId, () {
      super.userId = value;
    });
  }

  late final _$userDataListAtom =
      Atom(name: '_AppStore.userDataList', context: context);

  @override
  List<UserData> get userDataList {
    _$userDataListAtom.reportRead();
    return super.userDataList;
  }

  @override
  set userDataList(List<UserData> value) {
    _$userDataListAtom.reportWrite(value, super.userDataList, () {
      super.userDataList = value;
    });
  }

  late final _$notificationListAtom =
      Atom(name: '_AppStore.notificationList', context: context);

  @override
  List<NewsData> get notificationList {
    _$notificationListAtom.reportRead();
    return super.notificationList;
  }

  @override
  set notificationList(List<NewsData> value) {
    _$notificationListAtom.reportWrite(value, super.notificationList, () {
      super.notificationList = value;
    });
  }

  late final _$isUserInCommentAtom =
      Atom(name: '_AppStore.isUserInComment', context: context);

  @override
  bool? get isUserInComment {
    _$isUserInCommentAtom.reportRead();
    return super.isUserInComment;
  }

  @override
  set isUserInComment(bool? value) {
    _$isUserInCommentAtom.reportWrite(value, super.isUserInComment, () {
      super.isUserInComment = value;
    });
  }

  late final _$setNotificationListAsyncAction =
      AsyncAction('_AppStore.setNotificationList', context: context);

  @override
  Future<void> setNotificationList(List<NewsData> val) {
    return _$setNotificationListAsyncAction
        .run(() => super.setNotificationList(val));
  }

  late final _$setLoggedInAsyncAction =
      AsyncAction('_AppStore.setLoggedIn', context: context);

  @override
  Future<void> setLoggedIn(bool val) {
    return _$setLoggedInAsyncAction.run(() => super.setLoggedIn(val));
  }

  late final _$setDarkModeAsyncAction =
      AsyncAction('_AppStore.setDarkMode', context: context);

  @override
  Future<void> setDarkMode(bool aIsDarkMode) {
    return _$setDarkModeAsyncAction.run(() => super.setDarkMode(aIsDarkMode));
  }

  late final _$setLanguageAsyncAction =
      AsyncAction('_AppStore.setLanguage', context: context);

  @override
  Future<void> setLanguage(String aCode, {BuildContext? context}) {
    return _$setLanguageAsyncAction
        .run(() => super.setLanguage(aCode, context: context));
  }

  late final _$_AppStoreActionController =
      ActionController(name: '_AppStore', context: context);

  @override
  void setConnectionState(ConnectivityResult val) {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.setConnectionState');
    try {
      return super.setConnectionState(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addNotificationData(NewsData val) {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.addNotificationData');
    try {
      return super.addNotificationData(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeNotificationData(NewsData val) {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.removeNotificationData');
    try {
      return super.removeNotificationData(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserProfile(String? image) {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.setUserProfile');
    try {
      return super.setUserProfile(image);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserId(String? val) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setUserId');
    try {
      return super.setUserId(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserEmail(String? email) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setUserEmail');
    try {
      return super.setUserEmail(email);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFullName(String? name) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setFullName');
    try {
      return super.setFullName(name);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoading(bool val, {String? toastMsg}) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setLoading');
    try {
      return super.setLoading(val, toastMsg: toastMsg);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUpDownHide(bool val) {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.setUpDownHide');
    try {
      return super.setUpDownHide(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAdmin(bool val) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setAdmin');
    try {
      return super.setAdmin(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTester(bool val) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setTester');
    try {
      return super.setTester(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRedirectIndex(int val) {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.setRedirectIndex');
    try {
      return super.setRedirectIndex(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNotification(bool val) {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.setNotification');
    try {
      return super.setNotification(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoggedIn: ${isLoggedIn},
isAdmin: ${isAdmin},
isTester: ${isTester},
isNotificationOn: ${isNotificationOn},
isDarkMode: ${isDarkMode},
isLoading: ${isLoading},
isUpDownHide: ${isUpDownHide},
redirectIndex: ${redirectIndex},
selectedLanguageCode: ${selectedLanguageCode},
userProfileImage: ${userProfileImage},
isNetworkAvailable: ${isNetworkAvailable},
userFullName: ${userFullName},
userEmail: ${userEmail},
userId: ${userId},
userDataList: ${userDataList},
notificationList: ${notificationList},
isUserInComment: ${isUserInComment}
    ''';
  }
}
