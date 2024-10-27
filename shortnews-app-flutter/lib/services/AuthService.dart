import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../components/OTPLoginComponent.dart';
import '../models/UserModel.dart';
import '../utils/Constants.dart';
import '../utils/ModelKeys.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../main.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

Future<void> signInWithGoogle() async {
  GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

  if (googleSignInAccount != null) {
    //region Google Sign In
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult = await auth.signInWithCredential(credential);
    final User user = authResult.user!;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = auth.currentUser!;
    assert(user.uid == currentUser.uid);

    signOutGoogle();
    //endregion

    await loginFromFirebaseUser(user, LoginTypeGoogle);
  } else {
    throw errorSomethingWentWrong;
  }
}

Future<UserModel> signInWithEmail(String email, String password) async {
  if (await userService.isUserExist(email, LoginTypeApp)) {
    UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);

    if (userCredential != null && userCredential.user != null) {
      UserModel userModel = UserModel();

      User user = userCredential.user!;

      return await userService.userByEmail(user.email).then((value) async {
        log('Signed in');

        userModel = value;

        await setValue(PASSWORD, password);
        await setValue(LOGIN_TYPE, LoginTypeApp);
        //
        await updateUserData(userModel);
        //
        await setUserDetailPreference(userModel);

        return userModel;
      }).catchError((e) {
        throw e;
      });
    } else {
      throw errorSomethingWentWrong;
    }
  } else {
    throw 'You are not registered with us';
  }
}

Future<void> signUpWithEmail(String name, String email, String password, {bool? isAdmin = false}) async {
  UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);

  if (userCredential != null && userCredential.user != null) {
    User currentUser = userCredential.user!;
    UserModel userModel = UserModel();

    /// Create user
    userModel.id = currentUser.uid;
    userModel.email = currentUser.email;
    userModel.name = name;
    userModel.image = '';
    userModel.loginType = LoginTypeApp;
    userModel.isNotificationOn = true;
    userModel.appLanguage = DefaultLanguage;
    userModel.themeIndex = 0;
    userModel.updatedAt = DateTime.now();
    userModel.createdAt = DateTime.now();

    userModel.isAdmin = isAdmin;
    userModel.isTester = false;
    userModel.isNotificationOn = true;

    userModel.oneSignalPlayerId = getStringAsync(PLAYER_ID);

    await userService.addDocumentWithCustomId(currentUser.uid, userModel.toJson()).then((value) async {
      log('Signed up');
      await signInWithEmail(email, password).then((value) {
//
      });
    }).catchError((e) {
      throw e;
    });
  } else {
    throw errorSomethingWentWrong;
  }
}

Future<void> changePassword(newPassword) async {
  await FirebaseAuth.instance.currentUser!.updatePassword(newPassword).then((value) async {
    FirebaseAuth.instance.authStateChanges();
    await setValue(PASSWORD, newPassword);
  }).catchError((e) {
    log(e);
  });
}

Future<void> setUserDetailPreference(UserModel userModel) async {
  await setValue(USER_ID, userModel.id);
  await setValue(FULL_NAME, userModel.name);
  await setValue(USER_EMAIL, userModel.email);
  await setValue(PROFILE_IMAGE, userModel.image.validate());
  await setValue(IS_ADMIN, userModel.isAdmin.validate());
  await setValue(IS_TESTER, userModel.isTester.validate());
  if (userModel.bookmarks != null) await setValue(BOOKMARKS, jsonEncode(userModel.bookmarks));

  await setBookmarkList();
  postViewedList.clear();

  appStore.setLoggedIn(true);
  appStore.setUserId(userModel.id);
  appStore.setFullName(userModel.name);
  appStore.setUserEmail(userModel.email);
  appStore.setUserProfile(userModel.image);

  appStore.setAdmin(userModel.isAdmin.validate());
  appStore.setTester(userModel.isTester.validate());
}

Future<void> setBookmarkList() async {
  if (getStringAsync(BOOKMARKS).isNotEmpty) {
    Iterable? it = jsonDecode(getStringAsync(BOOKMARKS));

    if (it != null && it.isNotEmpty) {
      bookmarkList.clear();
      bookmarkList.addAll(it.map((e) => e.toString()).toList());
    }
  }
}

Future<void> updateUserData(UserModel user) async {
  //
  /// Update user data
  userService.updateDocument({
    UserKeys.oneSignalPlayerId: getStringAsync(PLAYER_ID),
    CommonKeys.updatedAt: DateTime.now(),
    UserKeys.isNotificationOn: user.isNotificationOn.validate(value: true),
  }, user.id);

  await setValue(THEME_MODE_INDEX, user.themeIndex.validate());

  appStore.setNotification(user.isNotificationOn.validate(value: true));

}

Future<void> logout(BuildContext context, {Function? onLogout}) async {
  await removeKey(IS_LOGGED_IN);
  await removeKey(IS_ADMIN);
  await removeKey(USER_ID);
  await removeKey(FULL_NAME);
  // await removeKey(USER_EMAIL);
  await removeKey(USER_ROLE);
  // await removeKey(PASSWORD);
  await removeKey(PROFILE_IMAGE);
  await removeKey(IS_NOTIFICATION_ON);
  // await removeKey(IS_REMEMBERED);
  await removeKey(LANGUAGE);
  await removeKey(PLAYER_ID);
  await removeKey(IS_SOCIAL_LOGIN);
  await removeKey(LOGIN_TYPE);
  await removeKey(POST_VIEWED_LIST);
  await removeKey(BOOKMARKS);

  bookmarkList.clear();
  postViewedList.clear();

  if (getBoolAsync(IS_SOCIAL_LOGIN) || getStringAsync(LOGIN_TYPE) == LoginTypeOTP || getBoolAsync(IS_REMEMBERED)==false) {
    await removeKey(PASSWORD);
    await removeKey(USER_EMAIL);
  }

  appStore.setLoggedIn(false);
  appStore.setUserId('');
  appStore.setFullName('');
  appStore.setUserEmail('');
  appStore.setUserProfile('');

  onLogout?.call();
}

Future<void> signOutGoogle() async {
  await googleSignIn.signOut();
}

Future<void> loginWithOTP(BuildContext context, String phoneNumber) async {
  await auth.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) async {},
    verificationFailed: (FirebaseAuthException e) {
      if (e.code == 'invalid-phone-number') {
        toast('The provided phone number is not valid.');
        throw 'The provided phone number is not valid.';
      } else {
        toast(e.message.toString());
        throw e.toString();
      }
    },
    codeSent: (String verificationId, int? resendToken) async {
      finish(context);
      await showDialog(context: context, builder: (context) => OTPDialog(verificationId: verificationId, isCodeSent: true, phoneNumber: phoneNumber), barrierDismissible: false);
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      //
    },
  );
}

/// Sign-In with Apple.
Future<void> appleLogIn() async {
  if (await TheAppleSignIn.isAvailable()) {
    AuthorizationResult result = await TheAppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential!;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken!),
          accessToken: String.fromCharCodes(appleIdCredential.authorizationCode!),
        );
        final authResult = await auth.signInWithCredential(credential);
        final user = authResult.user!;

        if (result.credential!.email != null) {
          await saveAppleData(result);
        }

        await loginFromFirebaseUser(
          user,
          LoginTypeApple,
          fullName: '${getStringAsync('appleGivenName')} ${getStringAsync('appleFamilyName')}',
        );
        break;
      case AuthorizationStatus.error:
        throw ("Sign in failed: ${result.error!.localizedDescription}");
      case AuthorizationStatus.cancelled:
        throw ('User cancelled');
    }
  } else {
    throw ('Apple SignIn is not available for your device');
  }
}

/// UserData provided only 1st time..

Future<void> saveAppleData(AuthorizationResult result) async {
  await setValue('appleEmail', result.credential!.email);
  await setValue('appleGivenName', result.credential!.fullName!.givenName);
  await setValue('appleFamilyName', result.credential!.fullName!.familyName);
}

Future<void> loginFromFirebaseUser(User currentUser, String loginType, {String? fullName}) async {
  UserModel userModel = UserModel();

  if (await userService.isUserExist(currentUser.email, loginType)) {
    //
    ///Return user data
    await userService.userByEmail(currentUser.email).then((user) async {
      userModel = user;

      setValue(GOOGLE_LOGIN_NEW, false);
      await updateUserData(userModel);
    }).catchError((e) {
      throw e;
    });
  } else {
    /// Create user
    userModel.id = currentUser.uid;
    userModel.email = currentUser.email;
    userModel.name = (currentUser.displayName) ?? fullName;
    userModel.image = currentUser.photoURL;
    userModel.mobileNumber = currentUser.phoneNumber;
    userModel.loginType = loginType;
    userModel.updatedAt = DateTime.now();
    userModel.createdAt = DateTime.now();

    userModel.isAdmin = false;
    userModel.isTester = false;
    userModel.isNotificationOn = true;

    userModel.oneSignalPlayerId = getStringAsync(PLAYER_ID);

    await userService.addDocumentWithCustomId(currentUser.uid, userModel.toJson()).then((value) {
      setValue(GOOGLE_LOGIN_NEW, true);
      //
    }).catchError((e) {
      throw e;
    });
  }

  await setValue(LOGIN_TYPE, loginType);
  await setUserDetailPreference(userModel);
}

Future deleteUser(String email, String password) async {
  await removeKey(IS_LOGGED_IN);
  await removeKey(IS_ADMIN);
  await removeKey(USER_ID);
  await removeKey(FULL_NAME);
  // await removeKey(USER_EMAIL);
  await removeKey(USER_ROLE);
  // await removeKey(PASSWORD);
  await removeKey(PROFILE_IMAGE);
  await removeKey(IS_NOTIFICATION_ON);
  // await removeKey(IS_REMEMBERED);
  await removeKey(LANGUAGE);
  await removeKey(PLAYER_ID);
  await removeKey(IS_SOCIAL_LOGIN);
  await removeKey(LOGIN_TYPE);
  await removeKey(POST_VIEWED_LIST);
  await removeKey(BOOKMARKS);
  appStore.setLoggedIn(false);

  bookmarkList.clear();
  postViewedList.clear();

  FirebaseAuth.instance.currentUser!.delete();
  await FirebaseAuth.instance.signOut();
}
