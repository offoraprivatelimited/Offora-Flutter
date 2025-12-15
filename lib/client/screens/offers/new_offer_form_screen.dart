import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/offer.dart';
import '../../services/offer_service.dart';
import '../../../services/auth_service.dart';
import '../../../theme/colors.dart';

import '../../../widgets/premium_text_field.dart';
import '../../../widgets/gradient_button.dart';
import '../../../widgets/responsive_page.dart';
import '../../../widgets/loading_overlay.dart';
import 'models/image_models.dart';
import 'widgets/discount_fields_widgets.dart';
import 'widgets/advanced_discount_fields_widgets.dart';
import 'widgets/category_specific_fields_widgets.dart';
import 'widgets/image_preview_widget.dart';

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

  // Date fields
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  // Offer type and category
  late OfferType _selectedOfferType;
  late OfferCategory _selectedOfferCategory;
  late String _selectedBusinessCategory;
  late String _selectedCity;

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

    _selectedOfferType = OfferType.percentageDiscount;
    _selectedOfferCategory = OfferCategory.product;
    _selectedBusinessCategory = '';
    _selectedCity = '';
    _applicableProducts = [];
    _applicableServices = [];
    _existingImageUrls = [];
    _selectedImages = [];

    // If editing, populate with existing data
    if (widget.offerToEdit != null) {
      _populateFormWithExistingOffer(widget.offerToEdit!);
    }
  }

  void _populateFormWithExistingOffer(Offer offer) {
    _titleController.text = offer.title;
    _descriptionController.text = offer.description;
    _originalPriceController.text = offer.originalPrice.toString();
    _termsController.text = offer.terms ?? '';
    _selectedStartDate = offer.startDate;
    _selectedEndDate = offer.endDate;
    _selectedOfferType = offer.offerType;
    _selectedOfferCategory = offer.offerCategory;
    _selectedBusinessCategory = offer.businessCategory ?? '';
    _selectedCity = offer.city ?? '';
    _existingImageUrls = offer.imageUrls ?? [];

    if (offer.percentageOff != null) {
      _percentageOffController.text = offer.percentageOff.toString();
    }
    if (offer.flatDiscountAmount != null) {
      _flatDiscountController.text = offer.flatDiscountAmount.toString();
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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
    _termsController.dispose();
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

      // Build the Offer object
      final offer = Offer(
        id: widget.offerToEdit?.id ?? '',
        clientId: _clientId,
        title: _titleController.text,
        description: _descriptionController.text,
        originalPrice: double.parse(_originalPriceController.text),
        discountPrice: double.parse(_originalPriceController.text),
        status: OfferApprovalStatus.pending,
        offerType: _selectedOfferType,
        offerCategory: _selectedOfferCategory,
        businessCategory: _selectedBusinessCategory.isNotEmpty
            ? _selectedBusinessCategory
            : null,
        city: _selectedCity.isNotEmpty ? _selectedCity : null,
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
        applicableProducts:
            _applicableProducts.isNotEmpty ? _applicableProducts : null,
        applicableServices:
            _applicableServices.isNotEmpty ? _applicableServices : null,
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
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/client-main',
                            (route) => route.isFirst,
                          );
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
      child: Scaffold(
        body: ResponsivePage(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Section
                  _buildSectionTitle('Basic Information'),
                  const SizedBox(height: 16),
                  PremiumTextField(
                    controller: _titleController,
                    labelText: 'Offer Title',
                    hintText: 'e.g., Summer Sale',
                    prefixIcon: Icons.title,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  PremiumTextField(
                    controller: _descriptionController,
                    labelText: 'Description',
                    hintText: 'Describe your offer in detail',
                    prefixIcon: Icons.description,
                    maxLines: 4,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Description is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  PremiumTextField(
                    controller: _originalPriceController,
                    labelText: 'Original Price',
                    prefixIcon: Icons.currency_rupee,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Required';
                      }
                      if (double.tryParse(value!) == null) {
                        return 'Invalid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Offer Type Section
                  _buildSectionTitle('Offer Type'),
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
                  _buildSectionTitle('Offer Category'),
                  const SizedBox(height: 16),
                  _buildOfferCategoryDropdown(),
                  const SizedBox(height: 24),

                  // Location Section
                  _buildSectionTitle('Location'),
                  const SizedBox(height: 16),
                  _buildCityDropdown(),
                  const SizedBox(height: 24),

                  // Additional Options
                  _buildSectionTitle('Additional Options'),
                  const SizedBox(height: 16),
                  PremiumTextField(
                    controller: _minimumPurchaseController,
                    labelText: 'Minimum Purchase Amount (Optional)',
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
                    labelText: 'Max Usage Per Customer (Optional)',
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
                  _buildSectionTitle('Offer Validity'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _selectDate(true),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_selectedStartDate == null
                              ? 'Start Date'
                              : _selectedStartDate!.toString().split(' ')[0]),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brightGold,
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
                              ? 'End Date'
                              : _selectedEndDate!.toString().split(' ')[0]),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brightGold,
                            foregroundColor: AppColors.darkBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Terms & Conditions
                  _buildSectionTitle('Terms & Conditions (Optional)'),
                  const SizedBox(height: 16),
                  PremiumTextField(
                    controller: _termsController,
                    labelText: 'Terms & Conditions',
                    hintText: 'Add any terms or conditions for this offer',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  // Images Section
                  _buildSectionTitle('Offer Images'),
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
                  const SizedBox(height: 16),
                ],
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
    return DropdownButtonFormField<OfferType>(
      initialValue: _selectedOfferType,
      decoration: InputDecoration(
        labelText: 'Select Offer Type',
        prefixIcon: const Icon(Icons.local_offer, color: AppColors.darkBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildOfferCategoryDropdown() {
    return DropdownButtonFormField<OfferCategory>(
      initialValue: _selectedOfferCategory,
      decoration: InputDecoration(
        labelText: 'Select Category',
        prefixIcon: const Icon(Icons.category, color: AppColors.darkBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildCityDropdown() {
    // Get user's city from their profile
    final auth = context.read<AuthService>();
    final userCity = auth.currentUser?.location ?? '';

    // Initialize city with user's city if not already set
    if (_selectedCity.isEmpty && userCity.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedCity = userCity;
        });
      });
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedCity.isNotEmpty ? _selectedCity : null,
      decoration: InputDecoration(
        labelText: 'Location/City',
        hintText: 'Select your business location',
        prefixIcon: const Icon(Icons.location_on, color: AppColors.darkBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dropdownColor: Colors.white,
      items: _generateCityList().map((city) {
        return DropdownMenuItem(
          value: city,
          child: Text(
            city,
            style: const TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCity = value ?? '';
        });
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please select a city' : null,
    );
  }

  List<String> _generateCityList() {
    // List of major Indian cities
    return [
      'Andhra Pradesh',
      'Arunachal Pradesh',
      'Assam',
      'Bihar',
      'Chhattisgarh',
      'Goa',
      'Gujarat',
      'Haryana',
      'Himachal Pradesh',
      'Jharkhand',
      'Karnataka',
      'Kerala',
      'Madhya Pradesh',
      'Maharashtra',
      'Manipur',
      'Meghalaya',
      'Mizoram',
      'Nagaland',
      'Odisha',
      'Punjab',
      'Rajasthan',
      'Sikkim',
      'Tamil Nadu',
      'Telangana',
      'Tripura',
      'Uttar Pradesh',
      'Uttarakhand',
      'West Bengal',
      'Chandigarh',
      'Delhi',
      'Ladakh',
      'Lakshadweep',
      'Puducherry',
      'Andaman and Nicobar Islands',
      'Dadra and Nagar Haveli',
      'Daman and Diu',
    ]..sort();
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
