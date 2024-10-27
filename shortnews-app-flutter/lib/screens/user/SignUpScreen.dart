import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_sort_news/screens/CategoryPreferenceScreen.dart';
import '../../models/UserModel.dart';
import '../../utils/AppImages.dart';
import '../../utils/Constants.dart';
import '/../screens/user/HomeFragment.dart';
import '/../services/AuthService.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import 'MyFeedScreen.dart';
import 'package:flutter/services.dart';


class SignUpScreen extends StatefulWidget {
  static String tag = '/RegisterScreen';
  final String? phoneNumber;
  final User? userModel;

  SignUpScreen({this.phoneNumber, this.userModel});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  bool passwordVisible = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
      passwordController.text = widget.phoneNumber!;
      confirmPasswordController.text = widget.phoneNumber!;
    }
  }

  signUp() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);

      appStore.setLoading(true);

      await signUpWithEmail(fullNameController.text.trim(), emailController.text.trim(), passwordController.text.trim()).then((value) {


        // CategoryPreferenceScreen().launch(context);

        newsService.getNewsList().then((value) {

          appStore.setLoading(false);

          newsDataDefault.clear();
          newsDataDefault.addAll(value);
          CategoryPreferenceScreen(isNewUser: true,).launch(context);

          // MyFeedScreen(news: value, name: languages.myFeed, isSplash: true, ind: getIntAsync(REDIRECT_INDEX)).launch(context, isNewTask: true);
        });
        // HomeFragment().launch(context, isNewTask: true);
      }).catchError((e) {
        toast(e.toString());

        appStore.setLoading(false);
      });
    }
  }

  void signUpWithOtp() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      appStore.setLoading(true);
      if (await userService.isUserExist(emailController.text, LoginTypeOTP)) {
        toast("user already register with email");
        appStore.setLoading(false);
      } else {
        UserModel userModel = UserModel();
        userModel.id = widget.userModel!.uid;
        userModel.email = emailController.text.validate();
        userModel.name = fullNameController.text.validate();
        userModel.image = '';
        userModel.mobileNumber = widget.phoneNumber;
        userModel.loginType = LoginTypeOTP;
        userModel.isNotificationOn = true;
        userModel.appLanguage = DefaultLanguage;
        userModel.themeIndex = 0;
        userModel.updatedAt = DateTime.now();
        userModel.createdAt = DateTime.now();

        userModel.isAdmin = false;
        userModel.isTester = false;
        userModel.isNotificationOn = true;

        userModel.oneSignalPlayerId = getStringAsync(PLAYER_ID);

        await userService.addDocumentWithCustomId(widget.userModel!.uid, userModel.toJson()).then((value) async {
          UserModel user = await value.get().then((value) => UserModel.fromJson(value.data() as Map<String, dynamic>));
          log('Signed up');
          await updateUserData(user);
          await setUserDetailPreference(user).whenComplete(() async {
            appStore.setLoading(false);
            await setValue(LOGIN_TYPE, LoginTypeOTP);

            CategoryPreferenceScreen(isNewUser: true,).launch(context);
            // HomeFragment().launch(context, isNewTask: true);
          });
        }).catchError((e) {
          throw e;
        }).whenComplete(() => appStore.setLoading(false));
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('', showBack: true, textColor: Colors.white, color: colorPrimary,systemUiOverlayStyle: SystemUiOverlayStyle.light, elevation: 0),
      body: Stack(
        children: [
          Container(
            color: colorPrimary,
            child: Column(
              children: [
                Container(decoration: boxDecorationWithRoundedCorners(borderRadius: radius(16)), child: Image.asset(ic_logo, height: 80).cornerRadiusWithClipRRect(16)),
                16.height,
                Visibility(
                  visible: widget.phoneNumber == null,
                    child: Text(languages.signUp, style: boldTextStyle(size: 22, color: Colors.white))
                ),
                Container(
                  decoration: boxDecorationWithShadow(backgroundColor: context.scaffoldBackgroundColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: radiusCircular(16))),
                  margin: EdgeInsets.only(top: 16),
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 30, top: 16, right: 16, left: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          16.height,
                          Text(languages.signUpText, style: boldTextStyle(size: 28)),
                          12.height,
                          Visibility(
                              visible: widget.phoneNumber == null,
                              child: Text(languages.singUpTextDec, style: secondaryTextStyle(size: 18, color: appStore.isDarkMode ? Colors.white54 : colorPrimary))
                          ),
                          Visibility(
                              visible: widget.phoneNumber != null,
                              child: Text(languages.singUpTextDecPhone, style: secondaryTextStyle(size: 18, color: appStore.isDarkMode ? Colors.white54 : colorPrimary))
                          ),
                          30.height,
                          AppTextField(
                            controller: fullNameController,
                            textFieldType: TextFieldType.NAME,
                            decoration: inputDecoration(labelText: languages.fullName),
                            nextFocus: emailFocus,
                            errorThisFieldRequired: languages.fieldRequired,
                            autoFillHints: [AutofillHints.name],
                          ).paddingBottom(16),
                          AppTextField(
                            controller: emailController,
                            focus: emailFocus,
                            textFieldType: TextFieldType.EMAIL,
                            decoration: inputDecoration(labelText: languages.email),
                            nextFocus: widget.phoneNumber != null ? null : passFocus,
                            errorThisFieldRequired: languages.fieldRequired,
                            errorInvalidEmail: languages.emailIsInvalid,
                            maxLines: 1,
                            cursorColor: colorPrimary,
                            autoFillHints: [AutofillHints.email],
                          ).paddingBottom(16),
                          AppTextField(
                            controller: passwordController,
                            textFieldType: TextFieldType.PASSWORD,
                            focus: passFocus,
                            nextFocus: confirmPasswordFocus,
                            errorThisFieldRequired: languages.fieldRequired,
                            decoration: inputDecoration(labelText: languages.password),
                            isValidationRequired: widget.phoneNumber == null,
                            autoFillHints: [AutofillHints.newPassword],
                          ).paddingBottom(16).visible(widget.phoneNumber == null),
                          AppTextField(
                            controller: confirmPasswordController,
                            textFieldType: TextFieldType.PASSWORD,
                            focus: confirmPasswordFocus,
                            errorThisFieldRequired: languages.fieldRequired,
                            decoration: inputDecoration(labelText: languages.confirmPassword),
                            onFieldSubmitted: (s) {
                              signUp();
                            },
                            validator: (value) {
                              if (value!.trim().isEmpty) return errorThisFieldRequired;
                              if (value.trim().length < passwordLengthGlobal) return languages.passwordLength;
                              return passwordController.text == value.trim() ? null : languages.passwordNotMatch;
                            },
                            isValidationRequired: widget.phoneNumber == null,
                            autoFillHints: [AutofillHints.newPassword],
                          ).visible(widget.phoneNumber == null),
                          30.height,
                          AppButton(
                            text: widget.phoneNumber != null ? languages.continueText : languages.signUp,
                            color: colorPrimary,
                            textStyle: boldTextStyle(color: white),
                            onTap: () {
                              if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty)
                                signUpWithOtp();
                              else
                                signUp();
                            },
                            width: context.width(),
                          ),
                          20.height,
                          if (widget.phoneNumber == null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(languages.member, style: primaryTextStyle()),
                                GestureDetector(
                                    child: Text(
                                      languages.login,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        decoration: TextDecoration.underline,
                                        color: appStore.isDarkMode ? Colors.white : colorPrimary,
                                      ),
                                    ).paddingLeft(4),
                                    onTap: () {
                                      finish(context);
                                    })
                              ],
                            ),
                        ],
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
