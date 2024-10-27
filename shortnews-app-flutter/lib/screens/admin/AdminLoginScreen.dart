import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../utils/AppImages.dart';
import '/../utils/Constants.dart';
import '/../screens/admin/AdminDashboardScreen.dart';
import '/../services/AuthService.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';

class AdminLoginScreen extends StatefulWidget {
  static String tag = '/AdminLoginScreen';

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FocusNode passFocus = FocusNode();
  FocusNode emailFocus = FocusNode();

  bool passwordVisible = false;

  //
  // TextEditingController emailSignUpController = TextEditingController();
  // TextEditingController passwordSignUpController = TextEditingController();
  //
  // FocusNode passSignUpFocus = FocusNode();
  // FocusNode emailSignUpFocus = FocusNode();

  TextEditingController fullNameController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FocusNode confirmPasswordFocus = FocusNode();

  bool? isSignUp = false;

  Future<void> signIn() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setLoading(true);

      signInWithEmail(emailController.text, passwordController.text).then((user) {
        appStore.setLoading(false);

        if (user != null) {
          // log(user.toJson());

          if (user.isAdmin.validate()) {
            AdminDashboardScreen().launch(context, isNewTask: true);
          } else {
            logout(context);
            toast(languages.notAllowed);
          }
        }
      }).catchError((e) {
        appStore.setLoading(false, toastMsg: e.toString());
      });
    }
  }

  // signUp() async {
  //   if (formKey.currentState!.validate()) {
  //     formKey.currentState!.save();
  //     hideKeyboard(context);
  //
  //     appStore.setLoading(true);
  //
  //     await signUpWithEmail(fullNameController.text.trim(), emailSignUpController.text.trim(), passwordSignUpController.text.trim(), isAdmin: true).then((value) {
  //       appStore.setLoading(false);
  //
  //       AdminDashboardScreen().launch(context, isNewTask: true);
  //     }).catchError((e) {
  //       toast(e.toString());
  //
  //       appStore.setLoading(false);
  //     });
  //
  //     /*createUser(request).then((res) async {
  //       if (!mounted) return;
  //
  //       Map req = {'username': widget.phoneNumber ?? emailController.text, 'password': widget.phoneNumber ?? passwordController.text};
  //
  //       await login(req).then((value) async {
  //         appStore.setLoading(false);
  //
  //         if (widget.phoneNumber != null) await setValue(LOGIN_TYPE, LoginTypeOTP);
  //
  //         UserDashboardScreen().launch(context, isNewTask: true);
  //       }).catchError((e) {
  //         appStore.setLoading(false);
  //       });
  //     }).catchError((error) {
  //       appStore.setLoading(false);
  //       toast(error.toString());
  //     });*/
  //   }
  // }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? context.scaffoldBackgroundColor : colorPrimary.withOpacity(0.1),
      body: Container(
        alignment: Alignment.center,
        width: context.width() * 0.6,
        height: context.height() * 0.65,
        decoration: boxDecorationRoundedWithShadow(16, backgroundColor: context.cardColor),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: context.width() * 0.3,
                  padding: EdgeInsets.all(16),
                  decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), topLeft: Radius.circular(16)), backgroundColor: colorPrimary),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(decoration: boxDecorationWithRoundedCorners(borderRadius: radius(16)), child: Image.asset(ic_logo, height: 100)),
                      16.height,
                      Text('Welcome To $appName', style: boldTextStyle(color: Colors.white, size: 20), textAlign: TextAlign.start),
                      16.height,
                      Text(mAboutApp, style: secondaryTextStyle(color: Colors.white), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                30.width,
                signInWidget()
              ],
            ),
            Observer(builder: (_) => loader().visible(appStore.isLoading)),
          ],
        ),
      ).center(),
    );
  }

  // Widget signUpWidget() {
  //   return SizedBox(
  //     width: context.width() * 0.25,
  //     child: Form(
  //       key: formKey,
  //       autovalidateMode: AutovalidateMode.onUserInteraction,
  //       child: SingleChildScrollView(
  //         padding: EdgeInsets.all(16),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: <Widget>[
  //             Text(languages.signUp, style: boldTextStyle(size: 22)),
  //             20.height,
  //             AppTextField(
  //               controller: fullNameController,
  //               textFieldType: TextFieldType.NAME,
  //               decoration: inputDecoration(labelText: languages.fullName),
  //               nextFocus: emailSignUpFocus,
  //               autoFillHints: [AutofillHints.name],
  //             ).paddingBottom(20),
  //             AppTextField(
  //               controller: emailSignUpController,
  //               focus: emailFocus,
  //               textFieldType: TextFieldType.EMAIL,
  //               decoration: inputDecoration(labelText: languages.email),
  //               nextFocus: passSignUpFocus,
  //               errorThisFieldRequired: languages.fieldRequired,
  //               errorInvalidEmail: languages.emailIsInvalid,
  //               maxLines: 1,
  //               cursorColor: colorPrimary,
  //               autoFillHints: [AutofillHints.email],
  //             ).paddingBottom(16),
  //             AppTextField(
  //               controller: passwordSignUpController,
  //               textFieldType: TextFieldType.PASSWORD,
  //               focus: passFocus,
  //               nextFocus: confirmPasswordFocus,
  //               decoration: inputDecoration(labelText: languages.password),
  //               autoFillHints: [AutofillHints.newPassword],
  //             ).paddingBottom(16),
  //             AppTextField(
  //               controller: confirmPasswordController,
  //               textFieldType: TextFieldType.PASSWORD,
  //               focus: confirmPasswordFocus,
  //               decoration: inputDecoration(labelText: languages.confirmPassword),
  //               onFieldSubmitted: (s) {
  //                 signUp();
  //               },
  //               validator: (value) {
  //                 if (value!.trim().isEmpty) return errorThisFieldRequired;
  //                 if (value.trim().length < passwordLengthGlobal) return languages.passwordLength;
  //                 return passwordController.text == value.trim() ? null : languages.passwordNotMatch;
  //               },
  //               autoFillHints: [AutofillHints.newPassword],
  //             ),
  //             30.height,
  //             AppButton(
  //               text: languages.signUp,
  //               color: appStore.isDarkMode ? scaffoldSecondaryDark : colorPrimary,
  //               textStyle: boldTextStyle(color: white),
  //               onTap: () {
  //                 signUp();
  //               },
  //               width: context.width(),
  //             ),
  //             8.height,
  //             AppButton(
  //               text: languages.login,
  //               textStyle: boldTextStyle(color: textPrimaryColorGlobal),
  //               color: appStore.isDarkMode ? scaffoldSecondaryDark : white,
  //               onTap: () {
  //                 isSignUp = false;
  //                 setState(() {});
  //               },
  //               width: context.width(),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget signInWidget() {
    return SizedBox(
      width: context.width() * 0.25,
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(languages.login, style: boldTextStyle(size: 22)),
              50.height,
              AppTextField(
                controller: emailController,
                textFieldType: TextFieldType.EMAIL,
                decoration: inputDecoration(labelText: languages.email),
                nextFocus: passFocus,
                autoFocus: true,
              ),
              8.height,
              AppTextField(
                controller: passwordController,
                textFieldType: TextFieldType.PASSWORD,
                focus: passFocus,
                decoration: inputDecoration(labelText: languages.password),
                onFieldSubmitted: (s) {
                  signIn();
                },
              ),
              30.height,
              AppButton(
                text: languages.login,
                textStyle: boldTextStyle(color: Colors.white),
                width: context.width() * 0.25,
                color: colorPrimary,
                onTap: () {
                  signIn();
                },
              ),
              16.height,
              // AppButton(
              //   text: languages.signUp,
              //   textStyle: boldTextStyle(color: textPrimaryColorGlobal),
              //   color: appStore.isDarkMode ? scaffoldSecondaryDark : white,
              //   onTap: () {
              //     isSignUp = true;
              //     setState(() {});
              //   },
              //   width: context.width(),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
