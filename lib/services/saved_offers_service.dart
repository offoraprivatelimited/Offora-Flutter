import 'package:cloud_firestore/cloud_firestore.dart';
import '../client/models/offer.dart';

class SavedOffersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user's saved offers collection reference
  CollectionReference _getUserSavedCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('savedOffers');
  }

  /// Check if an offer is saved by the user
  Future<bool> isOfferSaved(String userId, String offerId) async {
    try {
      final doc = await _getUserSavedCollection(userId).doc(offerId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Save an offer for the user
  Future<void> saveOffer(String userId, Offer offer) async {
    await _getUserSavedCollection(userId).doc(offer.id).set({
      'offerId': offer.id,
      'savedAt': FieldValue.serverTimestamp(),
      'offer': offer.toJson(),
    });
  }

  /// Remove a saved offer
  Future<void> unsaveOffer(String userId, String offerId) async {
    await _getUserSavedCollection(userId).doc(offerId).delete();
  }

  /// Toggle save status
  Future<bool> toggleSaveOffer(String userId, Offer offer) async {
    final isSaved = await isOfferSaved(userId, offer.id);
    if (isSaved) {
      await unsaveOffer(userId, offer.id);
      return false;
    } else {
      await saveOffer(userId, offer);
      return true;
    }
  }

  /// Watch saved offers for a user
  Stream<List<Offer>> watchSavedOffers(String userId) {
    return _getUserSavedCollection(userId)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final offerData = data['offer'] as Map<String, dynamic>;

        return Offer(
          id: offerData['id'] ?? doc.id,
          clientId: offerData['clientId'] ?? '',
          title: offerData['title'] ?? '',
          description: offerData['description'] ?? '',
          originalPrice: (offerData['originalPrice'] as num?)?.toDouble() ?? 0,
          discountPrice: (offerData['discountPrice'] as num?)?.toDouble() ?? 0,
          status: OfferApprovalStatus.values.firstWhere(
            (s) => s.name == (offerData['status'] ?? 'pending'),
            orElse: () => OfferApprovalStatus.approved,
          ),
          imageUrls: (offerData['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
          client: offerData['client'] as Map<String, dynamic>?,
          terms: offerData['terms'] as String?,
          startDate: offerData['startDate'] != null
              ? (offerData['startDate'] as Timestamp).toDate()
              : null,
          endDate: offerData['endDate'] != null
              ? (offerData['endDate'] as Timestamp).toDate()
              : null,
          createdAt: offerData['createdAt'] != null
              ? (offerData['createdAt'] as Timestamp).toDate()
              : null,
        );
      }).toList();
    });
  }

  /// Get saved offers as a list
  Future<List<Offer>> getSavedOffers(String userId) async {
    final snapshot = await _getUserSavedCollection(userId)
        .orderBy('savedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final offerData = data['offer'] as Map<String, dynamic>;

      return Offer(
        id: offerData['id'] ?? doc.id,
        clientId: offerData['clientId'] ?? '',
        title: offerData['title'] ?? '',
        description: offerData['description'] ?? '',
        originalPrice: (offerData['originalPrice'] as num?)?.toDouble() ?? 0,
        discountPrice: (offerData['discountPrice'] as num?)?.toDouble() ?? 0,
        status: OfferApprovalStatus.values.firstWhere(
          (s) => s.name == (offerData['status'] ?? 'pending'),
          orElse: () => OfferApprovalStatus.approved,
        ),
        imageUrls: (offerData['imageUrls'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        client: offerData['client'] as Map<String, dynamic>?,
        terms: offerData['terms'] as String?,
        startDate: offerData['startDate'] != null
            ? (offerData['startDate'] as Timestamp).toDate()
            : null,
        endDate: offerData['endDate'] != null
            ? (offerData['endDate'] as Timestamp).toDate()
            : null,
        createdAt: offerData['createdAt'] != null
            ? (offerData['createdAt'] as Timestamp).toDate()
            : null,
      );
    }).toList();
  }
}
