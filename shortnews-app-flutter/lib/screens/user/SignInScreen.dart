import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_sort_news/screens/CategoryPreferenceScreen.dart';
import '../../utils/AppImages.dart';
import '/../components/ForgotPasswordDialog.dart';
import '/../components/SocialLoginWidget.dart';
import '/../screens/user/HomeFragment.dart';
import '/../services/AuthService.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import '../../main.dart';
import 'MyFeedScreen.dart';
import 'SignUpScreen.dart';
import 'package:flutter/services.dart';


class SignInScreen extends StatefulWidget {
  static String tag = '/LoginScreen';

  final bool? isNewTask;

  SignInScreen({this.isNewTask});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FocusNode passFocus = FocusNode();
  FocusNode emailFocus = FocusNode();

  bool passwordVisible = false;

  bool isRemembered = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (!getBoolAsync(IS_SOCIAL_LOGIN) && getStringAsync(LOGIN_TYPE) != LoginTypeOTP && getBoolAsync(IS_REMEMBERED)==true) {
      emailController.text = getStringAsync(USER_EMAIL);
      passwordController.text = getStringAsync(PASSWORD);
    }
    if (Platform.isIOS) {
      TheAppleSignIn.onCredentialRevoked!.listen((_) {
        log("Credentials revoked");
      });
    }
    setState(() {});
  }

  Future<void> signIn() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setLoading(true);

      await signInWithEmail(emailController.text, passwordController.text).then((user) {
        if (user != null) {
          newsService.getNewsList().then((value) {
            newsDataDefault.clear();
            newsDataDefault.addAll(value);

            // MyFeedScreen(news: value, name: languages.myFeed, isSplash:true, ind: getIntAsync(REDIRECT_INDEX)).launch(context, isNewTask: true);
            MyFeedScreen(news: value, name: languages.myFeed, isSplash:true, ind: 0).launch(context, isNewTask: true);
          });
          // if (widget.isNewTask.validate()) {
          //   newsService.getNewsList().then((value) {
          //     MyFeedScreen(news: value, name: languages.myFeed, isSplash: true, ind: getIntAsync(REDIRECT_INDEX)).launch(context, isNewTask: true);
          //   });
          //   // HomeFragment().launch(context, isNewTask: true);
          // } else {
          //   finish(context, true);
          // }
        }
      }).catchError((e) {
        log(e);
        toast(e.toString());
        toast(e.toString().splitAfter(']').trim());
      });

      appStore.setLoading(false);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('', showBack: false, textColor: Colors.white, color: colorPrimary, systemUiOverlayStyle: SystemUiOverlayStyle.light,elevation: 0),
      body: Stack(
        children: [
          Container(
            color: colorPrimary,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(decoration: boxDecorationWithRoundedCorners(borderRadius: radius(16)), child: Image.asset(ic_logo, height: 80).cornerRadiusWithClipRRect(16)),
                16.height,
                Text(languages.login, style: boldTextStyle(size: 28, color: Colors.white), textAlign: TextAlign.center),
                Container(
                  decoration: boxDecorationWithShadow(backgroundColor: context.scaffoldBackgroundColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: radiusCircular(16))),
                  margin: EdgeInsets.only(top: 16),
                  child: AutofillGroup(
                    child: Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: <Widget>[
                            16.height,
                            Text(languages.signInText, style: boldTextStyle(size: 28)),
                            12.height,
                            Text(languages.singInTextDec, style: secondaryTextStyle(size: 18, color: appStore.isDarkMode ? Colors.white54 : colorPrimary)),
                            30.height,
                            AppTextField(
                              controller: emailController,
                              textFieldType: TextFieldType.EMAIL,
                              decoration: inputDecoration(labelText: languages.email),
                              nextFocus: passFocus,
                              errorThisFieldRequired: languages.fieldRequired,
                              errorInvalidEmail: languages.emailIsInvalid,
                              autoFillHints: [AutofillHints.email],
                            ),
                            16.height,
                            AppTextField(
                              controller: passwordController,
                              textFieldType: TextFieldType.PASSWORD,
                              focus: passFocus,
                              errorThisFieldRequired: languages.fieldRequired,
                              decoration: inputDecoration(labelText: languages.password),
                              autoFillHints: [AutofillHints.password],
                              onFieldSubmitted: (s) {
                                signIn();
                              },
                            ),
                            8.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      activeColor: colorPrimary,
                                      value: getBoolAsync(IS_REMEMBERED, defaultValue: true),
                                      onChanged: (v) async {
                                        await setValue(IS_REMEMBERED, v);
                                        setState(() {});
                                      },
                                    ),
                                    Text(languages.rememberMe, style: primaryTextStyle()).onTap(() async {
                                      await setValue(IS_REMEMBERED, !getBoolAsync(IS_REMEMBERED));
                                      setState(() {});
                                    }).expand(),
                                  ],
                                ).expand(),

                              ],
                            ),
                            8.height,
                            AppButton(
                              text: languages.login,
                              textStyle: boldTextStyle(color: white),
                              color: colorPrimary,
                              onTap: () {
                                signIn();
                              },
                              width: context.width(),
                            ),
                            16.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(languages.notMember, style: primaryTextStyle()),
                                GestureDetector(
                                    child: Text(
                                      languages.signUp,
                                      style: TextStyle(fontSize: 18.0, decoration: TextDecoration.underline, color: appStore.isDarkMode ? Colors.white : colorPrimary),
                                    ).paddingLeft(4),
                                    onTap: () {
                                      SignUpScreen().launch(context);
                                    })
                              ],
                            ),
                            5.height,
                            Text(languages.forgotPwd, style: primaryTextStyle()).paddingAll(8).onTap(() async {
                              hideKeyboard(context);
                              await showInDialog(context, builder: (_) => ForgotPasswordDialog());
                            }),
                            20.height,

                            Row(
                              children: [
                                16.width,
                                Container(
                                  width: 100,
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [colorPrimary.withOpacity(0.2), colorPrimary],
                                    ),
                                  ),
                                ).expand(),
                                16.width,
                                Text(languages.continueWith, style: secondaryTextStyle()),
                                16.width,
                                Container(
                                  width: 100,
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colorPrimary,
                                        colorPrimary.withOpacity(0.2),
                                      ],
                                    ),
                                  ),
                                ).expand(),
                                16.width,
                              ],
                            ),

                            20.height,
                            SocialLoginWidget(voidCallback: () async {
                              if(getBoolAsync(GOOGLE_LOGIN_NEW)){
                                setValue(GOOGLE_LOGIN_NEW, false);
                                appStore.setLoading(true);
                                newsService.getNewsList().then((value) {
                                  appStore.setLoading(false);

                                  newsDataDefault.clear();
                                  newsDataDefault.addAll(value);
                                  CategoryPreferenceScreen(isNewUser: true,).launch(context, isNewTask: true);

                                  // MyFeedScreen(news: value, name: languages.myFeed, isSplash: true, ind: getIntAsync(REDIRECT_INDEX)).launch(context, isNewTask: true);
                                });

                                // CategoryPreferenceScreen().launch(context, isNewTask: true);
                              } else {
                                setValue(GOOGLE_LOGIN_NEW, false);

                                await newsService.getNewsList().then((value) {

                                  newsDataDefault.clear();
                                  newsDataDefault.addAll(value);
                                  MyFeedScreen(news: value, name: languages.myFeed, isSplash:true, ind: 0).launch(context, isNewTask: true);

                                  // MyFeedScreen(news: value, name: languages.myFeed, isSplash: true, ind: getIntAsync(REDIRECT_INDEX)).launch(context, isNewTask: true);
                                });
                                // appStore.setLoading(true);
                                // print("Is logged in ${appStore.userId}");
                                // print("Is logged in ${appStore.isLoggedIn}");
                                // await newsService.getNewsList().then((value) {
                                //   print("Is logged in ${value}");
                                //   appStore.setLoading(false);
                                //   print(value);
                                //   if(value.isNotEmpty){
                                //     MyFeedScreen(news: value,
                                //         name: languages.myFeed,
                                //         isSplash: true,
                                //         ind: 0).launch(
                                //         context, isNewTask: true);
                                //   } else {
                                //     HomeFragment().launch(context, isNewTask: true);
                                //   }
                                // });

                                // if(newsData.isNotEmpty){
                                //   MyFeedScreen(news: newsData,
                                //       name: languages.myFeed,
                                //       isSplash: true,
                                //       ind: 0).launch(
                                //       context, isNewTask: true);
                                // } else {
                                //   HomeFragment().launch(context, isNewTask: true);
                                // }

                                // HomeFragment().launch(context, isNewTask: true);
                              }
                            }),
                            // languageselectionWidget(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).expand(),
              ],
            ),
          ),
          Observer(builder: (_) => loader().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
