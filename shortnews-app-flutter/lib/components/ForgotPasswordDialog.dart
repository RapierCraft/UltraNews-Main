import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../main.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

class ForgotPasswordDialog extends StatefulWidget {
  static String tag = '/ForgotPasswordDialog';

  @override
  _ForgotPasswordDialogState createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  TextEditingController emailCont = TextEditingController();

  Future<void> submit() async {
    if (emailCont.text.trim().isEmpty) return toast(errorThisFieldRequired);

    if (!emailCont.text.trim().validateEmail()) return toast(languages.emailIsInvalid);

    hideKeyboard(context);
    appStore.setLoading(true);

    if (await userService.isUserExist(emailCont.text, LoginTypeApp)) {
      ///
      await auth.sendPasswordResetEmail(email: emailCont.text).then((value) {
        toast('Reset email has been sent to ${emailCont.text}');

        finish(context);
      }).catchError((e) {
        toast(e.toString());
      });

      ///
      appStore.setLoading(false);
    } else {
      toast('No User Found');
    }
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(languages.forgotPwd, style: boldTextStyle()),
              CloseButton(),
            ],
          ),
          8.height,
          AppTextField(
            controller: emailCont,
            textFieldType: TextFieldType.EMAIL,
            decoration: inputDecoration(labelText: languages.email),
            textStyle: primaryTextStyle(),
            autoFocus: true,
          ),
          30.height,
          Stack(
            alignment: Alignment.center,
            children: [
              AppButton(
                text: languages.save,
                color: appStore.isDarkMode ? scaffoldSecondaryDark : colorPrimary,
                textStyle: boldTextStyle(color: white),
                onTap: () {
                  submit();
                },
                width: context.width(),
              ),
              Observer(builder: (_) => loader().visible(appStore.isLoading)),
            ],
          ),
        ],
      ),
    );
  }
}
