import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import '../../models/offer.dart';
import '../../services/offer_service.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/theme/colors.dart';

import '../../../../shared/widgets/premium_text_field.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../core/utils/keyboard_utils.dart';
import 'models/image_models.dart';
import 'widgets/discount_fields_widgets.dart';
import 'widgets/advanced_discount_fields_widgets.dart';
import 'widgets/category_specific_fields_widgets.dart';
import 'widgets/image_preview_widget.dart';
import 'dart:convert' as convert;

class NewOfferFormScreen extends StatefulWidget {
  final String? clientId;
  final Offer? offerToEdit;

  const NewOfferFormScreen({
    super.key,
    this.clientId,
    this.offerToEdit,
  }) : super();

  static const String routeName = '/new-offer';

  @override
  State<NewOfferFormScreen> createState() => _NewOfferFormScreenState();
}

class _NewOfferFormScreenState extends State<NewOfferFormScreen> {
  late GlobalKey<FormState> _formKey;
  late OfferService _offerService;
  late String _clientId;

  // Basic fields
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _originalPriceController;
  late TextEditingController _termsController;
  late TextEditingController _addressController;
  late TextEditingController _contactNumberController;

  // Date fields
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  // Offer type and category
  late OfferType _selectedOfferType;
  late OfferCategory _selectedOfferCategory;
  late String _selectedBusinessCategory;
  late String _selectedCity;

  // City autocomplete
  late TextEditingController _cityController;
  TextEditingController? _autocompleteCityController;
  VoidCallback? _autocompleteListener;
  List<String> _citySuggestions = [];

  // Business category autocomplete
  late TextEditingController _businessCategoryController;
  TextEditingController? _autocompleteBusinessCategoryController;
  VoidCallback? _autocompleteBCListener;
  List<String> _businessCategorySuggestions = [];

  // Business categories from signup
  final List<String> _categories = const [
    'Grocery',
    'Supermarket',
    'Restaurant',
    'Cafe & Bakery',
    'Pharmacy',
    'Electronics',
    'Mobile & Accessories',
    'Fashion & Apparel',
    'Footwear',
    'Jewelry',
    'Home Decor',
    'Furniture',
    'Hardware',
    'Automotive',
    'Books & Stationery',
    'Toys & Games',
    'Sports & Fitness',
    'Beauty & Cosmetics',
    'Salon & Spa',
    'Pet Supplies',
    'Dairy & Produce',
    'Electronics Repair',
    'Optical',
    'Travel & Tours',
    'Department Store',
    'Other',
  ];

  // Discount fields
  late TextEditingController _percentageOffController;
  late TextEditingController _flatDiscountController;

  // Advanced discount fields (for Buy X Get Y)
  late TextEditingController _buyQuantityController;
  late TextEditingController _getQuantityController;
  late TextEditingController _advancedPercentageController;
  late TextEditingController _advancedFlatDiscountController;

  // Product/Service specific fields
  late TextEditingController _productController;
  late TextEditingController _serviceController;
  late List<String> _applicableProducts;
  late List<String> _applicableServices;

  // Additional fields
  late TextEditingController _minimumPurchaseController;
  late TextEditingController _maxUsagePerCustomerController;
  late TextEditingController _keywordsController;
  late List<String> _keywords;

  // Image handling
  late List<String> _existingImageUrls;
  late List<SelectedImage> _selectedImages;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _offerService = OfferService();

    // Initialize clientId from widget parameter or from AuthService
    _clientId = widget.clientId ?? '';
    if (_clientId.isEmpty) {
      final auth = context.read<AuthService>();
      _clientId = auth.currentUser?.uid ?? '';
    }

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _originalPriceController = TextEditingController();
    _termsController = TextEditingController();
    _addressController = TextEditingController();
    _contactNumberController = TextEditingController();
    _percentageOffController = TextEditingController();
    _flatDiscountController = TextEditingController();
    _buyQuantityController = TextEditingController();
    _getQuantityController = TextEditingController();
    _advancedPercentageController = TextEditingController();
    _advancedFlatDiscountController = TextEditingController();
    _productController = TextEditingController();
    _serviceController = TextEditingController();
    _minimumPurchaseController = TextEditingController();
    _maxUsagePerCustomerController = TextEditingController();
    _keywordsController = TextEditingController();
    _keywords = [];

    _selectedOfferType = OfferType.percentageDiscount;
    _selectedOfferCategory = OfferCategory.product;
    _selectedBusinessCategory = '';
    _selectedCity = '';
    _cityController = TextEditingController();
    _businessCategoryController = TextEditingController();
    _businessCategorySuggestions = _categories;
    _applicableProducts = [];
    _applicableServices = [];
    _existingImageUrls = [];
    _selectedImages = [];

    _fetchCities();

    // If editing, populate with existing data
    if (widget.offerToEdit != null) {
      _populateFormWithExistingOffer(widget.offerToEdit!);
    }
  }

  Future<void> _fetchCities() async {
    try {
      final res =
          await Future.delayed(const Duration(milliseconds: 500), () async {
        return await http.post(
          Uri.parse('https://countriesnow.space/api/v0.1/countries/cities'),
          headers: {'Content-Type': 'application/json'},
          body: '{"country": "India"}',
        );
      });
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = convert.jsonDecode(res.body);
        final List<dynamic> cities = data['data'] ?? [];
        if (mounted) {
          setState(() {
            _citySuggestions = List<String>.from(cities);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _citySuggestions = [];
        });
      }
    }
  }

  void _populateFormWithExistingOffer(Offer offer) {
    _titleController.text = offer.title;
    _descriptionController.text = offer.description;
    _originalPriceController.text = offer.originalPrice.toString();
    _termsController.text = offer.terms ?? '';
    _addressController.text = offer.address ?? '';
    _contactNumberController.text = offer.contactNumber ?? '';
    _selectedStartDate = offer.startDate;
    _selectedEndDate = offer.endDate;
    _selectedOfferType = offer.offerType;
    _selectedOfferCategory = offer.offerCategory;
    _selectedBusinessCategory = offer.businessCategory ?? '';
    _businessCategoryController.text = offer.businessCategory ?? '';
    _selectedCity = offer.city ?? '';
    _cityController.text = offer.city ?? '';
    _existingImageUrls = offer.imageUrls ?? [];

    if (offer.percentageOff != null) {
      _percentageOffController.text = offer.percentageOff.toString();
    }
    if (offer.flatDiscountAmount != null) {
      _flatDiscountController.text = offer.flatDiscountAmount.toString();
    }
    if (offer.getPercentage != null) {
      _advancedPercentageController.text = offer.getPercentage.toString();
    }
    if (offer.buyQuantity != null) {
      _buyQuantityController.text = offer.buyQuantity.toString();
    }
    if (offer.getQuantity != null) {
      _getQuantityController.text = offer.getQuantity.toString();
    }
    if (offer.minimumPurchase != null) {
      _minimumPurchaseController.text = offer.minimumPurchase.toString();
    }
    if (offer.maxUsagePerCustomer != null) {
      _maxUsagePerCustomerController.text =
          offer.maxUsagePerCustomer.toString();
    }

    _applicableProducts = offer.applicableProducts ?? [];
    _applicableServices = offer.applicableServices ?? [];
    _keywords = offer.keywords ?? [];
    if (_keywords.isNotEmpty) {
      _keywordsController.text = _keywords.join(', ');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
    _termsController.dispose();
    _addressController.dispose();
    _contactNumberController.dispose();
    _percentageOffController.dispose();
    _flatDiscountController.dispose();
    _buyQuantityController.dispose();
    _getQuantityController.dispose();
    _advancedPercentageController.dispose();
    _advancedFlatDiscountController.dispose();
    _productController.dispose();
    _serviceController.dispose();
    _minimumPurchaseController.dispose();
    _maxUsagePerCustomerController.dispose();
    _keywordsController.dispose();
    _cityController.dispose();
    _businessCategoryController.dispose();
    if (_autocompleteCityController != null && _autocompleteListener != null) {
      _autocompleteCityController!.removeListener(_autocompleteListener!);
      _autocompleteListener = null;
      _autocompleteCityController = null;
    }
    if (_autocompleteBusinessCategoryController != null &&
        _autocompleteBCListener != null) {
      _autocompleteBusinessCategoryController!
          .removeListener(_autocompleteBCListener!);
      _autocompleteBCListener = null;
      _autocompleteBusinessCategoryController = null;
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      for (var file in pickedFiles) {
        final bytes = await file.readAsBytes();
        _selectedImages.add(
          SelectedImage(
            bytes: bytes,
            fileName: file.name,
            mimeType: 'image/jpeg',
          ),
        );
      }
      setState(() {});
    }
  }

  Future<void> _captureImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      final bytes = await photo.readAsBytes();
      _selectedImages.add(
        SelectedImage(
          bytes: bytes,
          fileName: photo.name,
          mimeType: 'image/jpeg',
        ),
      );
      setState(() {});
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  void _addProduct() {
    if (_productController.text.isNotEmpty) {
      setState(() {
        _applicableProducts.add(_productController.text);
        _productController.clear();
      });
    }
  }

  void _addService() {
    if (_serviceController.text.isNotEmpty) {
      setState(() {
        _applicableServices.add(_serviceController.text);
        _serviceController.clear();
      });
    }
  }

  List<String>? _parseKeywords() {
    final text = _keywordsController.text.trim();
    if (text.isEmpty) return null;
    final keywords = text
        .split(',')
        .map((k) => k.trim().toLowerCase())
        .where((k) => k.isNotEmpty)
        .toList();
    return keywords.isNotEmpty ? keywords : null;
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_selectedStartDate ?? DateTime.now())
          : (_selectedEndDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
        } else {
          _selectedEndDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
      return;
    }

    // Validate that dates are selected
    if (_selectedStartDate == null || _selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload new images to Firebase Storage and get their URLs
      final newImageUrls = <String>[];
      if (_selectedImages.isNotEmpty) {
        for (final image in _selectedImages) {
          try {
            final fileName =
                'offers/$_clientId/${DateTime.now().millisecondsSinceEpoch}_${image.fileName}';
            final ref = FirebaseStorage.instance.ref().child(fileName);
            await ref.putData(image.bytes);
            final url = await ref.getDownloadURL();
            newImageUrls.add(url);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Error uploading image: $e');
            }
          }
        }
      }

      // Combine existing and new image URLs
      final allImageUrls = [..._existingImageUrls, ...newImageUrls];

      // Validate and parse prices
      final originalPrice = _originalPriceController.text.isNotEmpty
          ? double.tryParse(_originalPriceController.text)
          : null;
      if (_originalPriceController.text.isNotEmpty && originalPrice == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid original price'),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Build the Offer object
      final offer = Offer(
        id: widget.offerToEdit?.id ?? '',
        clientId: _clientId,
        title: _titleController.text,
        description: _descriptionController.text,
        originalPrice: originalPrice ?? 0,
        discountPrice: originalPrice ?? 0,
        status: OfferApprovalStatus.pending,
        offerType: _selectedOfferType,
        offerCategory: _selectedOfferCategory,
        businessCategory: _selectedBusinessCategory.isNotEmpty
            ? _selectedBusinessCategory
            : null,
        city: _selectedCity.isNotEmpty ? _selectedCity : null,
        address:
            _addressController.text.isNotEmpty ? _addressController.text : null,
        contactNumber: _contactNumberController.text.isNotEmpty
            ? '+91${_contactNumberController.text.trim().replaceAll(RegExp(r'[^0-9]'), '')}'
            : null,
        imageUrls: allImageUrls,
        terms: _termsController.text.isNotEmpty ? _termsController.text : null,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        createdAt: widget.offerToEdit?.createdAt ?? DateTime.now(),
        percentageOff: _percentageOffController.text.isNotEmpty
            ? double.tryParse(_percentageOffController.text)
            : null,
        flatDiscountAmount: _flatDiscountController.text.isNotEmpty
            ? double.tryParse(_flatDiscountController.text)
            : null,
        buyQuantity: _buyQuantityController.text.isNotEmpty
            ? int.tryParse(_buyQuantityController.text)
            : null,
        getQuantity: _getQuantityController.text.isNotEmpty
            ? int.tryParse(_getQuantityController.text)
            : null,
        getPercentage: _advancedPercentageController.text.isNotEmpty
            ? double.tryParse(_advancedPercentageController.text)
            : null,
        applicableProducts:
            _applicableProducts.isNotEmpty ? _applicableProducts : null,
        applicableServices:
            _applicableServices.isNotEmpty ? _applicableServices : null,
        keywords: _parseKeywords(),
      );

      // Submit the offer
      await _offerService.submitOfferAdvanced(offer: offer);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF0D9488).withAlpha((0.1 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF0D9488),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Offer Submitted Successfully!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your offer has been submitted for approval.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Close dialog first
                      Navigator.of(dialogContext).pop();
                      // Navigate to ClientMainScreen to show ManageOffersScreen with AppBar and BottomNavBar
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          context.goNamed('client-dashboard');
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5136F0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Manage Offers',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: GestureDetector(
        onTap: () => KeyboardUtils.dismissKeyboard(context),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: ResponsivePage(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const ClampingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.darkBlue.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.offerToEdit == null
                                ? '✨ Create New Offer'
                                : '✏️ Edit Offer',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkBlue,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Fill in all required fields (*) to create your offer',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Basic Information Section
                    _buildSectionTitle('📋 Basic Details'),
                    const SizedBox(height: 8),
                    Text(
                      'Tell customers what you\'re offering',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    PremiumTextField(
                      controller: _titleController,
                      labelText: 'Offer Title *',
                      hintText: 'e.g., 50% Off Laptops, Buy 1 Get 1 Free',
                      prefixIcon: Icons.title,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter offer title'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    PremiumTextField(
                      controller: _descriptionController,
                      labelText: 'Description *',
                      hintText:
                          'What\'s included? Example: Valid on winter clothes, excludes sale items',
                      prefixIcon: Icons.description,
                      maxLines: 4,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please describe the offer'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    PremiumTextField(
                      controller: _originalPriceController,
                      labelText: 'Original Price (optional)',
                      hintText: 'Regular price before discount',
                      prefixIcon: Icons.currency_rupee,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            double.tryParse(value) == null) {
                          return 'Enter valid price (e.g., 999.50)';
                        }
                        // No required validation
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Offer Type Section
                    _buildSectionTitle('💰 How Much Discount?'),
                    const SizedBox(height: 16),
                    _buildOfferTypeDropdown(),
                    const SizedBox(height: 24),

                    // Discount Details Section
                    if (_selectedOfferType == OfferType.percentageDiscount)
                      _buildPercentageDiscountSection(),
                    if (_selectedOfferType == OfferType.flatDiscount)
                      _buildFlatDiscountSection(),
                    if (_selectedOfferType == OfferType.buyXGetYPercentOff ||
                        _selectedOfferType == OfferType.buyXGetYRupeesOff ||
                        _selectedOfferType == OfferType.bogo)
                      _buildAdvancedDiscountSection(),
                    if (_selectedOfferType == OfferType.productSpecific)
                      _buildProductSpecificSection(),
                    if (_selectedOfferType == OfferType.serviceSpecific)
                      _buildServiceSpecificSection(),

                    const SizedBox(height: 24),

                    // Offer Category
                    _buildSectionTitle('📂 What Type of Offer?'),
                    const SizedBox(height: 16),
                    _buildOfferCategoryDropdown(),
                    const SizedBox(height: 24),

                    // Business Category Section
                    _buildSectionTitle('🏪 What Industry Are You In?'),
                    const SizedBox(height: 16),
                    _buildBusinessCategoryDropdown(),
                    const SizedBox(height: 24),

                    // Location Section
                    _buildSectionTitle('📍 Where is Your Shop?'),
                    const SizedBox(height: 16),
                    _buildCityDropdown(),
                    const SizedBox(height: 16),
                    PremiumTextField(
                      controller: _addressController,
                      labelText: 'Address *',
                      hintText: 'Full address of your shop/location',
                      prefixIcon: Icons.location_on,
                      maxLines: 2,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter your address'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactNumberController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter contact number';
                        }
                        if (value!.length < 10) {
                          return 'Contact number must be 10 digits';
                        }
                        return null;
                      },
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: AppColors.darkBlue,
                      decoration: InputDecoration(
                        labelText: 'Contact Number *',
                        hintText: 'Enter 10-digit mobile number',
                        labelStyle: const TextStyle(
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '+91',
                                style: TextStyle(
                                  color: AppColors.darkBlue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '|',
                                style: TextStyle(
                                  color: Color(0xFFE0E0E0),
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.darkBlue,
                            width: 1.1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.darkBlue,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Additional Options
                    _buildSectionTitle('⚙️ Extra Rules (Optional)'),
                    const SizedBox(height: 8),
                    Text(
                      'Add conditions for your offer',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    PremiumTextField(
                      controller: _minimumPurchaseController,
                      labelText: 'Minimum Purchase Amount',
                      hintText: 'Customer must buy at least this (e.g., 500)',
                      prefixIcon: Icons.shopping_cart,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value?.isNotEmpty ?? false) {
                          if (double.tryParse(value!) == null) {
                            return 'Invalid amount';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    PremiumTextField(
                      controller: _maxUsagePerCustomerController,
                      labelText: 'How Many Times Can Customer Use?',
                      hintText: 'Maximum times per customer (e.g., 1, 2, 5)',
                      prefixIcon: Icons.person,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isNotEmpty ?? false) {
                          if (int.tryParse(value!) == null) {
                            return 'Invalid number';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Date Section
                    Row(
                      children: [
                        Text(
                          '📅 When is the Offer Active?',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkBlue,
                                  ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '*',
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select start and end dates',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectDate(true),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(_selectedStartDate == null
                                ? 'Pick Start Date'
                                : _selectedStartDate!.toString().split(' ')[0]),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedStartDate == null
                                  ? Colors.red.shade100
                                  : AppColors.brightGold,
                              foregroundColor: AppColors.darkBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectDate(false),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(_selectedEndDate == null
                                ? 'Pick End Date'
                                : _selectedEndDate!.toString().split(' ')[0]),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedEndDate == null
                                  ? Colors.red.shade100
                                  : AppColors.brightGold,
                              foregroundColor: AppColors.darkBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Terms & Conditions
                    _buildSectionTitle('📝 Rules & Restrictions (Optional)'),
                    const SizedBox(height: 8),
                    Text(
                      'Any special conditions customers should know',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    PremiumTextField(
                      controller: _termsController,
                      labelText: 'Terms & Conditions',
                      hintText:
                          'Example: Not valid with other offers, Only for registered members',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    // Keywords Section
                    _buildSectionTitle('🔍 Search Keywords (Optional)'),
                    const SizedBox(height: 8),
                    Text(
                      'Help customers find your offer easily',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    PremiumTextField(
                      controller: _keywordsController,
                      labelText: 'Keywords',
                      hintText:
                          'Separate keywords with commas • Example: buy one get one, BOGO, electronics, gadgets, summer sale',
                      prefixIcon: Icons.search,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),

                    // Images Section
                    _buildSectionTitle('🖼️ Add Photos'),
                    const SizedBox(height: 16),
                    ImagePreviewWidget(
                      existingImageUrls: _existingImageUrls,
                      selectedImages: _selectedImages,
                      onPickImages: _pickImages,
                      onCaptureImage: _captureImage,
                      onRemoveSelectedImage: _removeSelectedImage,
                      onRemoveExistingImage: _removeExistingImage,
                      darkBlue: AppColors.darkBlue,
                      brightGold: AppColors.brightGold,
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    GradientButton(
                      label: widget.offerToEdit == null
                          ? 'Create Offer'
                          : 'Update Offer',
                      onPressed: _submitForm,
                      isLoading: _isLoading,
                    ),
                    // Add bottom padding for keyboard
                    const KeyboardBottomPadding(minPadding: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.darkBlue,
      ),
    );
  }

  Widget _buildOfferTypeDropdown() {
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<OfferType>(
        initialValue: _selectedOfferType,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Select Discount Type *',
          hintText: 'Choose how customers save',
          prefixIcon: const Icon(Icons.local_offer, color: AppColors.darkBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBlue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBlue, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBlue, width: 2.5),
          ),
        ),
        dropdownColor: Colors.white,
        items: OfferType.values.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(
              _formatEnumName(type.name),
              style: const TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedOfferType = value!;
          });
        },
      ),
    );
  }

  Widget _buildOfferCategoryDropdown() {
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<OfferCategory>(
        initialValue: _selectedOfferCategory,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Are You Selling Products or Services? *',
          hintText: 'Products (like clothes) or Services (like haircut)',
          prefixIcon: const Icon(Icons.category, color: AppColors.darkBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBlue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBlue, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBlue, width: 2.5),
          ),
        ),
        dropdownColor: Colors.white,
        items: OfferCategory.values.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(
              _formatEnumName(category.name),
              style: const TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedOfferCategory = value!;
          });
        },
      ),
    );
  }

  Widget _buildBusinessCategoryDropdown() {
    return SizedBox(
      width: double.infinity,
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        child: Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return _businessCategorySuggestions.where((category) => category
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: Container(
                  width: 300,
                  color: Colors.white,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Text(
                            option,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          fieldViewBuilder:
              (context, categoryFieldController, focusNode, onFieldSubmitted) {
            _autocompleteBusinessCategoryController ??= categoryFieldController;
            if (_autocompleteBusinessCategoryController!.text !=
                _businessCategoryController.text) {
              _autocompleteBusinessCategoryController!.text =
                  _businessCategoryController.text;
              _autocompleteBusinessCategoryController!.selection =
                  _businessCategoryController.selection;
            }
            if (_autocompleteBCListener == null) {
              _autocompleteBCListener = () {
                if (_autocompleteBusinessCategoryController != null &&
                    _businessCategoryController.text !=
                        _autocompleteBusinessCategoryController!.text) {
                  _businessCategoryController.text =
                      _autocompleteBusinessCategoryController!.text;
                  _businessCategoryController.selection =
                      _autocompleteBusinessCategoryController!.selection;
                }
              };
              _autocompleteBusinessCategoryController!
                  .addListener(_autocompleteBCListener!);
            }
            return TextFormField(
              controller: categoryFieldController,
              focusNode: focusNode,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Business Category *',
                hintText: 'Type or select category (e.g., Grocery, Restaurant)',
                prefixIcon:
                    const Icon(Icons.business, color: AppColors.darkBlue),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.darkBlue, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a business category';
                }
                return null;
              },
            );
          },
          onSelected: (String selection) {
            setState(() {
              _selectedBusinessCategory = selection;
              _businessCategoryController.text = selection;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return SizedBox(
      width: double.infinity,
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        child: Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty || _citySuggestions.isEmpty) {
              return const Iterable<String>.empty();
            }
            return _citySuggestions.where((city) => city
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: Container(
                  width: 300,
                  color: Colors.white,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Text(
                            option,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          fieldViewBuilder:
              (context, cityFieldController, focusNode, onFieldSubmitted) {
            // Keep a single listener attached to the Autocomplete controller
            _autocompleteCityController ??= cityFieldController;
            // initialize content
            if (_autocompleteCityController!.text != _cityController.text) {
              _autocompleteCityController!.text = _cityController.text;
              _autocompleteCityController!.selection =
                  _cityController.selection;
            }
            // Attach a single listener and store it so it can be removed on dispose
            if (_autocompleteListener == null) {
              _autocompleteListener = () {
                if (_autocompleteCityController != null &&
                    _cityController.text != _autocompleteCityController!.text) {
                  _cityController.text = _autocompleteCityController!.text;
                  _cityController.selection =
                      _autocompleteCityController!.selection;
                }
              };
              _autocompleteCityController!.addListener(_autocompleteListener!);
            }
            return TextFormField(
              controller: cityFieldController,
              focusNode: focusNode,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'City/Town *',
                hintText: 'Type city name (e.g., Mumbai, Delhi, Bangalore)',
                prefixIcon: const Icon(Icons.location_city_outlined,
                    color: AppColors.darkBlue),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.darkBlue, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a city';
                }
                return null;
              },
            );
          },
          onSelected: (String selection) {
            setState(() {
              _selectedCity = selection;
              _cityController.text = selection;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPercentageDiscountSection() {
    return Column(
      children: [
        PercentageDiscountFields(
          percentageOffController: _percentageOffController,
          onPercentageChanged: (value) {},
          darkBlue: AppColors.darkBlue,
          brightGold: AppColors.brightGold,
          isEditing: widget.offerToEdit != null,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFlatDiscountSection() {
    return Column(
      children: [
        FlatDiscountFields(
          flatDiscountController: _flatDiscountController,
          darkBlue: AppColors.darkBlue,
          brightGold: AppColors.brightGold,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAdvancedDiscountSection() {
    return Column(
      children: [
        BuyXGetYFields(
          buyQuantityController: _buyQuantityController,
          getQuantityController: _getQuantityController,
          percentageOffController: _advancedPercentageController,
          flatDiscountController: _advancedFlatDiscountController,
          selectedOfferType: _selectedOfferType,
          darkBlue: AppColors.darkBlue,
          brightGold: AppColors.brightGold,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProductSpecificSection() {
    return Column(
      children: [
        ProductSpecificFields(
          productController: _productController,
          applicableProducts: _applicableProducts,
          darkBlue: AppColors.darkBlue,
          brightGold: AppColors.brightGold,
          onAddProduct: _addProduct,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildServiceSpecificSection() {
    return Column(
      children: [
        ServiceSpecificFields(
          serviceController: _serviceController,
          applicableServices: _applicableServices,
          darkBlue: AppColors.darkBlue,
          brightGold: AppColors.brightGold,
          onAddService: _addService,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _formatEnumName(String name) {
    return name
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
