import 'package:flutter/material.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../utils/ModelKeys.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class ThemeSelectionDialog extends StatefulWidget {
  static String tag = '/ThemeSelectionDialog';

  @override
  ThemeSelectionDialogState createState() => ThemeSelectionDialogState();
}

class ThemeSelectionDialogState extends State<ThemeSelectionDialog> {
  List<String> themeModeList = ['Dark','Light', 'System default'];

  int? currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    currentIndex = getIntAsync(THEME_MODE_INDEX);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.topLeft,
            decoration: boxDecorationWithShadow(backgroundColor: colorPrimary, borderRadius: BorderRadius.only(topRight: Radius.circular(8), topLeft: Radius.circular(8))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(languages.selectTheme, style: boldTextStyle(size: 20, color: Colors.white)).paddingLeft(12),
                CloseButton(color: Colors.white),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 8, bottom: 8, top: 8),
            itemCount: themeModeList.length,
            itemBuilder: (BuildContext context, int index) {
              return RadioListTile(
                value: index,
                dense: true,
                contentPadding: EdgeInsets.zero,
                groupValue: currentIndex,
                activeColor: colorPrimary,
                title: Text(themeModeList[index], style: primaryTextStyle()),
                onChanged: (dynamic val) {
                  setState(() {
                    currentIndex = val;
                    if (val == ThemeModeSystem) {
                      appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.dark);
                    } else if (val == ThemeModeLight) {
                      appStore.setDarkMode(false);
                    } else if (val == ThemeModeDark) {
                      appStore.setDarkMode(true);
                    }
                    setValue(THEME_MODE_INDEX, val);
                  });
                  if (appStore.isLoggedIn) {
                    userService.updateDocument({UserKeys.themeIndex: val}, appStore.userId);
                  }

                  finish(context);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
