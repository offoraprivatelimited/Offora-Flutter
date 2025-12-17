import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/offer.dart';

class OfferService {
  /// Fetch all offers uploaded by a client from their offers subcollection, with optional status filter
  Stream<List<Offer>> watchClientOffersByStatus(String clientId,
      {String? status}) {
    final offersRef =
        _firestore.collection('clients').doc(clientId).collection('offers');
    return offersRef.snapshots().asyncMap((snapshot) async {
      final offerIds = snapshot.docs.map((doc) => doc.id).toList();
      if (offerIds.isEmpty) return <Offer>[];

      // Fetch offer docs from all status collections
      final statuses = ['pending', 'approved', 'rejected'];
      final List<Offer> offers = [];
      for (final s in statuses) {
        if (status != null && s != status) continue;
        final query = await _statusCollection(s)
            .where(FieldPath.documentId, whereIn: offerIds)
            .get();
        offers.addAll(query.docs.map((doc) => Offer.fromFirestore(doc)));
      }
      return offers;
    });
  }

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
        final Uint8List data = await images[i].readAsBytes();
        final ref = storage.ref().child(
            'offers/$clientId/${createdAt.millisecondsSinceEpoch}_$i.jpg');
        final uploadTask = await ref.putData(
          data,
          SettableMetadata(contentType: 'image/jpeg'),
        );
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

  /// Advanced submit supporting extended Offer fields
  Future<String> submitOfferAdvanced({
    required Offer offer,
  }) async {
    final createdAt = offer.createdAt ?? DateTime.now();

    final toSave = offer.copyWith(
      id: '',
      status: OfferApprovalStatus.pending,
      createdAt: createdAt,
      updatedAt: null,
      rejectionReason: null,
    );

    // Create offer in the pending status collection (existing structure)
    final docRef = await _statusCollection('pending').add(toSave.toJson());

    // Also store the offer in the client's offers subcollection
    if (toSave.clientId.isNotEmpty) {
      await _firestore
          .collection('clients')
          .doc(toSave.clientId)
          .collection('offers')
          .doc(docRef.id)
          .set(toSave.copyWith(id: docRef.id).toJson());
    }
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

  /// Update an existing offer (client-side edit). It updates the pending document
  /// and uploads any new images, preserving existing image URLs if provided.
  Future<void> updateOffer({
    required String offerId,
    required String title,
    required String description,
    required double originalPrice,
    required double discountPrice,
    DateTime? startDate,
    DateTime? endDate,
    String? terms,
    List<XFile>? newImages,
    List<String>? existingImageUrls,
  }) async {
    try {
      // Get current offer to determine its status
      final pendingDoc = await _statusCollection('pending').doc(offerId).get();

      if (!pendingDoc.exists) {
        throw Exception('Offer not found');
      }

      // Upload new images if any
      List<String> allImageUrls =
          existingImageUrls != null ? List.from(existingImageUrls) : [];
      if (newImages != null && newImages.isNotEmpty) {
        final storage = FirebaseStorage.instance;
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        for (var i = 0; i < newImages.length; i++) {
          final Uint8List data = await newImages[i].readAsBytes();
          final ref = storage.ref().child(
                'offers/${pendingDoc.data()?['clientId']}/${timestamp}_$i.jpg',
              );
          final uploadTask = await ref.putData(
            data,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          final downloadUrl = await uploadTask.ref.getDownloadURL();
          allImageUrls.add(downloadUrl);
        }
      }

      // Update the offer document in pending collection
      await _statusCollection('pending').doc(offerId).update({
        'title': title,
        'description': description,
        'originalPrice': originalPrice,
        'discountPrice': discountPrice,
        'startDate': startDate,
        'endDate': endDate,
        'terms': terms,
        'imageUrls': allImageUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update offer: $e');
    }
  }

  /// Advanced update supporting extended Offer fields
  Future<void> updateOfferAdvanced({
    required Offer offer,
  }) async {
    try {
      // Search for the offer in all status collections
      final statuses = ['pending', 'approved', 'rejected'];
      String? foundStatus;

      for (final status in statuses) {
        final doc = await _statusCollection(status).doc(offer.id).get();
        if (doc.exists) {
          foundStatus = status;
          break;
        }
      }

      if (foundStatus == null) {
        throw Exception('Offer not found in any status collection');
      }

      final updated = offer.copyWith(
        status: OfferApprovalStatus.pending,
        updatedAt: DateTime.now(),
      );

      await _statusCollection(foundStatus)
          .doc(offer.id)
          .update(updated.toJson());
    } catch (e) {
      throw Exception('Failed to update offer: $e');
    }
  }

  /// Delete an offer and its images (searches through pending/approved/rejected)
  Future<void> deleteOffer(String offerId) async {
    try {
      final statuses = ['pending', 'approved', 'rejected'];

      for (final status in statuses) {
        final doc = await _statusCollection(status).doc(offerId).get();
        if (doc.exists) {
          final data = doc.data();
          final imageUrls = data?['imageUrls'] as List?;
          if (imageUrls != null && imageUrls.isNotEmpty) {
            final storage = FirebaseStorage.instance;
            for (final url in imageUrls) {
              try {
                final ref = storage.refFromURL(url.toString());
                await ref.delete();
              } catch (e) {
                // Continue even if image deletion fails
              }
            }
          }

          await _statusCollection(status).doc(offerId).delete();
          return;
        }
      }

      throw Exception('Offer not found');
    } catch (e) {
      throw Exception('Failed to delete offer: $e');
    }
  }
}
