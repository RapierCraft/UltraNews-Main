import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../models/AudiencePollModel.dart';
import '../services/BaseService.dart';

class PollAnswerListService extends BaseService {
  PollAnswerListService({String? pollID}) {
    ref = db.collection('audiencePoll').doc(pollID).collection('pollAnswerList');
  }

  Stream<List<UserData>> getAllPollAnswerList() {
    return ref!.snapshots().map((x) => x.docs.map((e) => UserData.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<void> deletePollAnswerList() async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    ref!.get().then((querySnapshot) {
      querySnapshot.docs.forEach((e) {
        batch.delete(e.reference);
      });
      batch.commit();
    });
  }
}
