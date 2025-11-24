import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/offer.dart';

class OfferService {
  OfferService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _offersCollection =>
      _firestore.collection('offers');

  CollectionReference<Map<String, dynamic>> _pendingCollection(
    String clientId,
  ) => _firestore.collection('offers').doc('pending').collection(clientId);

  Stream<List<Offer>> watchClientOffers(String clientId) {
    // Watch top-level offers collection for this client (keeps backward compatibility)
    return _offersCollection
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .withConverter<Offer>(
          fromFirestore: (snapshot, _) => Offer.fromFirestore(snapshot),
          toFirestore: (Offer offer, _) => offer.toJson(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> submitOffer({
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

    // Write to top-level offers collection (existing consumers)
    await _offersCollection.add(offer.toJson());

    // Also write to offers/pending/{clientId} as requested
    await _pendingCollection(clientId).add(offer.toJson());
  }
}
