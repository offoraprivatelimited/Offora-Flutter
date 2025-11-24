import 'package:cloud_firestore/cloud_firestore.dart';

enum OfferApprovalStatus { pending, approved, rejected }

class Offer {
  Offer({
    required this.id,
    required this.clientId,
    required this.title,
    required this.description,
    required this.originalPrice,
    required this.discountPrice,
    required this.status,
    this.imageUrls,
    this.client,
    this.terms,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.rejectionReason,
  });

  final String id;
  final String clientId;
  final String title;
  final String description;
  final double originalPrice;
  final double discountPrice;
  final OfferApprovalStatus status;
  final List<String>? imageUrls;
  final Map<String, dynamic>? client;
  final String? terms;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? rejectionReason;

  bool get isPending => status == OfferApprovalStatus.pending;
  bool get isApproved => status == OfferApprovalStatus.approved;
  bool get isRejected => status == OfferApprovalStatus.rejected;

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'title': title,
      'description': description,
      'originalPrice': originalPrice,
      'discountPrice': discountPrice,
      'status': status.name,
      if (imageUrls != null) 'imageUrls': imageUrls,
      if (client != null) 'client': client,
      if (terms != null) 'terms': terms,
      if (startDate != null) 'startDate': Timestamp.fromDate(startDate!),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }

  factory Offer.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final statusRaw =
        data['status'] as String? ?? OfferApprovalStatus.pending.name;
    return Offer(
      id: doc.id,
      clientId: data['clientId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      originalPrice: (data['originalPrice'] as num?)?.toDouble() ?? 0,
      discountPrice: (data['discountPrice'] as num?)?.toDouble() ?? 0,
      status: OfferApprovalStatus.values.firstWhere(
        (state) => state.name == statusRaw,
        orElse: () => OfferApprovalStatus.pending,
      ),
      imageUrls: (data['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      client: data['client'] as Map<String, dynamic>?,
      terms: data['terms'] as String?,
      startDate: _timestampToDate(data['startDate']),
      endDate: _timestampToDate(data['endDate']),
      createdAt: _timestampToDate(data['createdAt']),
      updatedAt: _timestampToDate(data['updatedAt']),
      rejectionReason: data['rejectionReason'] as String?,
    );
  }

  static DateTime? _timestampToDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }
}
