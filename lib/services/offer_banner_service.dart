import 'package:cloud_firestore/cloud_firestore.dart';

class OfferBanner {
  final String url;
  final int position;
  OfferBanner({required this.url, required this.position});

  factory OfferBanner.fromFirestore(Map<String, dynamic> data) {
    return OfferBanner(
      url: data['url'] as String,
      position: data['position'] as int? ?? 0,
    );
  }
}

class OfferBannerService {
  final FirebaseFirestore _firestore;
  OfferBannerService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<OfferBanner>> watchOfferBanners() {
    return _firestore
        .collection('offerBanners')
        .orderBy('position')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OfferBanner.fromFirestore(doc.data()))
            .toList());
  }
}
