import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/offer.dart';

class OfferService {
  OfferService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Reference to offers/{status}/offers subcollection
  CollectionReference<Map<String, dynamic>> _statusCollection(
    String status,
  ) =>
      _firestore.collection('offers').doc(status).collection('offers');

  /// Watch all offers for a specific client (across all statuses for their dashboard)
  Stream<List<Offer>> watchClientOffers(String clientId) {
    // Query across pending offers for this client
    return _statusCollection('pending')
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .withConverter<Offer>(
          fromFirestore: (snapshot, _) => Offer.fromFirestore(snapshot),
          toFirestore: (Offer offer, _) => offer.toJson(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Watch all approved offers (for user explore screen)
  /// Fetches from offers/approved/offers subcollection
  Stream<List<Offer>> watchApprovedOffers() {
    return _statusCollection('approved')
        .orderBy('createdAt', descending: true)
        .withConverter<Offer>(
          fromFirestore: (snapshot, _) => Offer.fromFirestore(snapshot),
          toFirestore: (Offer offer, _) => offer.toJson(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Watch pending offers (for admin approval panel)
  Stream<List<Offer>> watchPendingOffers() {
    return _statusCollection('pending')
        .orderBy('createdAt', descending: true)
        .withConverter<Offer>(
          fromFirestore: (snapshot, _) => Offer.fromFirestore(snapshot),
          toFirestore: (Offer offer, _) => offer.toJson(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Watch rejected offers (for admin review)
  Stream<List<Offer>> watchRejectedOffers() {
    return _statusCollection('rejected')
        .orderBy('createdAt', descending: true)
        .withConverter<Offer>(
          fromFirestore: (snapshot, _) => Offer.fromFirestore(snapshot),
          toFirestore: (Offer offer, _) => offer.toJson(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get a single offer by ID and status
  Future<Offer?> getOffer({
    required String offerId,
    required String status,
  }) async {
    try {
      final doc = await _statusCollection(status).doc(offerId).get();
      if (!doc.exists) return null;
      return Offer.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  /// Submit a new offer (saved to offers/pending/offers)
  Future<String> submitOffer({
    required String clientId,
    required String title,
    required String description,
    required double originalPrice,
    required double discountPrice,
    DateTime? startDate,
    DateTime? endDate,
    String? terms,
    List<XFile>? images,
    Map<String, dynamic>? client,
  }) async {
    final createdAt = DateTime.now();

    // Upload images to Firebase Storage and collect download URLs
    List<String>? imageUrls;
    if (images != null && images.isNotEmpty) {
      final storage = FirebaseStorage.instance;
      imageUrls = [];
      for (var i = 0; i < images.length; i++) {
        final file = File(images[i].path);
        final ref = storage.ref().child(
              'offers/$clientId/${createdAt.millisecondsSinceEpoch}_$i.jpg',
            );
        final uploadTask = await ref.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
    }

    final offer = Offer(
      id: '',
      clientId: clientId,
      title: title,
      description: description,
      originalPrice: originalPrice,
      discountPrice: discountPrice,
      status: OfferApprovalStatus.pending,
      startDate: startDate,
      endDate: endDate,
      terms: terms,
      imageUrls: imageUrls,
      client: client,
      createdAt: createdAt,
    );

    // Write to offers/pending/offers subcollection
    final docRef = await _statusCollection('pending').add(offer.toJson());
    return docRef.id;
  }

  /// Move an offer from one status to another (used by admin)
  /// For example: pending → approved, or pending → rejected
  Future<void> updateOfferStatus({
    required String offerId,
    required String fromStatus,
    required String toStatus,
    String? rejectionReason,
  }) async {
    try {
      // Get the offer from current status
      final currentDoc = await _statusCollection(fromStatus).doc(offerId).get();

      if (!currentDoc.exists) {
        throw Exception('Offer not found in $fromStatus collection');
      }

      // Get the data
      final offerData = currentDoc.data() ?? <String, dynamic>{};

      // Update status in the data
      offerData['status'] = toStatus;
      if (rejectionReason != null) {
        offerData['rejectionReason'] = rejectionReason;
      }
      offerData['updatedAt'] = FieldValue.serverTimestamp();

      // Write to new status collection
      await _statusCollection(toStatus).doc(offerId).set(offerData);

      // Delete from old status collection
      await _statusCollection(fromStatus).doc(offerId).delete();
    } catch (e) {
      throw Exception('Failed to update offer status: $e');
    }
  }

  /// Approve an offer (move from pending to approved)
  Future<void> approveOffer(String offerId) async {
    await updateOfferStatus(
      offerId: offerId,
      fromStatus: 'pending',
      toStatus: 'approved',
    );
  }

  /// Reject an offer (move from pending to rejected)
  Future<void> rejectOffer(String offerId, String reason) async {
    await updateOfferStatus(
      offerId: offerId,
      fromStatus: 'pending',
      toStatus: 'rejected',
      rejectionReason: reason,
    );
  }
}
