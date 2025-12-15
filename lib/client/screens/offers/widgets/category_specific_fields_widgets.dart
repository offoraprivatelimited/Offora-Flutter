import 'package:flutter/material.dart';

/// Widget for product-specific offer fields
class ProductSpecificFields extends StatefulWidget {
  final TextEditingController productController;
  final List<String> applicableProducts;
  final Color darkBlue;
  final Color brightGold;
  final VoidCallback onAddProduct;

  const ProductSpecificFields({
    super.key,
    required this.productController,
    required this.applicableProducts,
    required this.darkBlue,
    required this.brightGold,
    required this.onAddProduct,
  });

  @override
  State<ProductSpecificFields> createState() => _ProductSpecificFieldsState();
}

class _ProductSpecificFieldsState extends State<ProductSpecificFields> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Applicable Products',
          style: TextStyle(
            color: widget.darkBlue,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.productController,
                style: TextStyle(color: widget.darkBlue),
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  labelStyle: TextStyle(color: widget.darkBlue),
                  hintText: 'e.g., Premium Coffee Beans',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.inventory_2_outlined,
                      color: widget.brightGold),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: widget.onAddProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.brightGold,
                foregroundColor: widget.darkBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.applicableProducts.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.applicableProducts.map((product) {
              return Chip(
                label: Text(product),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    widget.applicableProducts.remove(product);
                  });
                },
                backgroundColor: widget.brightGold.withOpacity(0.2),
                labelStyle: TextStyle(color: widget.darkBlue),
              );
            }).toList(),
          ),
      ],
    );
  }
}

/// Widget for service-specific offer fields
class ServiceSpecificFields extends StatefulWidget {
  final TextEditingController serviceController;
  final List<String> applicableServices;
  final Color darkBlue;
  final Color brightGold;
  final VoidCallback onAddService;

  const ServiceSpecificFields({
    super.key,
    required this.serviceController,
    required this.applicableServices,
    required this.darkBlue,
    required this.brightGold,
    required this.onAddService,
  });

  @override
  State<ServiceSpecificFields> createState() => _ServiceSpecificFieldsState();
}

class _ServiceSpecificFieldsState extends State<ServiceSpecificFields> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Applicable Services',
          style: TextStyle(
            color: widget.darkBlue,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.serviceController,
                style: TextStyle(color: widget.darkBlue),
                decoration: InputDecoration(
                  labelText: 'Service Name',
                  labelStyle: TextStyle(color: widget.darkBlue),
                  hintText: 'e.g., Hair Styling',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.design_services_outlined,
                      color: widget.brightGold),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: widget.onAddService,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.brightGold,
                foregroundColor: widget.darkBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.applicableServices.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.applicableServices.map((service) {
              return Chip(
                label: Text(service),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    widget.applicableServices.remove(service);
                  });
                },
                backgroundColor: widget.brightGold.withOpacity(0.2),
                labelStyle: TextStyle(color: widget.darkBlue),
              );
            }).toList(),
          ),
      ],
    );
  }
}

/// Widget for bundle deal offer fields
class BundleDealFields extends StatefulWidget {
  final TextEditingController productController;
  final List<String> bundleItems;
  final Color darkBlue;
  final Color brightGold;
  final VoidCallback onAddItem;

  const BundleDealFields({
    super.key,
    required this.productController,
    required this.bundleItems,
    required this.darkBlue,
    required this.brightGold,
    required this.onAddItem,
  });

  @override
  State<BundleDealFields> createState() => _BundleDealFieldsState();
}

class _BundleDealFieldsState extends State<BundleDealFields> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bundle Items',
          style: TextStyle(
            color: widget.darkBlue,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.productController,
                style: TextStyle(color: widget.darkBlue),
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  labelStyle: TextStyle(color: widget.darkBlue),
                  hintText: 'e.g., Burger + Fries + Drink',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon:
                      Icon(Icons.shopping_basket, color: widget.brightGold),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: widget.onAddItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.brightGold,
                foregroundColor: widget.darkBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.bundleItems.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.bundleItems.map((item) {
              return Chip(
                label: Text(item),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    widget.bundleItems.remove(item);
                  });
                },
                backgroundColor: widget.brightGold.withValues(alpha: 0.2),
                labelStyle: TextStyle(color: widget.darkBlue),
              );
            }).toList(),
          ),
      ],
    );
  }
}
