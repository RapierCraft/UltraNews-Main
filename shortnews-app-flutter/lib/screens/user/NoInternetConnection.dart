import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/AppImages.dart';
import '../../utils/Colors.dart';

class NoInternetConnection extends StatefulWidget {
  static String tag = '/NoInternetConnection';

  @override
  NoInternetConnectionState createState() => NoInternetConnectionState();
}

class NoInternetConnectionState extends State<NoInternetConnection> {

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(ic_noInternet, height: 150, width: 150, fit: BoxFit.cover, color: colorPrimary),
            30.height,
            Text("No Internet", style: boldTextStyle(size: 24)),
            8.height,
           // Text(appLocalization.translate('lbl_internet_msg'), style: secondaryTextStyle(size: 16), textAlign: TextAlign.center).paddingOnly(left: 16, right: 16),
          ],
        ),
      ),
    );
  }
}
