import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../models/AudiencePollModel.dart';
import '../services/BaseService.dart';
import '../utils/ModelKeys.dart';

class AudiencePollService extends BaseService {
  AudiencePollService() {
    ref = db.collection('audiencePoll');
  }

  Stream<List<AudiencePollModel>> getAllPollList({int limit = 1}) {
    return getAllAudiencePoll().limit(limit).snapshots().map((x) => x.docs.map((y) => AudiencePollModel.fromJson(y.data() as Map<String, dynamic>)).toList());
  }

  Query getAllAudiencePoll() {
    return ref!.where(AudiencePollKeys.endedAt, isGreaterThan: DateTime.now()).orderBy(AudiencePollKeys.endedAt, descending: true).orderBy(CommonKeys.createdAt, descending: true);
  }

  Query getPollListByUserID(String userId) {
    return ref!.where(AudiencePollKeys.userId, isEqualTo: userId).orderBy(CommonKeys.createdAt, descending: true);
  }
}
