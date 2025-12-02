import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../services/auth_service.dart';
import '../../models/offer.dart';
import '../../services/offer_service.dart';

class NewOfferFormScreen extends StatefulWidget {
  const NewOfferFormScreen({super.key});

  static const String routeName = '/offers/new-advanced';

  @override
  State<NewOfferFormScreen> createState() => _NewOfferFormScreenState();
}

class _NewOfferFormScreenState extends State<NewOfferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _termsController = TextEditingController();
  final _buyQuantityController = TextEditingController();
  final _getQuantityController = TextEditingController();
  final _percentageOffController = TextEditingController();
  final _flatDiscountController = TextEditingController();
  final _minimumPurchaseController = TextEditingController();
  final _maxUsageController = TextEditingController();
  final _productController = TextEditingController();
  final _serviceController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;
  bool _isEditing = false;
  final List<XFile> _images = [];
  List<String> _existingImageUrls = [];
  OfferType _selectedOfferType = OfferType.percentageDiscount;
  OfferCategory _selectedCategory = OfferCategory.product;
  List<String> _applicableProducts = [];
  List<String> _applicableServices = [];

  final darkBlue = const Color(0xFF1F477D);
  final brightGold = const Color(0xFFF0B84D);

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    try {
      final results = await picker.pickMultiImage(imageQuality: 80);
      if (results.isEmpty) return;
      setState(() {
        _images.addAll(results);
      });
    } catch (e) {
      // ignore errors for now
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
    _discountPriceController.dispose();
    _termsController.dispose();
    _buyQuantityController.dispose();
    _getQuantityController.dispose();
    _percentageOffController.dispose();
    _flatDiscountController.dispose();
    _minimumPurchaseController.dispose();
    _maxUsageController.dispose();
    _productController.dispose();
    _serviceController.dispose();
    super.dispose();
  }

  bool _didInitDependencies = false;
  Offer? _editingOffer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didInitDependencies) return;

    final maybeOffer = ModalRoute.of(context)?.settings.arguments;
    if (maybeOffer is Offer) {
      _editingOffer = maybeOffer;
      _titleController.text = maybeOffer.title;
      _descriptionController.text = maybeOffer.description;
      _originalPriceController.text = maybeOffer.originalPrice.toString();
      _discountPriceController.text = maybeOffer.discountPrice.toString();
      _termsController.text = maybeOffer.terms ?? '';
      _startDate = maybeOffer.startDate;
      _endDate = maybeOffer.endDate;
      _selectedOfferType = maybeOffer.offerType;
      _selectedCategory = maybeOffer.offerCategory;

      if (maybeOffer.buyQuantity != null) {
        _buyQuantityController.text = maybeOffer.buyQuantity.toString();
      }
      if (maybeOffer.getQuantity != null) {
        _getQuantityController.text = maybeOffer.getQuantity.toString();
      }
      if (maybeOffer.percentageOff != null) {
        _percentageOffController.text = maybeOffer.percentageOff.toString();
      }
      if (maybeOffer.flatDiscountAmount != null) {
        _flatDiscountController.text = maybeOffer.flatDiscountAmount.toString();
      }
      if (maybeOffer.minimumPurchase != null) {
        _minimumPurchaseController.text = maybeOffer.minimumPurchase.toString();
      }
      if (maybeOffer.maxUsagePerCustomer != null) {
        _maxUsageController.text = maybeOffer.maxUsagePerCustomer.toString();
      }
      if (maybeOffer.applicableProducts != null) {
        _applicableProducts = List.from(maybeOffer.applicableProducts!);
      }
      if (maybeOffer.applicableServices != null) {
        _applicableServices = List.from(maybeOffer.applicableServices!);
      }

      if (maybeOffer.imageUrls != null) {
        _existingImageUrls = List.from(maybeOffer.imageUrls!);
      }
      _isEditing = true;
    }

    _didInitDependencies = true;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (newDate == null) return;

    setState(() {
      if (isStart) {
        _startDate = newDate;
        if (_endDate != null && _endDate!.isBefore(newDate)) {
          _endDate = newDate.add(const Duration(days: 7));
        }
      } else {
        _endDate = newDate;
      }
    });
  }

  void _addProduct() {
    if (_productController.text.trim().isNotEmpty) {
      setState(() {
        _applicableProducts.add(_productController.text.trim());
        _productController.clear();
      });
    }
  }

  void _addService() {
    if (_serviceController.text.trim().isNotEmpty) {
      setState(() {
        _applicableServices.add(_serviceController.text.trim());
        _serviceController.clear();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      _showError('End date should be after the start date.');
      return;
    }

    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    if (user == null) {
      _showError('Sign in required.');
      return;
    }

    final offerService = context.read<OfferService>();

    setState(() => _isSubmitting = true);
    try {
      if (_isEditing) {
        final offer = Offer(
          id: _editingOffer!.id,
          clientId: user.uid,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          originalPrice: double.parse(_originalPriceController.text.trim()),
          discountPrice: double.parse(_discountPriceController.text.trim()),
          status: OfferApprovalStatus.pending,
          offerType: _selectedOfferType,
          offerCategory: _selectedCategory,
          startDate: _startDate,
          endDate: _endDate,
          terms: _termsController.text.trim().isEmpty
              ? null
              : _termsController.text.trim(),
          buyQuantity: _buyQuantityController.text.isEmpty
              ? null
              : int.tryParse(_buyQuantityController.text),
          getQuantity: _getQuantityController.text.isEmpty
              ? null
              : int.tryParse(_getQuantityController.text),
          percentageOff: _percentageOffController.text.isEmpty
              ? null
              : double.tryParse(_percentageOffController.text),
          flatDiscountAmount: _flatDiscountController.text.isEmpty
              ? null
              : double.tryParse(_flatDiscountController.text),
          minimumPurchase: _minimumPurchaseController.text.isEmpty
              ? null
              : double.tryParse(_minimumPurchaseController.text),
          maxUsagePerCustomer: _maxUsageController.text.isEmpty
              ? null
              : int.tryParse(_maxUsageController.text),
          applicableProducts:
              _applicableProducts.isEmpty ? null : _applicableProducts,
          applicableServices:
              _applicableServices.isEmpty ? null : _applicableServices,
          imageUrls: _existingImageUrls,
          client: user.toJson(),
          createdAt: _editingOffer?.createdAt,
        );

        await offerService.updateOfferAdvanced(
          offer: offer,
          newImages: _images.isEmpty ? null : _images,
        );
      } else {
        final offer = Offer(
          id: '',
          clientId: user.uid,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          originalPrice: double.parse(_originalPriceController.text.trim()),
          discountPrice: double.parse(_discountPriceController.text.trim()),
          status: OfferApprovalStatus.pending,
          offerType: _selectedOfferType,
          offerCategory: _selectedCategory,
          startDate: _startDate,
          endDate: _endDate,
          terms: _termsController.text.trim().isEmpty
              ? null
              : _termsController.text.trim(),
          buyQuantity: _buyQuantityController.text.isEmpty
              ? null
              : int.tryParse(_buyQuantityController.text),
          getQuantity: _getQuantityController.text.isEmpty
              ? null
              : int.tryParse(_getQuantityController.text),
          percentageOff: _percentageOffController.text.isEmpty
              ? null
              : double.tryParse(_percentageOffController.text),
          flatDiscountAmount: _flatDiscountController.text.isEmpty
              ? null
              : double.tryParse(_flatDiscountController.text),
          minimumPurchase: _minimumPurchaseController.text.isEmpty
              ? null
              : double.tryParse(_minimumPurchaseController.text),
          maxUsagePerCustomer: _maxUsageController.text.isEmpty
              ? null
              : int.tryParse(_maxUsageController.text),
          applicableProducts:
              _applicableProducts.isEmpty ? null : _applicableProducts,
          applicableServices:
              _applicableServices.isEmpty ? null : _applicableServices,
          client: user.toJson(),
          createdAt: DateTime.now(),
        );

        await offerService.submitOfferAdvanced(
          offer: offer,
          images: _images.isEmpty ? null : _images,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      _showError('Could not ${_isEditing ? 'update' : 'submit'} offer: $error');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  String _getOfferTypeLabel(OfferType type) {
    switch (type) {
      case OfferType.percentageDiscount:
        return 'Percentage Discount (X% Off)';
      case OfferType.flatDiscount:
        return 'Flat Discount (₹X Off)';
      case OfferType.buyXGetYPercentOff:
        return 'Buy X Get Y% Off';
      case OfferType.buyXGetYRupeesOff:
        return 'Buy X Get ₹Y Off';
      case OfferType.bogo:
        return 'Buy One Get One (BOGO)';
      case OfferType.productSpecific:
        return 'Product-Specific Offer';
      case OfferType.serviceSpecific:
        return 'Service-Specific Offer';
      case OfferType.bundleDeal:
        return 'Bundle Deal';
    }
  }

  Widget _buildOfferTypeSpecificFields() {
    switch (_selectedOfferType) {
      case OfferType.percentageDiscount:
        return _buildPercentageDiscountFields();
      case OfferType.flatDiscount:
        return _buildFlatDiscountFields();
      case OfferType.buyXGetYPercentOff:
      case OfferType.buyXGetYRupeesOff:
        return _buildBuyXGetYFields();
      case OfferType.bogo:
        return _buildBOGOFields();
      case OfferType.productSpecific:
        return _buildProductSpecificFields();
      case OfferType.serviceSpecific:
        return _buildServiceSpecificFields();
      case OfferType.bundleDeal:
        return _buildBundleDealFields();
    }
  }

  Widget _buildPercentageDiscountFields() {
    return Column(
      children: [
        TextFormField(
          controller: _percentageOffController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: darkBlue),
          decoration: InputDecoration(
            labelText: 'Discount Percentage',
            labelStyle: TextStyle(color: darkBlue),
            hintText: 'e.g., 25 for 25% off',
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
              return 'Enter a valid percentage (1-100)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFlatDiscountFields() {
    return Column(
      children: [
        TextFormField(
          controller: _flatDiscountController,
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Discount amount is required';
            }
            final num = double.tryParse(value);
            if (num == null || num <= 0) {
              return 'Enter a valid amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBuyXGetYFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _buyQuantityController,
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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _getQuantityController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: darkBlue),
                decoration: InputDecoration(
                  labelText: 'Get Quantity',
                  labelStyle: TextStyle(color: darkBlue),
                  hintText: 'e.g., 1',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.card_giftcard, color: brightGold),
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
        ),
        const SizedBox(height: 16),
        if (_selectedOfferType == OfferType.buyXGetYPercentOff)
          TextFormField(
            controller: _percentageOffController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: darkBlue),
            decoration: InputDecoration(
              labelText: 'Percentage Off on "Get" Items',
              labelStyle: TextStyle(color: darkBlue),
              hintText: 'e.g., 50 for 50% off',
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
        if (_selectedOfferType == OfferType.buyXGetYRupeesOff)
          TextFormField(
            controller: _flatDiscountController,
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

  Widget _buildBOGOFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _buyQuantityController,
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
                controller: _getQuantityController,
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

  Widget _buildProductSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Applicable Products',
          style: TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _productController,
                style: TextStyle(color: darkBlue),
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  labelStyle: TextStyle(color: darkBlue),
                  hintText: 'e.g., Premium Coffee Beans',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon:
                      Icon(Icons.inventory_2_outlined, color: brightGold),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: brightGold,
                foregroundColor: darkBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_applicableProducts.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _applicableProducts.map((product) {
              return Chip(
                label: Text(product),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _applicableProducts.remove(product);
                  });
                },
                backgroundColor: brightGold.withValues(alpha: 0.2),
                labelStyle: TextStyle(color: darkBlue),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildServiceSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Applicable Services',
          style: TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _serviceController,
                style: TextStyle(color: darkBlue),
                decoration: InputDecoration(
                  labelText: 'Service Name',
                  labelStyle: TextStyle(color: darkBlue),
                  hintText: 'e.g., Hair Styling',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon:
                      Icon(Icons.design_services_outlined, color: brightGold),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addService,
              style: ElevatedButton.styleFrom(
                backgroundColor: brightGold,
                foregroundColor: darkBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_applicableServices.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _applicableServices.map((service) {
              return Chip(
                label: Text(service),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _applicableServices.remove(service);
                  });
                },
                backgroundColor: brightGold.withValues(alpha: 0.2),
                labelStyle: TextStyle(color: darkBlue),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildBundleDealFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bundle Items',
          style: TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _productController,
                style: TextStyle(color: darkBlue),
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  labelStyle: TextStyle(color: darkBlue),
                  hintText: 'e.g., Burger + Fries + Drink',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.shopping_basket, color: brightGold),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: brightGold,
                foregroundColor: darkBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_applicableProducts.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _applicableProducts.map((item) {
              return Chip(
                label: Text(item),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _applicableProducts.remove(item);
                  });
                },
                backgroundColor: brightGold.withValues(alpha: 0.2),
                labelStyle: TextStyle(color: darkBlue),
              );
            }).toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          toolbarHeight: 44,
          title: Row(
            children: [
              SizedBox(
                height: 28,
                child: Image.asset(
                  'images/logo/original/Text_without_logo_without_background.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          iconTheme: IconThemeData(color: darkBlue),
        ),
        body: Column(
          children: [
            // Title below stable AppBar
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Create offer',
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Divider(height: 1),
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Sign in required to create offers.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('EEE, d MMM yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 44,
        title: Row(
          children: [
            SizedBox(
              height: 28,
              child: Image.asset(
                'images/logo/original/Text_without_logo_without_background.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: darkBlue),
      ),
      body: Column(
        children: [
          // Title below stable AppBar
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              _isEditing ? 'Edit Offer' : 'Create New Offer',
              style: TextStyle(
                color: darkBlue,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [darkBlue, darkBlue.withValues(alpha: 0.8)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: darkBlue.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.campaign,
                                    color: brightGold, size: 32),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Create Amazing Offers',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Reach thousands of local customers',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Main Form Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Basic Information',
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _titleController,
                              style: TextStyle(color: darkBlue),
                              decoration: InputDecoration(
                                labelText: 'Offer Title *',
                                labelStyle: TextStyle(color: darkBlue),
                                hintText: 'e.g., Summer Sale - 50% Off',
                                hintStyle: const TextStyle(color: Colors.grey),
                                prefixIcon:
                                    Icon(Icons.title, color: brightGold),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: brightGold, width: 2),
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Offer title is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Image picker
                            Text(
                              'Offer Images',
                              style: TextStyle(
                                color: darkBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ..._images.map((img) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 12.0),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.file(
                                              File(img.path),
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _images.remove(img);
                                                });
                                              },
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(4),
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  InkWell(
                                    onTap: _pickImages,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color:
                                            brightGold.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: brightGold,
                                          width: 2,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate,
                                              color: brightGold, size: 32),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Add Photos',
                                            style: TextStyle(
                                              color: brightGold,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 4,
                              style: TextStyle(color: darkBlue),
                              decoration: InputDecoration(
                                labelText: 'Description *',
                                labelStyle: TextStyle(color: darkBlue),
                                alignLabelWithHint: true,
                                hintText:
                                    'Describe your offer in detail. What makes it special?',
                                hintStyle: const TextStyle(color: Colors.grey),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(bottom: 60),
                                  child: Icon(Icons.description_outlined,
                                      color: brightGold),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: brightGold, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Description is required';
                                }
                                if (value.trim().length < 20) {
                                  return 'Please provide at least 20 characters';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Offer Type Selection
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Offer Type',
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<OfferType>(
                              initialValue: _selectedOfferType,
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              style: TextStyle(color: darkBlue, fontSize: 15),
                              decoration: InputDecoration(
                                prefixIcon:
                                    Icon(Icons.local_offer, color: brightGold),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: brightGold, width: 2),
                                ),
                              ),
                              items: OfferType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(_getOfferTypeLabel(type)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedOfferType = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Offer Category
                            Text(
                              'Offer Category',
                              style: TextStyle(
                                color: darkBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<OfferCategory>(
                              initialValue: _selectedCategory,
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              style: TextStyle(color: darkBlue, fontSize: 15),
                              decoration: InputDecoration(
                                prefixIcon:
                                    Icon(Icons.category, color: brightGold),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: brightGold, width: 2),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: OfferCategory.product,
                                  child: Text('Product'),
                                ),
                                DropdownMenuItem(
                                  value: OfferCategory.service,
                                  child: Text('Service'),
                                ),
                                DropdownMenuItem(
                                  value: OfferCategory.both,
                                  child: Text('Both Product & Service'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 20),

                            // Type-specific fields
                            _buildOfferTypeSpecificFields(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Pricing
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pricing Details',
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _originalPriceController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    style: TextStyle(color: darkBlue),
                                    decoration: InputDecoration(
                                      labelText: 'Original Price (₹) *',
                                      labelStyle: TextStyle(color: darkBlue),
                                      hintText: '₹999',
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
                                      prefixIcon: Icon(
                                          Icons.currency_rupee_outlined,
                                          color: brightGold),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade200),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: brightGold, width: 2),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      final parsed =
                                          double.tryParse(value.trim());
                                      if (parsed == null || parsed <= 0) {
                                        return 'Enter valid price';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _discountPriceController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    style: TextStyle(color: darkBlue),
                                    decoration: InputDecoration(
                                      labelText: 'Offer Price (₹) *',
                                      labelStyle: TextStyle(color: darkBlue),
                                      hintText: '₹499',
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
                                      prefixIcon: Icon(
                                          Icons.local_offer_outlined,
                                          color: brightGold),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade200),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: brightGold, width: 2),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      final parsed =
                                          double.tryParse(value.trim());
                                      if (parsed == null || parsed <= 0) {
                                        return 'Enter valid price';
                                      }
                                      final original = double.tryParse(
                                        _originalPriceController.text.trim(),
                                      );
                                      if (original != null &&
                                          parsed >= original) {
                                        return 'Must be lower than original';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Additional Options
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Additional Options',
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _minimumPurchaseController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    style: TextStyle(color: darkBlue),
                                    decoration: InputDecoration(
                                      labelText: 'Min. Purchase (₹)',
                                      labelStyle: TextStyle(color: darkBlue),
                                      hintText: 'Optional',
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
                                      prefixIcon: Icon(
                                          Icons.shopping_cart_outlined,
                                          color: brightGold),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade200),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: brightGold, width: 2),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _maxUsageController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(color: darkBlue),
                                    decoration: InputDecoration(
                                      labelText: 'Max Usage/Customer',
                                      labelStyle: TextStyle(color: darkBlue),
                                      hintText: 'Optional',
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
                                      prefixIcon:
                                          Icon(Icons.repeat, color: brightGold),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade200),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: brightGold, width: 2),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _pickDate(isStart: true),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.event, color: brightGold),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Start Date',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _startDate != null
                                                      ? dateFormat
                                                          .format(_startDate!)
                                                      : 'Select date',
                                                  style: TextStyle(
                                                    color: darkBlue,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _pickDate(isStart: false),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.event_available,
                                              color: brightGold),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'End Date',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _endDate != null
                                                      ? dateFormat
                                                          .format(_endDate!)
                                                      : 'Select date',
                                                  style: TextStyle(
                                                    color: darkBlue,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _termsController,
                              maxLines: 3,
                              style: TextStyle(color: darkBlue),
                              decoration: InputDecoration(
                                labelText: 'Terms & Conditions',
                                labelStyle: TextStyle(color: darkBlue),
                                alignLabelWithHint: true,
                                hintText:
                                    'Optional: Add any special terms or conditions',
                                hintStyle: const TextStyle(color: Colors.grey),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(bottom: 40),
                                  child: Icon(Icons.article_outlined,
                                      color: brightGold),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: brightGold, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brightGold,
                            foregroundColor: darkBlue,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadowColor: brightGold.withValues(alpha: 0.5),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isEditing
                                          ? Icons.save_outlined
                                          : Icons.send_outlined,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _isSubmitting
                                          ? (_isEditing
                                              ? 'Updating...'
                                              : 'Submitting...')
                                          : (_isEditing
                                              ? 'Update Offer'
                                              : 'Submit for Review'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info text
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: darkBlue.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: darkBlue, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your offer will be reviewed by our team before going live. This usually takes 24-48 hours.',
                                style: TextStyle(
                                  color: darkBlue,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
