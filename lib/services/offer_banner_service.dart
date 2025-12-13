import 'package:cloud_firestore/cloud_firestore.dart';

class OfferBanner {
  final String url;
  final int position;
  final String? title;
  final String? description;
  final String? email;
  final String? phone;
  final String? link;

  OfferBanner({
    required this.url,
    required this.position,
    this.title,
    this.description,
    this.email,
    this.phone,
    this.link,
  });

  factory OfferBanner.fromFirestore(Map<String, dynamic> data) {
    return OfferBanner(
      url: data['url'] as String,
      position: data['position'] as int? ?? 0,
      title: data['title'] as String?,
      description: data['description'] as String?,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      link: data['link'] as String?,
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
