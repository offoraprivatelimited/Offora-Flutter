import 'offer.dart';

class OfferCalculationResult {
  final String summary;
  final double discountAmount;
  final double? percentOff;
  final String? details;

  OfferCalculationResult({
    required this.summary,
    required this.discountAmount,
    this.percentOff,
    this.details,
  });
}

class OfferCalculator {
  static OfferCalculationResult calculate(Offer offer) {
    switch (offer.offerType) {
      case OfferType.percentageDiscount:
        final discountPrice = offer.discountPrice ?? 0;
        final percent =
            (((1 - (discountPrice / offer.originalPrice)) * 100).clamp(0, 100))
                .toDouble();
        final amount = ((offer.originalPrice - discountPrice)
                .clamp(0, offer.originalPrice))
            .toDouble();
        return OfferCalculationResult(
          summary:
              'You save ₹${amount.toStringAsFixed(0)} (${percent.toStringAsFixed(0)}%)',
          discountAmount: amount,
          percentOff: percent,
          details: 'Get ${percent.toStringAsFixed(0)}% off on your purchase.',
        );
      case OfferType.flatDiscount:
        final discountAmount =
            offer.flatDiscountAmount ?? (offer.discountPrice ?? 0);
        final amount = offer.originalPrice - discountAmount;
        if (amount > 0) {
          return OfferCalculationResult(
            summary: 'You save ₹${amount.toStringAsFixed(0)}',
            discountAmount: amount,
            details: 'Flat ₹${amount.toStringAsFixed(0)} off on this item.',
          );
        } else {
          return OfferCalculationResult(
            summary: 'No discount',
            discountAmount: 0,
            details: 'No discount applied.',
          );
        }
      case OfferType.buyXGetYPercentOff:
        if (offer.buyQuantity != null && offer.percentageOff != null) {
          return OfferCalculationResult(
            summary:
                'Buy ${offer.buyQuantity}, get ${offer.percentageOff!.toStringAsFixed(0)}% off next',
            discountAmount: 0,
            percentOff: offer.percentageOff,
            details:
                'Buy ${offer.buyQuantity} items, get ${offer.percentageOff!.toStringAsFixed(0)}% off on the next item.',
          );
        }
        break;
      case OfferType.buyXGetYRupeesOff:
        if (offer.buyQuantity != null && offer.flatDiscountAmount != null) {
          return OfferCalculationResult(
            summary:
                'Buy ${offer.buyQuantity}, get ₹${offer.flatDiscountAmount!.toStringAsFixed(0)} off next',
            discountAmount: offer.flatDiscountAmount!,
            details:
                'Buy ${offer.buyQuantity} items, get ₹${offer.flatDiscountAmount!.toStringAsFixed(0)} off on the next item.',
          );
        }
        break;
      case OfferType.bogo:
        return OfferCalculationResult(
          summary: 'Buy 1, get 1 FREE',
          discountAmount: offer.originalPrice,
          details:
              'Buy 1 item and get 1 item FREE! Perfect for sharing with a friend.',
        );
      case OfferType.productSpecific:
        return OfferCalculationResult(
          summary: 'Product-specific offer',
          discountAmount: 0,
          details: 'This special discount applies to specific products.',
        );
      case OfferType.serviceSpecific:
        return OfferCalculationResult(
          summary: 'Service-specific offer',
          discountAmount: 0,
          details: 'This special discount applies to specific services.',
        );
      case OfferType.bundleDeal:
        return OfferCalculationResult(
          summary: 'Bundle offer',
          discountAmount: 0,
          details: 'Buy multiple items together and save more!',
        );
    }
    return OfferCalculationResult(
      summary: 'No discount',
      discountAmount: 0,
      details: 'No discount applied.',
    );
  }
}
