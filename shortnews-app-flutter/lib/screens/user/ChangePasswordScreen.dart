import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '/../services/AuthService.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter/services.dart';


import '../../main.dart';

class ChangePasswordScreen extends StatefulWidget {
  static String tag = '/ChangePasswordScreen';

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  var formKey = GlobalKey<FormState>();

  var oldPassCont = TextEditingController();
  var newPassCont = TextEditingController();
  var confNewPassCont = TextEditingController();

  var newPassFocus = FocusNode();
  var confPassFocus = FocusNode();

  bool oldPasswordVisible = false;
  bool newPasswordVisible = false;
  bool confPasswordVisible = false;

  Future<void> submit() async {
    if (appStore.isTester) return toast(mTesterNotAllowedMsg);
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      appStore.setLoading(true);

      await changePassword(newPassCont.text.trim()).then((value) async {
        finish(context);
        toast('Password successfully changed');
      }).catchError((e) {
        toast(e.toString());
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
      appBar: appBarWidget(languages.changePwd, showBack: true, elevation: 5, color: colorPrimary,systemUiOverlayStyle: SystemUiOverlayStyle.light, textColor: Colors.white),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    AppTextField(
                      controller: oldPassCont,
                      textFieldType: TextFieldType.PASSWORD,
                      decoration: inputDecoration(labelText: languages.password),
                      nextFocus: newPassFocus,
                      textStyle: primaryTextStyle(),
                      autoFillHints: [AutofillHints.password],
                      validator: (s) {
                        if (s!.isEmpty) return errorThisFieldRequired;
                        if (s != getStringAsync(PASSWORD)) return languages.oldPwdIncorrect;

                        return null;
                      },
                    ),
                    16.height,
                    AppTextField(
                      controller: newPassCont,
                      textFieldType: TextFieldType.PASSWORD,
                      decoration: inputDecoration(labelText: languages.newPassword),
                      focus: newPassFocus,
                      nextFocus: confPassFocus,
                      textStyle: primaryTextStyle(),
                      autoFillHints: [AutofillHints.newPassword],
                    ),
                    16.height,
                    AppTextField(
                      controller: confNewPassCont,
                      textFieldType: TextFieldType.PASSWORD,
                      decoration: inputDecoration(labelText: languages.confirmPassword),
                      focus: confPassFocus,
                      validator: (String? value) {
                        if (value!.isEmpty) return errorThisFieldRequired;
                        if (value.length < passwordLengthGlobal) return languages.passwordLength;
                        if (value.trim() != newPassCont.text.trim()) return languages.confirmPwdValidation;
                        if (value.trim() == oldPassCont.text.trim()) return languages.oldPwdNotSameNew;

                        return null;
                      },
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (s) {
                        submit();
                      },
                      textStyle: primaryTextStyle(),
                      autoFillHints: [AutofillHints.newPassword],
                    ),
                    30.height,
                    AppButton(
                      onTap: () {
                        submit();
                      },
                      text: languages.save,
                      width: context.width(),
                      color: colorPrimary,
                      textStyle: boldTextStyle(color: white),
                    ),
                  ],
                ),
              ),
            ),
            Observer(builder: (_) => loader().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
