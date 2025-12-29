import 'package:cloud_firestore/cloud_firestore.dart';

class OfferScrollerService {
  final FirebaseFirestore _firestore;
  OfferScrollerService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches the offerScroller texts from Firestore (main/offerScroller/texts)
  Stream<List<String>> watchOfferScrollerTexts() {
    return _firestore
        .collection('offerScroller')
        .doc('main')
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null || data['texts'] == null) return <String>[];
      final texts = data['texts'];
      if (texts is List) {
        return texts.whereType<String>().toList();
      }
      return <String>[];
    });
  }
}
