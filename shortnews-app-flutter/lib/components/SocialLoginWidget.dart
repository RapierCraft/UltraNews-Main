import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../utils/Colors.dart';
import '../services/AuthService.dart';
import '../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'OTPLoginComponent.dart';

class SocialLoginWidget extends StatelessWidget {
  static String tag = '/SocialLoginWidget';
  final VoidCallback? voidCallback;

  SocialLoginWidget({this.voidCallback});

  @override
  Widget build(BuildContext context) {
    if (!EnableSocialLogin) return SizedBox();
    Widget socialWidget({bool? isMobile = false, String? text, Function? onCall, Widget? img}) {
      return GestureDetector(
        onTap: () {
          onCall!.call();
        },
        child: Container(
          height: 45,
          margin: EdgeInsets.symmetric(vertical: 8),
          width: context.width(),
          alignment: Alignment.center,
          padding: EdgeInsets.all(10),
          decoration: boxDecorationWithRoundedCorners(backgroundColor: appStore.isDarkMode ? Colors.white10 : colorPrimary.withOpacity(0.1), borderRadius: radius(defaultRadius)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              img!,
              6.width,
              Text(text!, style: boldTextStyle(), maxLines: 1),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        socialWidget(
            text: languages.signGoogle,
            isMobile: false,
            img: GoogleLogoWidget(size: 18),
            onCall: () async {
              hideKeyboard(context);

              appStore.setLoading(true);

              await signInWithGoogle().then((user) {
                appStore.setLoading(false);

                voidCallback?.call();
              }).catchError((e) {
                appStore.setLoading(false, toastMsg: e.toString());
              });
            }),
        socialWidget(
            text: languages.signPhone,
            isMobile: false,
            img: Icon(Feather.phone, color: appStore.isDarkMode ? Colors.white : colorPrimary),
            onCall: () async {
              hideKeyboard(context);
              await showDialog(context: context, builder: (context) => OTPDialog(), barrierDismissible: false).catchError((e) {
                toast(e.toString());
              });
            }),
        socialWidget(
            text: languages.signApple,
            isMobile: false,
            img: Icon(AntDesign.apple1, color: appStore.isDarkMode ? Colors.white : colorPrimary),
            onCall: () async {
              hideKeyboard(context);
              appStore.setLoading(true);

              await appleLogIn().then((value) {
                voidCallback?.call();
              }).catchError((e) {
                toast(e.toString());
              });
              appStore.setLoading(false);
            }).visible(isIOS),
      ],
    );
  }
}
