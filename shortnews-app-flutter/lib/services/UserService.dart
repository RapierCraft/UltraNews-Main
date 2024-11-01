import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/UserModel.dart';
import '../main.dart';
import 'BaseService.dart';

class UserService extends BaseService {
  UserService() {
    ref = db.collection('users');
  }

  Stream<List<UserModel>> users() {
    return ref!.orderBy('updatedAt', descending: true).snapshots().map((x) => x.docs.map((y) => UserModel.fromJson(y.data() as Map<String, dynamic>)).toList());
  }

  Stream<int> totalUsersCount() {
    return ref!.snapshots().map((x) => x.docs.length);
  }

  Future<List<UserModel>> usersFuture({int? limit}) async {
    Query query;

    if (limit == null) {
      query = ref!.orderBy('updatedAt', descending: true);
    } else {
      query = ref!.orderBy('updatedAt', descending: true).limit(limit);
    }
    return await query.get().then((x) => x.docs.map((y) => UserModel.fromJson(y.data() as Map<String, dynamic>)).toList());
  }

  Future<bool> isUserExist(String? email, String loginType) async {
    Query query = ref!.limit(1).where('loginType', isEqualTo: loginType).where('email', isEqualTo: email);

    var res = await query.get();

    if (res.docs != null) {
      return res.docs.length == 1;
    } else {
      return false;
    }
  }

  Future<UserModel> userByEmail(String? email) async {
    return await ref!.where('email', isEqualTo: email).limit(1).get().then((value) {
      if (value.docs.isNotEmpty) {
        return UserModel.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw 'No User Found';
      }
    });
  }

  Future<UserModel> getUserByID(String? id) async {
    return await ref!.where('id', isEqualTo: id).limit(1).get().then((value) {
      if (value.docs.isNotEmpty) {
        return UserModel.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw 'No User Found';
      }
    });
  }

  Future<UserModel> userByMobileNumber(String? phone) async {
    return await ref!.where('mobile', isEqualTo: phone).limit(1).get().then((value) {
      if (value.docs.isNotEmpty) {
        return UserModel.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw 'EXCEPTION_NO_USER_FOUND';
      }
    });
  }
}
