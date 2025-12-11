import 'package:cloud_firestore/cloud_firestore.dart';

enum OfferApprovalStatus { pending, approved, rejected }

enum OfferType {
  percentageDiscount, // X% off
  flatDiscount, // ₹X off
  buyXGetYPercentOff, // Buy X Get Y% off
  buyXGetYRupeesOff, // Buy X Get ₹Y off
  bogo, // Buy One Get One
  productSpecific, // Discount on specific product
  serviceSpecific, // Discount on specific service
  bundleDeal, // Multiple items together
}

enum OfferCategory {
  product,
  service,
  both,
}

class Offer {
  Offer({
    required this.id,
    required this.clientId,
    required this.title,
    required this.description,
    required this.originalPrice,
    required this.discountPrice,
    required this.status,
    this.offerType = OfferType.percentageDiscount,
    this.offerCategory = OfferCategory.product,
    this.businessCategory,
    this.imageUrls,
    this.client,
    this.terms,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.rejectionReason,
    this.buyQuantity,
    this.getQuantity,
    this.percentageOff,
    this.flatDiscountAmount,
    this.applicableProducts,
    this.applicableServices,
    this.minimumPurchase,
    this.maxUsagePerCustomer,
  });

  final String id;
  final String clientId;
  final String title;
  final String description;
  final double originalPrice;
  final double discountPrice;
  final OfferApprovalStatus status;
  final OfferType offerType;
  final OfferCategory offerCategory;
  final String?
      businessCategory; // Business category like Grocery, Restaurant, etc.
  final List<String>? imageUrls;
  final Map<String, dynamic>? client;
  final String? terms;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? rejectionReason;

  // New fields for advanced offer types
  final int? buyQuantity; // For BOGO and Buy X Get Y offers
  final int? getQuantity; // For BOGO and Buy X Get Y offers
  final double? percentageOff; // For percentage-based discounts
  final double? flatDiscountAmount; // For flat rupee discounts
  final List<String>?
      applicableProducts; // Specific products this offer applies to
  final List<String>?
      applicableServices; // Specific services this offer applies to
  final double? minimumPurchase; // Minimum purchase amount required
  final int? maxUsagePerCustomer; // Maximum times a customer can use this offer

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
      'offerType': offerType.name,
      'offerCategory': offerCategory.name,
      if (businessCategory != null) 'businessCategory': businessCategory,
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
      if (buyQuantity != null) 'buyQuantity': buyQuantity,
      if (getQuantity != null) 'getQuantity': getQuantity,
      if (percentageOff != null) 'percentageOff': percentageOff,
      if (flatDiscountAmount != null) 'flatDiscountAmount': flatDiscountAmount,
      if (applicableProducts != null) 'applicableProducts': applicableProducts,
      if (applicableServices != null) 'applicableServices': applicableServices,
      if (minimumPurchase != null) 'minimumPurchase': minimumPurchase,
      if (maxUsagePerCustomer != null)
        'maxUsagePerCustomer': maxUsagePerCustomer,
    };
  }

  factory Offer.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final statusRaw =
        data['status'] as String? ?? OfferApprovalStatus.pending.name;
    final offerTypeRaw =
        data['offerType'] as String? ?? OfferType.percentageDiscount.name;
    final offerCategoryRaw =
        data['offerCategory'] as String? ?? OfferCategory.product.name;

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
      offerType: OfferType.values.firstWhere(
        (type) => type.name == offerTypeRaw,
        orElse: () => OfferType.percentageDiscount,
      ),
      offerCategory: OfferCategory.values.firstWhere(
        (cat) => cat.name == offerCategoryRaw,
        orElse: () => OfferCategory.product,
      ),
      businessCategory: data['businessCategory'] as String?,
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
      buyQuantity: data['buyQuantity'] as int?,
      getQuantity: data['getQuantity'] as int?,
      percentageOff: (data['percentageOff'] as num?)?.toDouble(),
      flatDiscountAmount: (data['flatDiscountAmount'] as num?)?.toDouble(),
      applicableProducts: (data['applicableProducts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      applicableServices: (data['applicableServices'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      minimumPurchase: (data['minimumPurchase'] as num?)?.toDouble(),
      maxUsagePerCustomer: data['maxUsagePerCustomer'] as int?,
    );
  }

  static DateTime? _timestampToDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }

  Offer copyWith({
    String? id,
    String? clientId,
    String? title,
    String? description,
    double? originalPrice,
    double? discountPrice,
    OfferApprovalStatus? status,
    OfferType? offerType,
    OfferCategory? offerCategory,
    String? businessCategory,
    List<String>? imageUrls,
    Map<String, dynamic>? client,
    String? terms,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? rejectionReason,
    int? buyQuantity,
    int? getQuantity,
    double? percentageOff,
    double? flatDiscountAmount,
    List<String>? applicableProducts,
    List<String>? applicableServices,
    double? minimumPurchase,
    int? maxUsagePerCustomer,
  }) {
    return Offer(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      title: title ?? this.title,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      status: status ?? this.status,
      offerType: offerType ?? this.offerType,
      offerCategory: offerCategory ?? this.offerCategory,
      businessCategory: businessCategory ?? this.businessCategory,
      imageUrls: imageUrls ?? this.imageUrls,
      client: client ?? this.client,
      terms: terms ?? this.terms,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      buyQuantity: buyQuantity ?? this.buyQuantity,
      getQuantity: getQuantity ?? this.getQuantity,
      percentageOff: percentageOff ?? this.percentageOff,
      flatDiscountAmount: flatDiscountAmount ?? this.flatDiscountAmount,
      applicableProducts: applicableProducts ?? this.applicableProducts,
      applicableServices: applicableServices ?? this.applicableServices,
      minimumPurchase: minimumPurchase ?? this.minimumPurchase,
      maxUsagePerCustomer: maxUsagePerCustomer ?? this.maxUsagePerCustomer,
    );
  }
}
