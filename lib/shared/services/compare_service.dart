import 'package:flutter/foundation.dart';
import '../../features/client/models/offer.dart';

class CompareService extends ChangeNotifier {
  /// For compatibility with UI code expecting 'comparedOffers' instead of 'compareList'.
  List<Offer> get comparedOffers => compareList;
  final List<Offer> _compareList = [];

  List<Offer> get compareList => List.unmodifiable(_compareList);

  int get count => _compareList.length;

  bool get canCompare => _compareList.length >= 2;

  bool get isFull => _compareList.length >= 4;

  bool isInCompare(String offerId) {
    return _compareList.any((offer) => offer.id == offerId);
  }

  void addToCompare(Offer offer) {
    if (_compareList.length >= 4) {
      throw Exception('Maximum 4 offers can be compared');
    }
    if (!isInCompare(offer.id)) {
      _compareList.add(offer);
      notifyListeners();
    }
  }

  void removeFromCompare(String offerId) {
    _compareList.removeWhere((offer) => offer.id == offerId);
    notifyListeners();
  }

  void toggleCompare(Offer offer) {
    if (isInCompare(offer.id)) {
      removeFromCompare(offer.id);
    } else {
      if (!isFull) {
        addToCompare(offer);
      }
    }
  }

  void clearCompare() {
    _compareList.clear();
    notifyListeners();
  }
}
