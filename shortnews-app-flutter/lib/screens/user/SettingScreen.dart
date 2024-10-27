import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mighty_sort_news/screens/CategoryPreferenceScreen.dart';
import '/../utils/AppImages.dart';
import '/../components/AppWidgets.dart';
import '/../components/ThemeSelectionDialog.dart';
import '/../models/FontSizeModel.dart';
import '/../screens/user/HomeFragment.dart';
import '/../services/AuthService.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import '/../utils/ModelKeys.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share/share.dart';
import '../../main.dart';
import 'AboutAppScreen.dart';
import 'BookmarkNewsScreen.dart';
import 'ChangePasswordScreen.dart';
import 'EditProfileScreen.dart';
import 'SignInScreen.dart';

class SettingScreen extends StatefulWidget {
  static String tag = '/ProfileFragment';

  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) =>
          Scaffold(
            appBar: appBarWidget(languages.settings, elevation: 0, showBack: true,  systemUiOverlayStyle: SystemUiOverlayStyle.light,color: colorPrimary, textColor: Colors.white),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (appStore.isLoggedIn)
                    Column(
                      children: [
                        16.height,
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: boxDecorationWithShadow(boxShape: BoxShape.circle, backgroundColor: context.cardColor),
                              child: appStore.userProfileImage
                                  .validate()
                                  .isEmpty
                                  ? Image.asset(ic_profile, width: 100, height: 100).cornerRadiusWithClipRRect(50)
                                  : cachedImage(appStore.userProfileImage.validate(), usePlaceholderIfUrlEmpty: true, height: 100, width: 100, fit: BoxFit.cover).cornerRadiusWithClipRRect(50),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: boxDecorationWithShadow(boxShape: BoxShape.circle, backgroundColor: context.cardColor),
                                child: Icon(MaterialCommunityIcons.circle_edit_outline, color: context.iconColor, size: 20).onTap(() {
                                  EditProfileScreen().launch(context);
                                }),
                              ),
                            ),
                          ],
                        ),
                        8.height,
                        Text(appStore.userFullName.validate(), style: boldTextStyle()),
                        Text(appStore.userEmail.validate(), style: primaryTextStyle()).fit(),
                      ],
                    ).center(),
                  if (appStore.isLoggedIn) 16.height,
                  titleWidget(languages.appSettings),
                  if (appStore.isLoggedIn) 8.height,
                  if (appStore.isLoggedIn)
                    SettingItemWidget(
                      leading: Icon(Ionicons.bookmark_outline),
                      title: languages.bookmarks,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onTap: () {
                        if (appStore.isLoggedIn) {
                          BookmarkNewsScreen().launch(context);
                        } else {
                          SignInScreen().launch(context);
                        }
                      },
                    ),
                  if (appStore.isLoggedIn) 8.height,
                  if (appStore.isLoggedIn)
                    SettingItemWidget(
                      leading: Icon(Ionicons.heart_outline),
                      title: languages.personalizeNews,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onTap: () {
                        if (appStore.isLoggedIn) {
                          CategoryPreferenceScreen().launch(context);
                        } else {
                          SignInScreen().launch(context);
                        }
                      },
                    ),
                  if (appStore.isLoggedIn) 8.height,
                  SettingItemWidget(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Icon(Ionicons.key_outline),
                    title: languages.changePwd,
                    onTap: () {
                      ChangePasswordScreen().launch(context);
                    },
                  ).visible(appStore.isLoggedIn && isLoggedInWithApp()),
                  SettingItemWidget(
                    leading: Icon(Entypo.language),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    title: languages.language,
                    trailing: DropdownButton(
                      isDense: true,
                      underline: SizedBox(),
                      elevation: 5,
                      dropdownColor: Theme
                          .of(context)
                          .cardColor,
                      style: primaryTextStyle(color: Colors.white),
                      items: localeLanguageList
                          .map((e) =>
                          DropdownMenuItem<LanguageDataModel>(
                              child: Row(
                                children: [
                                  Image.asset(e.flag!, height: 24),
                                  6.width,
                                  Text(e.name!, style: primaryTextStyle(size: 14)),
                                ],
                              ),
                              value: e))
                          .toList(),
                      value: language,
                      onChanged: (LanguageDataModel? v) async {
                        hideKeyboard(context);
                        LiveStream().emit(StreamUpdateDrawer, v!.languageCode);
                        await appStore.setLanguage(v.languageCode!, context: context);

                        if (appStore.isLoggedIn) {
                          userService.updateDocument({UserKeys.appLanguage: v.languageCode}, appStore.userId);
                        }
                        await setValue(SELECTED_LANGUAGE_CODE, v.languageCode);
                        selectedLanguageDataModel = v;
                        appStore.setLanguage(v.languageCode!, context: context);
                        setState(() {});
                      },
                    ),
                  ),
                  SettingItemWidget(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: '${languages.selectTheme}',
                    leading: Icon(MaterialCommunityIcons.theme_light_dark),
                    onTap: () async {
                      await showInDialog(context, builder: (_) => ThemeSelectionDialog(), contentPadding: EdgeInsets.zero);
                      if (isIOS) {
                        HomeFragment().launch(context, isNewTask: true);
                      }
                    },
                  ),
                  8.height,
                  SettingItemWidget(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Icon(appStore.isNotificationOn ? Ionicons.notifications_outline : Ionicons.ios_notifications_off_outline),
                    title: languages.enablePushNotification,
                    trailing: CupertinoSwitch(
                      activeColor: colorPrimary,
                      value: appStore.isNotificationOn,
                      onChanged: (v) {
                        if (appStore.isLoggedIn) {
                          userService.updateDocument({UserKeys.isNotificationOn: v}, appStore.userId);
                        }

                        appStore.setNotification(v);
                      },
                    ).withHeight(10),
                    onTap: () {
                      appStore.setNotification(!getBoolAsync(IS_NOTIFICATION_ON, defaultValue: true));

                      if (appStore.isLoggedIn) {
                        userService.updateDocument({UserKeys.isNotificationOn: appStore.isNotificationOn}, appStore.userId);
                      }
                    },
                  ),
                  SettingItemWidget(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Icon(MaterialCommunityIcons.format_text),
                    title: languages.articleFontSize,
                    trailing: DropdownButton<FontSizeModel>(
                      items: fontSizes.map((e) {
                        return DropdownMenuItem<FontSizeModel>(child: Text('${e.title}', style: primaryTextStyle(size: 14)), value: e);
                      }).toList(),
                      dropdownColor: appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
                      value: fontSize,
                      underline: SizedBox(),
                      onChanged: (FontSizeModel? v) async {
                        hideKeyboard(context);

                        await setValue(FONT_SIZE_PREF, v!.fontSize);

                        fontSize = fontSizes.firstWhere((element) => element.fontSize == getIntAsync(FONT_SIZE_PREF, defaultValue: 16));

                        setState(() {});
                      },
                    ),
                    onTap: () {
                      //
                    },
                  ),
                  titleWidget(languages.other),
                  8.height,
                  SettingItemWidget(
                    leading: Icon(Ionicons.share_social_outline),
                    title: '${languages.share} $appName',
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    onTap: () {
                      PackageInfo.fromPlatform().then((value) {
                        String package = '';
                        if (isAndroid) package = value.packageName;

                        Share.share('${languages.share} $mAppName\n\n${storeBaseURL()}$package');
                      });
                    },
                  ),
                  SettingItemWidget(
                    leading: Icon(SimpleLineIcons.star),
                    title: languages.rateUs,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    onTap: () {
                      PackageInfo.fromPlatform().then((value) {
                        String package = '';
                        if (isAndroid) package = value.packageName;
                        launchUrlWidget('${storeBaseURL()}$package');
                      });
                    },
                  ),
                  SettingItemWidget(
                    leading: Icon(AntDesign.appstore_o),
                    title: languages.moreApps,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    onTap: () {
                      launchUrlWidget(mMoreAppsLink, forceWebView: false);
                    },
                  ),
                  SettingItemWidget(
                    leading: Icon(AntDesign.filetext1),
                    title: languages.termCondition,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    onTap: () {
                      launchUrlWidget(getStringAsync(TERMS_AND_CONDITION_PREF), forceWebView: true);
                    },
                  ),
                  SettingItemWidget(
                    leading: Icon(AntDesign.filetext1),
                    title: languages.privacyPolicy,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    onTap: () {
                      launchUrlWidget(getStringAsync(PRIVACY_POLICY_PREF), forceWebView: true);
                    },
                  ),
                  SettingItemWidget(
                    leading: Icon(Feather.info),
                    title: languages.about,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    onTap: () {
                      AboutAppScreen().launch(context);
                    },
                  ),
                  // SettingItemWidget(
                  //   leading: Icon(MaterialCommunityIcons.login),
                  //   title: languages.login,
                  //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  //   onTap: () async {
                  //     SignInScreen().launch(context);
                  //   },
                  // ).visible(!appStore.isLoggedIn),
                  SettingItemWidget(
                    leading: Icon(MaterialCommunityIcons.login),
                    title: languages.logout,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    onTap: () async {
                      showConfirmDialogCustom(
                        context,
                        primaryColor: colorPrimary,
                        title: languages.logoutConfirmation,
                        positiveText: languages.yes,
                        negativeText: languages.no,
                        onAccept: (_) {
                          print(getStringAsync(USER_EMAIL).toString());
                          logout(context, onLogout: () {
                            SignInScreen().launch(context, isNewTask: true);
                            // HomeFragment().launch(context, isNewTask: true);
                          });
                        },
                      );
                    },
                  ).visible(appStore.isLoggedIn),
                  SettingItemWidget(
                    title: languages.deleteAccount,
                    titleTextStyle: boldTextStyle(color: Colors.red),
                    leading: Icon(AntDesign.delete, color: Colors.red),
                    onTap: () {
                      showConfirmDialogCustom(
                        context,
                        primaryColor: colorPrimary,
                        title:  languages.deleteUser,
                        positiveText: languages.yes,
                        negativeText: languages.no,
                        onAccept: (_) {
                          userService.removeDocument(appStore.userId).then((value) {
                            deleteUser(getStringAsync(USER_EMAIL), getStringAsync(PASSWORD));
                            appStore.setLoggedIn(false);
                            setState(() {});
                          }).catchError((e) {
                            toast(e.toString());
                          });
                        },
                      );
                    },
                  ).visible(appStore.isLoggedIn && !appStore.isTester),
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (_, snap) {
                      if (snap.hasData) {
                        return Center(child: Text('${languages.version} ${snap.data!.version.validate()}', style: secondaryTextStyle(), textAlign: TextAlign.center).paddingLeft(16));
                      }
                      return SizedBox();
                    },
                  ),
                  16.height,
                ],
              ),
            ),
          ),
    );
  }
}
