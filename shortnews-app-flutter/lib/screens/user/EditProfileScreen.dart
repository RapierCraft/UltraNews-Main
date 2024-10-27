import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/AppImages.dart';
import '/../components/AppWidgets.dart';
import '/../services/FileStorageService.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter/services.dart';

import '../../main.dart';

class EditProfileScreen extends StatefulWidget {
  static String tag = '/EditProfileScreen';

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  bool passwordVisible = false;

  bool isLoading = false;

  XFile? image;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    log(appStore.userProfileImage);
    fullNameController.text = getStringAsync(FULL_NAME);
    emailController.text = getStringAsync(USER_EMAIL);
  }

  Future save() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);

      isLoading = true;
      setState(() {});

      Map<String, dynamic> req = {};

      if (fullNameController.text != getStringAsync(FULL_NAME)) {
        req.putIfAbsent('name', () => fullNameController.text.trim());
      }

      if (image != null) {
        await uploadFile(file: File(image!.path), prefix: 'userProfiles').then((path) async {
          req.putIfAbsent('image', () => path);

          await setValue(PROFILE_IMAGE, path);
          appStore.setUserProfile(path);
        }).catchError((e) {
          toast(e.toString());
        });
      }

      await userService.updateDocument(req, appStore.userId).then((value) async {
        isLoading = false;
        appStore.setFullName(fullNameController.text);
        setValue(FULL_NAME, fullNameController.text);

        finish(context);
      });
    }
  }

  Future getImage() async {
    if (!isLoggedInWithGoogle() && !isLoggedInWithApple()) {
      image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
      setState(() {});
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    Widget profileImage() {
      if (image != null) {
        return Image.file(File(image!.path), height: 130, width: 130, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(65);
      } else {
        if (getStringAsync(LOGIN_TYPE) == LoginTypeGoogle || getStringAsync(LOGIN_TYPE) == LoginTypeApp || getStringAsync(LOGIN_TYPE) == LoginTypeApple) {
          if (appStore.userProfileImage != null && appStore.userProfileImage!.isNotEmpty)
            return cachedImage(appStore.userProfileImage, height: 130, width: 130, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(65);
          else
            return Image.asset(ic_profile, width: 130, height: 130).cornerRadiusWithClipRRect(38).cornerRadiusWithClipRRect(65);
        } else {
          return Image.asset(ic_profile, width: 130, height: 130).cornerRadiusWithClipRRect(38).cornerRadiusWithClipRRect(65);
        }
      }
    }

    return Scaffold(
      appBar: appBarWidget(languages.editProfile, showBack: true, color: colorPrimary,systemUiOverlayStyle: SystemUiOverlayStyle.light, textColor: Colors.white),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        profileImage(),
                        Text(languages.changeAvatar, style: boldTextStyle()).paddingTop(8).visible(!isLoggedInWithGoogle() && !isLoggedInWithApple()),
                      ],
                    ).paddingOnly(top: 16, bottom: 16),
                  ).onTap(() {
                    getImage();
                  }, highlightColor: Colors.transparent, splashColor: Colors.transparent, hoverColor: Colors.transparent),
                  16.height,
                  AppTextField(
                    controller: fullNameController,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(labelText:
                    languages.fullName),
                    textStyle: isLoggedInWithApp() ? primaryTextStyle() : secondaryTextStyle(),
                    enabled: isLoggedInWithApp() || isLoggedInWithOTP(),
                  ),
                  16.height,
                  AppTextField(
                    controller: emailController,
                    textFieldType: TextFieldType.EMAIL,
                    decoration: inputDecoration(labelText:languages.email),
                    textStyle: secondaryTextStyle(),
                    enabled: false,
                  ),
                  30.height,
                  AppButton(
                    text: languages.save,
                    color: colorPrimary,
                    textStyle: boldTextStyle(color: white),
                    enabled: isLoggedInWithApp() || isLoggedInWithOTP(),
                    onTap: () {
                      save();
                    },
                    width: context.width(),
                  ).visible(isLoggedInWithApp()|| isLoggedInWithOTP()),
                ],
              ),
            ),
          ),
          loader().center().visible(isLoading),
        ],
      ),
    );
  }
}
