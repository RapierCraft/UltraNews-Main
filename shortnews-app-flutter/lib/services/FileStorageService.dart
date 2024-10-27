import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart' as path;

Future<String> uploadFile({Uint8List? bytes, dynamic blob, File? file, String prefix = mFirebaseStorageFilePath}) async {
  if (Uint8List == null && blob == null && file == null) {
    throw errorSomethingWentWrong;
  }

  if (prefix.isNotEmpty && !prefix.endsWith('/')) {
    prefix = '$prefix';
  }
  String fileName = currentTimeStamp().toString();
  if (file != null) {
    fileName = '${path.basename(file.path)}';
  }

  Reference storageReference = FirebaseStorage.instance.ref().child('$fileName');

  log(storageReference.fullPath);

  UploadTask? uploadTask;

  if (file != null) {
    log("file" + file.toString());
    uploadTask = storageReference.putFile(file);
    log("Uploaded task" + uploadTask.storage.bucket);
  } else if (blob != null) {
    uploadTask = storageReference.putBlob(blob);
  } else if (bytes != null) {
    uploadTask = storageReference.putData(bytes, SettableMetadata(contentType: 'image/png'));
  }

  if (uploadTask == null) throw errorSomethingWentWrong;

  log('File Uploading');

  return await uploadTask.then((v) async {
    log('File Uploaded---');

    if (v.state == TaskState.success) {
      String url = await storageReference.getDownloadURL();

      log("url" + url);

      return url;
    } else {
      throw errorSomethingWentWrong;
    }
  }).catchError((error) {
    log(error);
    throw error;
  });
}

Future<void> updateUserInfo(Map data, String id, {XFile? profileImage}) async {
  if (profileImage != null) {
    String fileName = profileImage.path;
    Reference storageRef = FirebaseStorage.instance.ref().child('$fileName');
    final metadata = SettableMetadata(contentType: 'image/png');
    UploadTask uploadTask = storageRef.putData(await profileImage.readAsBytes(), metadata);
    await uploadTask.then((e) async {
      await e.ref.getDownloadURL().then((value) {
        appStore.setUserProfile(value);
        data.putIfAbsent("photoUrl", () => value);
      });
    });
    // finish(context);
  }

  return userService.ref!.doc(id).update(data as Map<String, Object?>);
}

Future<void> deleteFile(String url) async {
  String path = url.replaceAll(RegExp(r'https://firebasestorage.googleapis.com/v0/b/digitalguyzz-news-firebase.appspot.com/o/default_images%2F'), '').split('?')[0];
  log(path);
  await FirebaseStorage.instance.ref().child(path).delete().then((value) {
    log('File deleted: $url');
  }).catchError((e) {
    throw e;
  });
}

Future<List<String>> listOfFileFromFirebaseStorage({String? path}) async {
  List<String> list = [];

  var ref = FirebaseStorage.instance.ref('$mFirebaseStorageFilePath');
  log(ref);

  var listResult = await ref.listAll();
  log(listResult);

  listResult.prefixes.forEach((element) {
    log(element.fullPath);
  });
  listResult.items.forEach((element) {
    log(element.fullPath);

    list.add(element.fullPath);
  });
  return list;
}
