import 'offer.dart';
import 'offer_calculator.dart';

/// Use this for offer card summary display (short, always shows a value)
String getOfferCardDiscountText(Offer offer) {
  final result = OfferCalculator.calculate(offer);
  // Always show a value for the card, fallback to "No discount" if needed
  if (result.discountAmount > 0) {
    return result.summary;
  }
  // For BOGO and similar, show summary
  if (offer.offerType == OfferType.bogo ||
      offer.offerType == OfferType.buyXGetYPercentOff ||
      offer.offerType == OfferType.buyXGetYRupeesOff) {
    return result.summary;
  }
  // Otherwise, fallback
  return 'No discount';
}
