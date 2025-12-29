import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/image_models.dart';

/// Widget for building and displaying image previews with options to add/remove images
class ImagePreviewWidget extends StatelessWidget {
  final List<String> existingImageUrls;
  final List<SelectedImage> selectedImages;
  final VoidCallback onPickImages;
  final VoidCallback onCaptureImage;
  final Function(int) onRemoveSelectedImage;
  final Function(int) onRemoveExistingImage;
  final Color darkBlue;
  final Color brightGold;

  const ImagePreviewWidget({
    super.key,
    required this.existingImageUrls,
    required this.selectedImages,
    required this.onPickImages,
    required this.onCaptureImage,
    required this.onRemoveSelectedImage,
    required this.onRemoveExistingImage,
    required this.darkBlue,
    required this.brightGold,
  });

  @override
  Widget build(BuildContext context) {
    final allImages = [
      ...existingImageUrls.map((url) => ImageItem(url: url, isExisting: true)),
      ...selectedImages
          .map((image) => ImageItem(localImage: image, isExisting: false)),
    ];

    if (allImages.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildImageGrid(allImages),
        const SizedBox(height: 16),
        _buildImageActionButtons(),
        const SizedBox(height: 8),
        _buildImageInfoText(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: brightGold.withValues(alpha: 80 / 255.0), width: 2),
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
              color: brightGold.withValues(alpha: 40 / 255.0),
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
          const SizedBox(height: 24),
          _buildImageActionButtons(),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<ImageItem> allImages) {
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
                    onRemoveExistingImage(index);
                  } else {
                    final adjustedIndex = index - existingImageUrls.length;
                    onRemoveSelectedImage(adjustedIndex);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.9),
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

  Widget _buildImageActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onPickImages,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: darkBlue,
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: brightGold, width: 2),
              ),
            ),
            icon: Icon(Icons.photo_library, color: brightGold),
            label: const Text(
              'Choose from Gallery',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onCaptureImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: brightGold,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: Icon(Icons.camera_alt, color: darkBlue),
            label: const Text(
              'Camera',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageInfoText() {
    return Text(
      'Supported formats: JPG, PNG, WebP. Max size: 5MB per image. You can add up to 10 images.',
      style: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 12,
      ),
    );
  }
}
