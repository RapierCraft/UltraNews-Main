import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mighty_sort_news/store/AppStore.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../screens/user/HomeFragment.dart';
import '../screens/user/MyFeedScreen.dart';
import '../utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';
import '../screens/user/SignUpScreen.dart';
import '../services/AuthService.dart';
import '../utils/Common.dart';

import '../utils/Constants.dart';

class OTPDialog extends StatefulWidget {
  static String tag = '/OTPDialog';
  final String? verificationId;
  final String? phoneNumber;
  final bool? isCodeSent;
  final PhoneAuthCredential? credential;

  OTPDialog(
      {this.verificationId,
      this.isCodeSent,
      this.phoneNumber,
      this.credential});

  @override
  OTPDialogState createState() => OTPDialogState();
}

class OTPDialogState extends State<OTPDialog> {
  TextEditingController numberController = TextEditingController();
  String? countryCode = '';
  String otpCode = '';

  TextEditingController textEditingController = TextEditingController();

  // ..text = "123456";

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();


  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> submit() async {
    formKey.currentState!.validate();
    if (currentText.length != 6 || !currentText.isDigit()) {
      errorController!
          .add(ErrorAnimationType.shake); // Triggering error shake animation
      setState(() => hasError = true);
    } else {
      setState(
        () {
          hasError = false;
          // snackBar("OTP Verified!!");
        },
      );
      print("currentText: $currentText");

      otpCode = currentText;
      appStore.setLoading(true);
      setState(() {});
      try {
        AuthCredential credential = PhoneAuthProvider.credential(
            verificationId: widget.verificationId!,
            smsCode: otpCode.validate());

        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((result) async {
          User currentUser = result.user!;

          await userService
              .userByMobileNumber(currentUser.phoneNumber)
              .then((user) async {
            await setValue(LOGIN_TYPE, LoginTypeOTP);
            await updateUserData(user);
            await setUserDetailPreference(user).whenComplete(() async {
              // appStore.setLoading(false);
              // HomeFragment().launch(context, isNewTask: true);

              await newsService.getNewsList().then((value) {
                newsDataDefault.clear();
                newsDataDefault.addAll(value);
                appStore.setLoading(false);

                if(value.isNotEmpty){
                  MyFeedScreen(news: value,
                      name: languages.myFeed,
                      isSplash: true,
                      ind: 0).launch(
                      context, isNewTask: true);
                } else {
                  appStore.setLoading(false);

                  HomeFragment().launch(context, isNewTask: true);
                }
              });



              // if(newsData.isNotEmpty){
              //   MyFeedScreen(news: newsData,
              //       name: languages.myFeed,
              //       isSplash: true,
              //       ind: 0).launch(
              //       context, isNewTask: true);
              // } else {
              //   HomeFragment().launch(context, isNewTask: true);
              // }
            });
          }).catchError((e) {
            log(e);
            if (e.toString() == 'EXCEPTION_NO_USER_FOUND') {
              appStore.setLoading(false);
              SignUpScreen(
                      userModel: currentUser,
                      phoneNumber: currentUser.phoneNumber)
                  .launch(context)
                  .then((value) {
                appStore.setLoading(false);
              });
            } else {
              throw e;
            }
          });
        });
      } on FirebaseAuthException catch (e) {
        log(e);
        toast(e.message.toString());
        appStore.setLoading(false);
      } catch (e) {
        log(e);
        toast(e.toString());
        appStore.setLoading(false);
      }
      setState(() {});
    }
    // print(appStore.isLoading);
  }

  Future<void> sendOTP() async {
    if (numberController.text.trim().isEmpty) {
      return toast(errorThisFieldRequired);
    }
    appStore.setLoading(true);
    setState(() {});

    // print(appStore.isLoading);
    String number = '+$countryCode${numberController.text.trim()}';
    if (!number.startsWith('+')) {
      number = '+$countryCode${numberController.text.trim()}';
    }

    // await Future.delayed(Duration(seconds: 3));

    await auth.verifyPhoneNumber(
      phoneNumber: number,
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: (FirebaseAuthException e) {
        appStore.setLoading(false);
        setState(() {});
        if (e.code == 'invalid-phone-number') {
          toast('The provided phone number is not valid.');
          throw 'The provided phone number is not valid.';
        } else {
          toast(e.message.toString());
          throw e.toString();
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        appStore.setLoading(false);
        setState(() {});
        finish(context);
        await showDialog(
            context: context,
            builder: (context) => OTPDialog(
                verificationId: verificationId,
                isCodeSent: true,
                phoneNumber: number),
            barrierDismissible: false);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        appStore.setLoading(false);
        setState(() {});
      },
    );

    // await loginWithOTP(context, number).then((value) {
    //   print("sss");
    // }).catchError((e) {
    //   toast(e.toString());
    //
    // });

    setState(() {});
  }


  showAlertDialog(BuildContext context, String code) {

    // set up the button
    Widget okButton = TextButton(
      child: Text(languages.continueText),
      onPressed: () {
        textEditingController.text = code;
        finish(context);
      },
    );

    Widget cancelButton = TextButton(
      child: Text(languages.cancel),
      onPressed: () {
        finish(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(languages.pasteCode, style: boldTextStyle(size: 18),),
      content: Text("${languages.pasteCodeDesc}: $code?", style: TextStyle(color: Colors.white),),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: radius(defaultRadius)),
      child: Container(
        width: context.width(),
        child: !widget.isCodeSent.validate()
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(languages.msgOtpLogin,
                              style: boldTextStyle(size: 18))
                          .paddingOnly(left: 16, top: 16),
                      IconButton(
                          onPressed: () {
                            finish(context);
                          },
                          icon: Icon(Icons.close_sharp))
                    ],
                  ),
                  30.height,
                  Container(
                    height: 100,
                    child: Row(
                      children: [
                        CountryCodePicker(
                          initialSelection: 'IN',
                          showCountryOnly: false,
                          showFlag: false,
                          boxDecoration: BoxDecoration(
                              borderRadius: radius(defaultRadius),
                              color: context.scaffoldBackgroundColor),
                          showFlagDialog: true,
                          searchStyle: TextStyle(
                              color: appStore.isDarkMode
                                  ? Colors.white
                                  : Colors.black),
                          searchDecoration: new InputDecoration(
                            prefixIconColor: appStore.isDarkMode
                                ? Colors.white
                                : Colors.grey,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : Colors.grey,
                                  width: 1.0),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : Colors.grey,
                                  width: 1.0),
                            ),
                          ),
                          dialogTextStyle: TextStyle(
                              color: appStore.isDarkMode
                                  ? Colors.white
                                  : Colors.black),
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                          textStyle: primaryTextStyle(),
                          onInit: (c) {
                            countryCode = c!.dialCode;
                          },
                          onChanged: (c) {
                            countryCode = c.dialCode;
                          },
                        ),
                        AppTextField(
                          controller: numberController,
                          textFieldType: TextFieldType.PHONE,
                          decoration:
                              inputDecoration(labelText: "Mobile number"),
                          autoFocus: true,
                          onFieldSubmitted: (s) {
                            sendOTP();
                          },
                        ).expand(),
                      ],
                    ),
                  ).paddingOnly(left: 16, right: 16),
                  16.height,
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AppButton(
                        onTap: () {
                          sendOTP();
                        },
                        text: "Send OTP",
                        color: appStore.isDarkMode
                            ? scaffoldDarkColor
                            : colorPrimary,
                        textStyle: boldTextStyle(color: Colors.white),
                        width: context.width(),
                      ),
                      loader().visible(appStore.isLoading),
                    ],
                  ).paddingOnly(left: 16, right: 16, bottom: 16)
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Enter Received OTP", style: boldTextStyle()),
                      IconButton(
                          onPressed: () {
                            finish(context);
                          },
                          icon: Icon(Icons.close_sharp))
                    ],
                  ),
                  30.height,
                  Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 0,
                      ),
                      child: PinCodeTextField(
                        textStyle: TextStyle(color: Colors.white, fontSize: 16),
                        appContext: context,
                        pastedTextStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        length: 6,
                        obscureText: false,
                        obscuringCharacter: '*',
                        blinkWhenObscuring: false,
                        animationType: AnimationType.fade,
                        validator: (v) {
                          return null;
                          if (v!.length < 3) {
                            return "Insert valid OTP";
                          } else {
                            return null;
                          }
                        },
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          inactiveFillColor: Colors.transparent,
                          activeColor: Colors.white,
                          selectedColor: Colors.white,
                          activeFillColor: Colors.transparent,
                          inactiveColor: Colors.white,
                          selectedFillColor: Colors.transparent,
                        ),
                        cursorColor: Colors.black,
                        animationDuration: const Duration(milliseconds: 300),
                        enableActiveFill: true,
                        errorAnimationController: errorController,
                        controller: textEditingController,
                        keyboardType: TextInputType.number,
                        boxShadows: const [
                          BoxShadow(
                            offset: Offset(0, 1),
                            color: Colors.black12,
                            blurRadius: 10,
                          )
                        ],
                        onCompleted: (v) {
                          submit();
                          // debugPrint("Completed");
                        },
                        dialogConfig: DialogConfig(
                          affirmativeText: languages.continueText,
                          dialogContent: languages.pasteCodeDesc,
                          dialogTitle: languages.pasteCode,
                          negativeText: languages.cancel,
                          platform: PinCodePlatform.other,
                        ),
                        // onTap: () {
                        //   print("Pressed");
                        // },
                        onChanged: (value) {
                          debugPrint(value);
                          setState(() {
                            currentText = value;
                          });
                        },
                        beforeTextPaste: (text) {
                          text = text ?? '';
                          if(text.trim() == ''){
                            // toast("No data to paste");
                          } else {
                            showAlertDialog(context, text);
                            // debugPrint("Allowing to paste $text");
                            // textEditingController.text = text;
                          }



                          return false;
                          //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                          //but you can show anything you want here, like your pop up saying wrong paste format or etc
                          // return true;

                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      hasError ? "*${languages.validFields}" : "",
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  // OTPTextField(
                  //   pinLength: 6,
                  //   fieldWidth: 30,
                  //   onChanged: (s) {
                  //     otpCode = s;
                  //   },
                  //   onCompleted: (pin) {
                  //     otpCode = pin;
                  //     submit();
                  //   },
                  // ),
                  30.height,
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AppButton(
                        onTap: () {
                          submit();
                        },
                        text: languages.confirm,
                        color: appStore.isDarkMode
                            ? scaffoldDarkColor
                            : colorPrimary,
                        textStyle: boldTextStyle(color: Colors.white),
                        width: context.width(),
                        shapeBorder: RoundedRectangleBorder(
                            borderRadius: radius(defaultRadius)),
                      ),
                      loader().visible(appStore.isLoading),
                    ],
                  )
                ],
              ).paddingAll(16),
      ),
    );
  }
}
