import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../models/offer.dart';
import '../../services/offer_service.dart';
import '../dashboard/manage_offers_screen.dart';

class NewOfferFormScreen extends StatefulWidget {
  const NewOfferFormScreen({super.key});

  static const String routeName = '/offers/new-advanced';

  @override
  State<NewOfferFormScreen> createState() => _NewOfferFormScreenState();
}

class _NewOfferFormScreenState extends State<NewOfferFormScreen> {
  bool _redirectingToLogin = false;
  Offer? _editingOffer;
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
  final bool _isEditing = false;
  final List<String> _existingImageUrls = [];
  final List<SelectedImage> _selectedImages = [];
  OfferType _selectedOfferType = OfferType.percentageDiscount;
  OfferCategory _selectedCategory = OfferCategory.product;
  final List<String> _applicableProducts = [];
  final List<String> _applicableServices = [];

  final darkBlue = const Color(0xFF1F477D);
  final brightGold = const Color(0xFFF0B84D);
  final ImagePicker _imagePicker = ImagePicker();

  // Helper to check if minimum purchase applies to category
  bool get _showMinimumPurchase => _selectedCategory != OfferCategory.service;
  bool get _isPercentageOffer =>
      _selectedOfferType == OfferType.percentageDiscount;

  double? _computedPercentageDiscountPrice() {
    if (!_isPercentageOffer) return null;
    final original = double.tryParse(_originalPriceController.text.trim());
    final percentage = double.tryParse(_percentageOffController.text.trim());

    if (original == null || original <= 0) return null;
    if (percentage == null || percentage <= 0 || percentage > 100) return null;

    final discounted = original * (1 - (percentage / 100));
    return double.parse(discounted.toStringAsFixed(2));
  }

  void _syncComputedDiscountPrice() {
    if (!_isPercentageOffer) return;
    final computed = _computedPercentageDiscountPrice();
    if (computed != null) {
      _discountPriceController.text = computed.toStringAsFixed(2);
    } else {
      _discountPriceController.clear();
    }
  }

  Future<SelectedImage> _toSelectedImage(XFile xFile) async {
    final bytes = await xFile.readAsBytes();
    final ext = _extensionFromName(xFile.name);

    return SelectedImage(
      bytes: bytes,
      fileName: xFile.name.isNotEmpty
          ? xFile.name
          : 'image_${DateTime.now().millisecondsSinceEpoch}',
      mimeType: _mimeTypeFromExtension(ext),
    );
  }

  String _buildStorageFileName(SelectedImage image, int index) {
    final ext = _extensionFromName(image.fileName) ?? 'jpg';
    return 'offer_${DateTime.now().millisecondsSinceEpoch}_$index.$ext';
  }

  String? _extensionFromName(String name) {
    final parts = name.split('.');
    if (parts.length < 2) return null;
    final ext = parts.last.toLowerCase();
    const allowed = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'];
    return allowed.contains(ext) ? ext : null;
  }

  String? _mimeTypeFromExtension(String? ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return null;
    }
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        if (_selectedImages.length + pickedFiles.length > 10) {
          _showError('Maximum 10 images allowed');
          return;
        }

        final newImages = await Future.wait(
          pickedFiles.map((xFile) => _toSelectedImage(xFile)),
        );

        setState(() {
          _selectedImages.addAll(newImages);
        });
      }
    } catch (e) {
      _showError('Failed to pick images: $e');
    }
  }

  Future<void> _captureImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (_selectedImages.length >= 10) {
          _showError('Maximum 10 images allowed');
          return;
        }

        final image = await _toSelectedImage(pickedFile);

        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
    }
  }

  Future<List<String>> _uploadImagesToFirebase(
    String userId,
    String offerId,
  ) async {
    if (_selectedImages.isEmpty) return [];

    final storage = FirebaseStorage.instance;
    final List<String> uploadedUrls = [];

    try {
      for (int i = 0; i < _selectedImages.length; i++) {
        final image = _selectedImages[i];
        final fileName = _buildStorageFileName(image, i);
        final storagePath = 'offers/$userId/$offerId/$fileName';

        final ref = storage.ref().child(storagePath);
        final uploadTask = ref.putData(
          image.bytes,
          SettableMetadata(contentType: image.mimeType ?? 'image/jpeg'),
        );

        uploadTask.snapshotEvents.listen((snapshot) {
          final progress =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          debugPrint('Upload progress: ${progress.toStringAsFixed(2)}%');
        });

        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        uploadedUrls.add(downloadUrl);
      }
    } catch (e, stack) {
      debugPrint('Error uploading images: $e');
      debugPrint('Stack trace: $stack');
      if (e is FirebaseException) {
        debugPrint('FirebaseException code: \\${e.code}');
        debugPrint('FirebaseException message: \\${e.message}');
        debugPrint('FirebaseException details: \\${e.details}');
      }
      throw Exception('Failed to upload images: $e');
    }

    return uploadedUrls;
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

  Widget _buildImagePreview() {
    final allImages = [
      ..._existingImageUrls.map((url) => ImageItem(url: url, isExisting: true)),
      ..._selectedImages
          .map((image) => ImageItem(localImage: image, isExisting: false)),
    ];

    if (allImages.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: brightGold.withAlpha(80), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(18 / 255.0),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: brightGold.withOpacity(40 / 255.0),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(18),
              child: Icon(Icons.photo_library, color: darkBlue, size: 54),
            ),
            const SizedBox(height: 18),
            Text(
              'No Images Added',
              style: TextStyle(
                color: darkBlue,
                fontWeight: FontWeight.w600,
                fontSize: 17,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload up to 10 images to showcase your offer',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: allImages.length,
      itemBuilder: (context, index) {
        final item = allImages[index];
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.isExisting
                    ? CachedNetworkImage(
                        imageUrl: item.url!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image),
                        ),
                      )
                    : Image.memory(
                        item.localImage!.bytes,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  if (item.isExisting) {
                    _removeExistingImage(index);
                  } else {
                    final adjustedIndex = index - _existingImageUrls.length;
                    _removeSelectedImage(adjustedIndex);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
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
      final originalPrice = double.parse(_originalPriceController.text.trim());
      double discountPrice;

      if (_isPercentageOffer) {
        final computed = _computedPercentageDiscountPrice();
        if (computed == null) {
          _showError('Enter valid original price and discount percentage.');
          setState(() => _isSubmitting = false);
          return;
        }
        discountPrice = computed;
        _discountPriceController.text = computed.toStringAsFixed(2);
      } else {
        discountPrice = double.parse(_discountPriceController.text.trim());
      }

      if (_isEditing) {
        final offer = Offer(
          id: _editingOffer!.id,
          clientId: user.uid,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          originalPrice: originalPrice,
          discountPrice: discountPrice,
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

        List<String> newImageUrls = [];
        if (_selectedImages.isNotEmpty) {
          newImageUrls = await _uploadImagesToFirebase(user.uid, offer.id);
        }

        debugPrint('[DEBUG] Submitting edited offer with images:');
        debugPrint(offer.toJson().toString());

        await offerService.updateOfferAdvanced(
          offer: offer.copyWith(
            imageUrls: [..._existingImageUrls, ...newImageUrls],
          ),
        );
      } else {
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();

        List<String> imageUrls = [];
        if (_selectedImages.isNotEmpty) {
          imageUrls = await _uploadImagesToFirebase(user.uid, tempId);
        }

        final offer = Offer(
          id: '',
          clientId: user.uid,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          originalPrice: originalPrice,
          discountPrice: discountPrice,
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
          imageUrls: imageUrls,
          client: user.toJson(),
          createdAt: DateTime.now(),
        );

        debugPrint('[DEBUG] Submitting new offer with images:');
        debugPrint(offer.toJson().toString());

        await offerService.submitOfferAdvanced(offer: offer);
      }

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.celebration, color: brightGold, size: 56),
                const SizedBox(height: 16),
                Text(
                  'Offer Submitted!',
                  style: TextStyle(
                    color: darkBlue,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your offer has been submitted for review and is now pending approval.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: darkBlue, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brightGold,
                    foregroundColor: darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                  ),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Go to My Offers'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      );
      if (mounted) {
        // Replace with your actual manage offers page route and pass a param to show pending section
        Navigator.of(context).pushReplacementNamed(
          ManageOffersScreen.routeName,
          arguments: {'section': 'pending'},
        );
      }
    } catch (error, stack) {
      debugPrint('[ERROR] Offer submit failed: $error');
      debugPrint('[ERROR] Stack trace: $stack');
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
          onChanged: (_) => setState(_syncComputedDiscountPrice),
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
            color: brightGold.withOpacity(0.1),
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
                backgroundColor: brightGold.withOpacity(0.2),
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
                backgroundColor: brightGold.withOpacity(0.2),
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
      if (!_redirectingToLogin) {
        _redirectingToLogin = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            ManageOffersScreen.routeName,
            (route) => false,
          );
        });
      }
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final dateFormat = DateFormat('EEE, d MMM yyyy');

    return Column(
      children: [
        Expanded(
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
                        colors: [darkBlue, darkBlue.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: darkBlue.withOpacity(0.3),
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
                            Icon(Icons.campaign, color: brightGold, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
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
                          color: Colors.black.withOpacity(0.05),
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
                            prefixIcon: Icon(Icons.title, color: brightGold),
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

                        // ...existing code...

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

                        const SizedBox(height: 18),

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
                                'Offer Images',
                                style: TextStyle(
                                  color: darkBlue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Add up to 10 images to showcase your offer',
                                style: TextStyle(
                                  color: darkBlue.withOpacity(180 / 255.0),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildImagePreview(),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _pickImages,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: darkBlue,
                                        elevation: 2,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                            horizontal:
                                                8), // reduced horizontal padding
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          side: BorderSide(
                                              color: brightGold, width: 2),
                                        ),
                                      ),
                                      icon: Icon(Icons.photo_library,
                                          color: brightGold),
                                      label: const Text('Choose from Gallery',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 12), // slightly reduced spacing
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _captureImage,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: brightGold,
                                        foregroundColor: Colors.white,
                                        elevation: 2,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                            horizontal:
                                                8), // reduced horizontal padding
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      icon: Icon(Icons.camera_alt,
                                          color: darkBlue),
                                      label: const Text('Camera',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Supported formats: JPG, PNG, WebP. Max size: 5MB per image. You can add up to 10 images.',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
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
                                if (_isPercentageOffer) {
                                  _syncComputedDiscountPrice();
                                } else {
                                  _discountPriceController.clear();
                                }
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Offer Category
                        Text(
                          'What are you offering? *',
                          style: TextStyle(
                            color: darkBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: brightGold.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: darkBlue, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Choose to see relevant fields for your offer type',
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<OfferCategory>(
                          initialValue: _selectedCategory,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          style: TextStyle(color: darkBlue, fontSize: 15),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.category, color: brightGold),
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
                              child: Text('Product (e.g., Food, Electronics)'),
                            ),
                            DropdownMenuItem(
                              value: OfferCategory.service,
                              child: Text('Service (e.g., Haircut, Repair)'),
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
                          'Pricing Details (Required)',
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'All prices are mandatory and must be valid amounts',
                          style: TextStyle(
                            color: darkBlue.withOpacity(0.6),
                            fontSize: 13,
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
                                onChanged: (_) {
                                  if (_isPercentageOffer) {
                                    setState(_syncComputedDiscountPrice);
                                  }
                                },
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
                                    return 'Required';
                                  }
                                  final parsed = double.tryParse(value.trim());
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
                                readOnly: _isPercentageOffer,
                                decoration: InputDecoration(
                                  labelText: _isPercentageOffer
                                      ? 'Offer Price (Auto)'
                                      : 'Offer Price (₹) *',
                                  labelStyle: TextStyle(color: darkBlue),
                                  hintText: _isPercentageOffer
                                      ? 'Calculated from percentage'
                                      : '₹499',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  prefixIcon: Icon(Icons.local_offer_outlined,
                                      color: brightGold),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  helperText: _isPercentageOffer
                                      ? 'Auto-calculated using original price and discount %'
                                      : null,
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
                                  if (_isPercentageOffer) {
                                    final computed =
                                        _computedPercentageDiscountPrice();
                                    if (computed == null) {
                                      return 'Enter valid original price and %';
                                    }
                                    return null;
                                  }
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  final parsed = double.tryParse(value.trim());
                                  if (parsed == null || parsed <= 0) {
                                    return 'Enter valid price';
                                  }
                                  final original = double.tryParse(
                                    _originalPriceController.text.trim(),
                                  );
                                  if (original != null && parsed >= original) {
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

                  // Additional Options (Category-specific)
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
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: brightGold.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: darkBlue, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedCategory == OfferCategory.service
                                      ? 'All fields below are optional'
                                      : 'Min purchase applies only to products',
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Minimum Purchase - Only for Products
                        if (_showMinimumPurchase)
                          Column(
                            children: [
                              TextFormField(
                                controller: _minimumPurchaseController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                style: TextStyle(color: darkBlue),
                                decoration: InputDecoration(
                                  labelText: 'Min. Purchase Amount (₹)',
                                  labelStyle: TextStyle(color: darkBlue),
                                  hintText: 'Optional - e.g., 500',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  prefixIcon: Icon(Icons.shopping_cart_outlined,
                                      color: brightGold),
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
                              const SizedBox(height: 16),
                            ],
                          ),
                        // Max Usage Per Customer - For All
                        TextFormField(
                          controller: _maxUsageController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: darkBlue),
                          decoration: InputDecoration(
                            labelText: 'Max Usage Per Customer',
                            labelStyle: TextStyle(color: darkBlue),
                            hintText: 'Optional - e.g., 3',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: Icon(Icons.repeat, color: brightGold),
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
                        const SizedBox(height: 16),
                        // Validity Dates Section
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: brightGold.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: darkBlue, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Start & End dates are optional',
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                                    border:
                                        Border.all(color: Colors.grey.shade200),
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
                                                  : 'Optional',
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
                                    border:
                                        Border.all(color: Colors.grey.shade200),
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
                                                  ? dateFormat.format(_endDate!)
                                                  : 'Optional',
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
                            labelText: 'Terms & Conditions (Optional)',
                            labelStyle: TextStyle(color: darkBlue),
                            alignLabelWithHint: true,
                            hintText:
                                'e.g., Valid on Sundays only, Cannot be combined with other offers',
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
                        shadowColor: brightGold.withOpacity(0.5),
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
                      color: darkBlue.withOpacity(0.05),
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
      ],
    );
  }
}

extension on FirebaseException {
  get details => null;
}

class SelectedImage {
  SelectedImage({
    required this.bytes,
    required this.fileName,
    this.mimeType,
  });

  final Uint8List bytes;
  final String fileName;
  final String? mimeType;
}

class ImageItem {
  ImageItem({
    this.url,
    this.localImage,
    required this.isExisting,
  }) : assert(
          (url != null && localImage == null) ||
              (url == null && localImage != null),
        );

  final String? url;
  final SelectedImage? localImage;
  final bool isExisting;
}
