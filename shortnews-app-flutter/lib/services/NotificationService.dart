import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nb_utils/nb_utils.dart';
import '../models/NotificationModel.dart';
import '../utils/Constants.dart';
import 'BaseService.dart';

class NotificationService extends BaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  late CollectionReference userRef;

  NotificationService() {
    userRef = fireStore.collection(NOTIFICATION);
  }

  Future<DocumentReference> addNotification(NotificationClass data) async {
    // log(data.toJson());
    var doc = await userRef.add(data.toJson());
    doc.update({'id': doc.id});
    return doc;
  }
  Future<List<NotificationClass>> getNotification() async {
    Query query = userRef.orderBy("createdAt", descending: true);
    log("value");
    return await query.get().then((x) {
      return x.docs.map((y) => NotificationClass.fromJson(y.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<NotificationClass> getNotificationByID(String? id) async {
    Query query = userRef.orderBy("createdAt", descending: true);
    log("value");
    return await query.get().then((x) {
      return NotificationClass.fromJson(x.docs.first.data() as Map<String, dynamic>);
    });
  }

  removeNotification(String? id){
    userRef.doc(id).delete();
  }

  updateNotification(String? id,Map<String, dynamic> data){
    userRef.doc(id).update(data);
  }
}
//
// Future<DocumentReference> addMessage(ChatMessageModel data, String docId) async {
//   var doc = await fireStore.collection(GROUP_COLLECTION).doc(docId).collection(GROUP_CHATS).add(data.toJson());
//   doc.update({'id': doc.id});
//   return doc;
// }
//
// Query chatMessagesWithPagination({String? currentUserId, required String groupDocId}) {
//   return fireStore.collection(GROUP_COLLECTION).doc(groupDocId).collection(GROUP_CHATS).orderBy('createdAt', descending: true);
// }
//
// Future<void> addMessageToDb({required DocumentReference senderDoc, ChatMessageModel? data, UserModel? sender, UserModel? user, File? image, bool isRequest = false}) async {
//   String imageUrl = '';
//
//   if (image != null) {
//     String fileName = basename(image.path);
//     Reference storageRef = _storage.ref().child("$GROUP_PROFILE_IMAGES/${getStringAsync(userId)}/$fileName");
//     UploadTask uploadTask = storageRef.putFile(image);
//
//     await uploadTask.then((e) async {
//       await e.ref.getDownloadURL().then((value) async {
//         imageUrl = value;
//         // fileList.removeWhere((element) => element.id == senderDoc.id);
//       }).catchError((e) {
//         toast(e.toString());
//       });
//     }).catchError((e) {
//       toast(e.toString());
//     });
//   }
//   userRef.doc(getStringAsync(userId)).update({"lastMessageTime": DateTime.now().millisecondsSinceEpoch});
//   updateChatDocument(senderDoc, image: image, imageUrl: imageUrl);
// }
//
// DocumentReference? updateChatDocument(DocumentReference data, {File? image, String? imageUrl}) {
//   Map<String, dynamic> sendData = {'id': data.id};
//
//   if (image != null) {
//     sendData.putIfAbsent('photoUrl', () => imageUrl);
//   }
//   data.update(sendData);
// }
//
// Stream<QuerySnapshot> fetchLastMessageBetween({required String senderId, required String rec}) {
//   return fireStore.collection(GROUP_COLLECTION).doc(rec).collection(GROUP_CHATS).orderBy("createdAt", descending: false).snapshots();
// }
//
// addLatLong(ChatMessageModel data, {String? lat, String? long, String? groupId}) {
//   Map<String, dynamic> sendData = {'id': data.id};
//   fireStore.collection(GROUP_COLLECTION).doc(groupId).collection(GROUP_CHATS).doc(data.id).set({'currentLat': lat, 'currentLong': long}, SetOptions(merge: true)).then((value) {
//     //
//   });
//
//   sendData.putIfAbsent('current_lat', () => lat);
//   sendData.putIfAbsent('current_lat', () => long);
// }
