import 'dart:typed_data';

/// Represents a selected image with its bytes and metadata
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

/// Represents an image item that can be either from URL or local selection
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
