import 'package:flutter/material.dart';

/// Widget for percentage discount offer fields
class PercentageDiscountFields extends StatelessWidget {
  final TextEditingController percentageOffController;
  final Function(String) onPercentageChanged;
  final String Function(String?)? validator;
  final Color darkBlue;
  final Color brightGold;
  final bool isEditing;

  const PercentageDiscountFields({
    super.key,
    required this.percentageOffController,
    required this.onPercentageChanged,
    this.validator,
    required this.darkBlue,
    required this.brightGold,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: percentageOffController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: darkBlue),
          onChanged: onPercentageChanged,
          decoration: InputDecoration(
            labelText: 'Discount Percentage',
            labelStyle: TextStyle(color: darkBlue),
            hintText: 'e.g., 25 for 25% off',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.percent, color: brightGold),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: validator,
        ),
      ],
    );
  }
}

/// Widget for flat discount offer fields
class FlatDiscountFields extends StatelessWidget {
  final TextEditingController flatDiscountController;
  final String Function(String?)? validator;
  final Color darkBlue;
  final Color brightGold;

  const FlatDiscountFields({
    super.key,
    required this.flatDiscountController,
    this.validator,
    required this.darkBlue,
    required this.brightGold,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: flatDiscountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: darkBlue),
          decoration: InputDecoration(
            labelText: 'Flat Discount Amount (₹)',
            labelStyle: TextStyle(color: darkBlue),
            hintText: 'e.g., 100 for ₹100 off',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.currency_rupee, color: brightGold),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
