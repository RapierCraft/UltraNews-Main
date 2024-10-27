import 'package:flutter/material.dart';

abstract class BaseLanguage {
  static BaseLanguage? of(BuildContext context) => Localizations.of<BaseLanguage>(context, BaseLanguage);

  String get unpublished;

  String get published;

  String get newsBy;

  String get fullName;

  String get rateUs;

  String get share;

  String get minRead;

  String get flutterWebBuildVersion;

  String get sendNotificationAllUsers;

  String get users;

  String get preview;

  String get sendNotification;

  String get allowComments;

  String get status;

  String get contentHtml;

  String get type;

  String get shortContent;

  String get sourceUrl;

  String get selectCategory;

  String get commentRequired;

  String get addCategory;

  String get contactInfo;

  String get disableAdMob;

  String get successSaved;

  String get notAllowed;

  String get send;

  String get media;

  String get deleteUser;

  String get deleteCategory;

  String get deletePost;

  String get delete;

  String get urlInvalid;

  String get imageUrl;

  String get image;

  String get name;

  String get comingSoon;

  String get upload;

  String get manageUser;

  String get notifications;

  String get newsCategories;

  String get allNews;

  String get uploadNews;

  String get dashboard;

  String get totalUsers;

  String get totalCategories;

  String get totalNews;

  String get startTyping;

  String get searchNews;

  String get readMore;

  String get oldPwdNotSameNew;

  String get oldPwdIncorrect;

  String get purchase;

  String get contact;

  String get passwordLength;

  String get passwordNotMatch;

  String get language;

  String get enablePushNotification;

  String get chooseArticleSize;

  String get categories;

  String get category;

  String get about;

  String get selectTheme;

  String get rememberMe;

  String get sendOtp;

  String get emailIsInvalid;

  String get comments;

  String get comment;

  String get variant;

  String get confirm;

  String get validOTP;

  String get validFields;

  String get articleFontSize;

  String get relatedNews;

  String get appName;

  String get title;

  String get walkTitle1;

  String get walkTitle2;

  String get walkTitle3;

  String get walkSubTitle1;

  String get walkSubTitle2;

  String get walkSubTitle3;

  String get skip;

  String get next;

  String get finish;

  String get loginTitle;

  String get login;

  String get forgotPwd;

  String get email;

  String get password;

  String get signUpTitle;

  String get firstName;

  String get lastName;

  String get username;

  String get confirmPwd;

  String get signUp;

  String get breakingNews;

  String get recentNews;

  String get chooseTopics;

  String get suggestForYou;

  String get searchHintText;

  String get changePwd;

  String get myTopics;

  String get termCondition;

  String get helpSupport;

  String get logout;

  String get version;

  String get emailValidation;

  String get passwordValidation;

  String get fieldRequired;

  String get bookmarks;

  String get logoutConfirmation;

  String get news;

  String get confirmPassword;

  String get submit;

  String get newPassword;

  String get editProfile;

  String get changeAvatar;

  String get save;

  String get privacyPolicy;

  String get confirmPwdValidation;

  String get noData;

  String get writeHere;

  String get post;

  String get writeComment;

  String get viewAll;

  String get pushNotification;

  String get exitApp;

  String get notification;

  String get darkMode;

  String get yes;

  String get no;

  String get appSettings;

  String get other;

  String get discover;

  String get myFeed;

  String get description;

  String get url;

  String get createInterstitialAds;

  String get createBannerAds;

  String get interstitialAdPreview;

  String get bannerAdPreview;

  String get admobIdForAndroid;

  String get admobBannerIdForAndroid;

  String get admobInterstitialIdForAndroid;

  String get admobIdForIOS;

  String get admobBannerIdForIos;

  String get admobInterstitialIdForIos;

  String get selectAdsType;

  String get adsConfiguration;

  String get moreApps;

  String get exitMsg;

  String get swipeUp;

  String get featuredImageUrl;

  String get swipeLeft;

  String get swipeRight;

  String get lblSetting;

  String get lblTrendingNews;

  String get signInText;

  String get singInTextDec;

  String get signUpText;

  String get singUpTextDec;

  String get singUpTextDecPhone;

  String get notMember;

  String get signGoogle;

  String get signPhone;

  String get signApple;

  String get continueWith;

  String get continueText;

  String get collapseMenu;

  String get searchHere;

  String get settings;

  String get member;

  String get trendingNews;

  String get appSetting;

  String get mostViewedNews;

  String get recentLogin;

  String get msgOtpLogin;

  String get deleteAccount;

  String get removed;

  String get personalizeNews;

  String get pasteCode;

  String get pasteCodeDesc;

  String get cancel;

  String get unableToFetchNews;

  String get categorySelectionToContinue;
}
