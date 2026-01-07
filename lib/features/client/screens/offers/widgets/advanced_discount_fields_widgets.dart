import 'package:flutter/material.dart';
import '../../../models/offer.dart';

/// Widget for Buy X Get Y discount offer fields
class BuyXGetYFields extends StatelessWidget {
  final TextEditingController buyQuantityController;
  final TextEditingController getQuantityController;
  final TextEditingController percentageOffController;
  final TextEditingController flatDiscountController;
  final OfferType selectedOfferType;
  final Color darkBlue;
  final Color brightGold;

  const BuyXGetYFields({
    super.key,
    required this.buyQuantityController,
    required this.getQuantityController,
    required this.percentageOffController,
    required this.flatDiscountController,
    required this.selectedOfferType,
    required this.darkBlue,
    required this.brightGold,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // For BOGO show both buy and get quantities. For Buy X Get Y (percent/rupees)
        // only show the buy quantity and the corresponding percent/rupee field below.
        if (selectedOfferType == OfferType.bogo)
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: buyQuantityController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: darkBlue),
                  decoration: InputDecoration(
                    labelText: 'Buy Quantity',
                    labelStyle: TextStyle(color: darkBlue),
                    hintText: 'Usually 1',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.shopping_bag, color: brightGold),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    final num = int.tryParse(value);
                    if (num == null || num <= 0) {
                      return 'Enter valid quantity';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: getQuantityController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: darkBlue),
                  decoration: InputDecoration(
                    labelText: 'Get Free Quantity',
                    labelStyle: TextStyle(color: darkBlue),
                    hintText: 'Usually 1',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.redeem, color: brightGold),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    final num = int.tryParse(value);
                    if (num == null || num <= 0) {
                      return 'Enter valid quantity';
                    }
                    return null;
                  },
                ),
              ),
            ],
          )
        else
          // For Buy X Get Y% or Buy X Get ₹Y show only Buy Quantity here
          TextFormField(
            controller: buyQuantityController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: darkBlue),
            decoration: InputDecoration(
              labelText: 'Buy Quantity',
              labelStyle: TextStyle(color: darkBlue),
              hintText: 'e.g., 2',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.shopping_cart, color: brightGold),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Required';
              }
              final num = int.tryParse(value);
              if (num == null || num <= 0) {
                return 'Enter valid quantity';
              }
              return null;
            },
          ),
        const SizedBox(height: 16),
        if (selectedOfferType == OfferType.buyXGetYPercentOff)
          TextFormField(
            controller: percentageOffController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: darkBlue),
            decoration: InputDecoration(
              labelText: 'Percentage Off',
              labelStyle: TextStyle(color: darkBlue),
              hintText: 'e.g., 50 for 50%',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.percent, color: brightGold),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Percentage is required';
              }
              final num = double.tryParse(value);
              if (num == null || num <= 0 || num > 100) {
                return 'Enter valid percentage (1-100)';
              }
              return null;
            },
          ),
        if (selectedOfferType == OfferType.buyXGetYRupeesOff)
          TextFormField(
            controller: flatDiscountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: darkBlue),
            decoration: InputDecoration(
              labelText: 'Rupees Off on "Get" Items',
              labelStyle: TextStyle(color: darkBlue),
              hintText: 'e.g., 100 for ₹100 off',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.currency_rupee, color: brightGold),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Amount is required';
              }
              final num = double.tryParse(value);
              if (num == null || num <= 0) {
                return 'Enter valid amount';
              }
              return null;
            },
          ),
      ],
    );
  }
}

/// Widget for Buy One Get One (BOGO) offer fields
class BOGOFields extends StatelessWidget {
  final TextEditingController buyQuantityController;
  final TextEditingController getQuantityController;
  final Color darkBlue;
  final Color brightGold;

  const BOGOFields({
    super.key,
    required this.buyQuantityController,
    required this.getQuantityController,
    required this.darkBlue,
    required this.brightGold,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: buyQuantityController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: darkBlue),
                decoration: InputDecoration(
                  labelText: 'Buy Quantity',
                  labelStyle: TextStyle(color: darkBlue),
                  hintText: 'Usually 1',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.shopping_bag, color: brightGold),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: getQuantityController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: darkBlue),
                decoration: InputDecoration(
                  labelText: 'Get Free Quantity',
                  labelStyle: TextStyle(color: darkBlue),
                  hintText: 'Usually 1',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.redeem, color: brightGold),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: brightGold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: darkBlue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Example: Buy 1 Get 1 Free - customers get one item free when they purchase one.',
                  style: TextStyle(color: darkBlue, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
