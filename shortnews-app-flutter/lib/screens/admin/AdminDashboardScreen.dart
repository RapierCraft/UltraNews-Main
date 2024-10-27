import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../models/ListModel.dart';
import '../../services/AuthService.dart';
import '../../utils/AppImages.dart';
import '../../utils/ModelKeys.dart';
import '../../utils/ResponsiveWidget.dart';
import '/../components/AppWidgets.dart';
import '/../main.dart';
import '/../screens/admin/components/AdminStatisticsWidget.dart';
import '/../utils/Colors.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'AdminLoginScreen.dart';
import 'UploadNewsScreen.dart';
import 'components/AllNewsListWidget.dart';
import 'components/IndependentNewsGridWidget.dart';
import 'CategoryListScreen.dart';
import 'UserListScreen.dart';
import 'AdminSettingScreen.dart';
import 'AdsConfigurationScreen.dart';
import 'components/SendNotificationWidget.dart';

class AdminDashboardScreen extends StatefulWidget {
  static String tag = '/AdminDashboardScreen';

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Widget currentWidget = AdminStatisticsWidget();
  bool? isHide = false;
  List<ListModel> list = [];
  bool? onHover = true;

  int index = 0;

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    list.clear();

    list.add(ListModel(onHover: false, name: languages.dashboard, widget: AdminStatisticsWidget(), leading: Icons.dashboard));
    list.add(ListModel(onHover: false, name: languages.uploadNews, widget: UploadNewsScreen(), leading: MaterialCommunityIcons.cloud_upload_outline));
    list.add(ListModel(onHover: false, name: languages.allNews, widget: AllNewsListWidget(), leading: MaterialCommunityIcons.newspaper));
    list.add(ListModel(onHover: false, name: languages.recentNews, widget: IndependentNewsGridWidget(newsType: NewsTypeRecent), leading: MaterialCommunityIcons.newspaper));
    list.add(ListModel(onHover: false, name: languages.breakingNews, widget: IndependentNewsGridWidget(newsType: NewsTypeBreaking), leading: MaterialCommunityIcons.newspaper));
    list.add(ListModel(onHover: false, name: languages.newsCategories, widget: CategoryListScreen(), leading: MaterialCommunityIcons.view_dashboard_outline));
    list.add(ListModel(onHover: false, name: languages.notifications, widget: SendNotificationWidget(), leading: AntDesign.bells));
    list.add(ListModel(onHover: false, name: languages.manageUser, widget: UserListScreen(), leading: FontAwesome.user_o));
    list.add(ListModel(onHover: false, name: languages.lblSetting, widget: AdminSettingScreen(), leading: Feather.settings));
    list.add(ListModel(onHover: false, name: languages.adsConfiguration, widget: AdsConfigurationScreen(), leading: Icons.ad_units));

    LiveStream().on(StreamSelectItem, (index) {
      this.index = index as int;
      currentWidget = list[index].widget.validate();
      setState(() {});
    });

    return Scaffold(
      body: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
              width: isHide == true || ResponsiveWidget.isSmallScreen(context) ? 72 : 240,
              height: context.height(),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: boxDecorationWithShadow(backgroundColor: colorPrimary),
                child: Column(
                  children: [
                    16.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        4.width,
                        Container(decoration: boxDecorationWithRoundedCorners(), child: Image.asset(ic_logo, height: 30)),
                        16.width,
                        ResponsiveWidget.isSmallScreen(context)?SizedBox():Text(appName, style: boldTextStyle(color: Colors.white), maxLines: 1).expand().visible(isHide == false),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: list.map((e) {
                              int cIndex = list.indexOf(e);
                              return InkWell(
                                focusColor: Colors.blue.withOpacity(0.3),
                                splashColor: Colors.blue.withOpacity(0.3),
                                onHover: (v) {
                                  setState(() {
                                    e.onHover = v;
                                  });
                                },
                                hoverColor: Colors.amber.withOpacity(0.3),
                                onTap: () {
                                  LiveStream().dispose(StreamSelectItem);
                                  index = list.indexOf(e);
                                  currentWidget = e.widget!;
                                  setState(() {});
                                },
                                child: Container(
                                  child: Row(
                                    children: [
                                      Icon(e.leading, color: Colors.white),
                                      8.width.visible(isHide == false ||ResponsiveWidget.isSmallScreen(context)),
                                      Text(e.name!, style: primaryTextStyle(size: isHide == true ||ResponsiveWidget.isSmallScreen(context)? 0 : 14, color: Colors.white, letterSpacing: 1)).expand().visible(isHide == false),
                                    ],
                                  ),
                                  padding: isHide == true ||ResponsiveWidget.isSmallScreen(context)? EdgeInsets.only(right: 0, left: 8, bottom: 8, top: 8) : EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: cIndex == index
                                          ? Colors.white.withOpacity(0.1)
                                          : e.onHover.validate()
                                              ? Colors.red
                                              : null,
                                      borderRadius: radius(8)),
                                ).paddingSymmetric(vertical: 4),
                              );
                            }).toList(),
                          ),
                        ).expand(),
                        Divider(thickness: 0.5, height: 0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: isHide == true ||ResponsiveWidget.isSmallScreen(context)? CrossAxisAlignment.start : CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                showConfirmDialogCustom(
                                  context,
                                  primaryColor: colorPrimary,
                                  title: languages.logoutConfirmation,
                                  positiveText: languages.yes,
                                  negativeText: languages.no,
                                  onAccept: (_) {
                                    logout(context, onLogout: () {
                                      AdminLoginScreen().launch(context, isNewTask: true);
                                    });
                                  },
                                );
                              },
                              child: Container(
                                child: Row(
                                  children: [
                                    Icon(Feather.log_out, color: Colors.white),
                                    8.width.visible(isHide == false),
                                    Text(languages.logout, style: primaryTextStyle(size: isHide == true ||ResponsiveWidget.isSmallScreen(context)? 0 : 14, color: Colors.white, letterSpacing: 1)).visible(isHide == false),
                                  ],
                                ),
                                padding: isHide == true ||ResponsiveWidget.isSmallScreen(context)? EdgeInsets.only(right: 0, left: 8, bottom: 8, top: 8) : EdgeInsets.all(8),
                              ).paddingSymmetric(vertical: 4),
                            ),
                            GestureDetector(
                              onTap: () {
                                isHide = !isHide!;
                                setState(() {});
                              },
                              child: Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(isHide == true ? AntDesign.doubleright : AntDesign.doubleleft, color: Colors.white, size: 18),
                                    8.width.visible(isHide == false),
                                    Text(languages.collapseMenu,style: primaryTextStyle(size: isHide == true ||ResponsiveWidget.isSmallScreen(context)? 0 : 14, color: Colors.white, letterSpacing: 1)).visible(isHide == false),
                                  ],
                                ),
                                padding: isHide == true ||ResponsiveWidget.isSmallScreen(context)? EdgeInsets.only(right: 0, left: 8, bottom: 8, top: 8) : EdgeInsets.all(8),
                              ),
                            ).paddingSymmetric(vertical: 6)
                          ],
                        )
                      ],
                    ).expand(),
                  ],
                ),
              )),
          Container(
            width: isHide == true||ResponsiveWidget.isSmallScreen(context) ? context.width() - 72 : context.width() - 240,
            height: context.height(),
            color: colorPrimary.withOpacity(0.1),
            child: Column(
              children: [
                Container(
                  alignment: isRTL ? Alignment.topLeft : Alignment.topRight,
                  height: 70,
                  color: colorPrimary,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Tooltip(
                        message: '',
                        child: FlutterSwitch(
                          value: appStore.isDarkMode,
                          width: 54,
                          height: 28,
                          toggleSize: 24,
                          borderRadius: 24.0,
                          padding: 4.0,
                          activeIcon: Icon(Icons.dark_mode),
                          inactiveIcon: Icon(Icons.light_mode, color: Colors.white),
                          activeColor: Colors.white.withOpacity(0.5),
                          activeToggleColor: Colors.black,
                          inactiveToggleColor: Colors.white24,
                          inactiveColor: Colors.white24,
                          onToggle: (value) {
                            appStore.isDarkMode != appStore.isDarkMode;
                            if (value) {
                              setValue(THEME_MODE_INDEX, 1);
                            } else {
                              setValue(THEME_MODE_INDEX, 0);
                            }
                            getIntAsync(THEME_MODE_INDEX);
                            appStore.setDarkMode(value);
                            setState(() {});
                          },
                        ),
                      ),
                      DropdownButton(
                        underline: SizedBox(),
                        elevation: 5,
                        dropdownColor: colorPrimary,
                        style: primaryTextStyle(color: Colors.white),
                        items: localeLanguageList
                            .map((e) => DropdownMenuItem<LanguageDataModel>(
                                child: Row(
                                  children: [
                                    Image.asset(e.flag!, height: 24),
                                    6.width,
                                    Text(e.name!, style: primaryTextStyle(size: 14, color: Colors.white)),
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
                      ).paddingAll(16),
                      Row(
                        children: [
                          appStore.userProfileImage!.isNotEmpty
                              ? cachedImage(appStore.userProfileImage, width: 34, height: 34, fit: BoxFit.cover).cornerRadiusWithClipRRect(20)
                              : Container(
                                  width: 34,
                                  height: 34,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white38),
                                  child: Text(appStore.userFullName!.split('').first, style: boldTextStyle(size: 14, color: colorPrimary)),
                                ),
                          16.width,
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(appStore.userFullName!, style: primaryTextStyle(size: 12, color: Colors.white), overflow: TextOverflow.ellipsis, maxLines: 1),
                              Text(appStore.userEmail!, style: primaryTextStyle(size: 10, color: Colors.white), overflow: TextOverflow.ellipsis, maxLines: 1),
                            ],
                          ),
                        ],
                      ),
                      16.width,
                    ],
                  ),
                ),
                currentWidget.expand(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
