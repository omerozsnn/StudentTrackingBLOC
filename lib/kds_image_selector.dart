import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api.dart/kdsResimleriApiService.dart';

class KDSImageSelector extends StatefulWidget {
  final int? kdsId;
  final Function(List<File>) onImagesSelected;
  final String baseUrl;

  const KDSImageSelector({
    Key? key,
    this.kdsId,
    required this.onImagesSelected,
    required this.baseUrl,
  }) : super(key: key);

  @override
  State<KDSImageSelector> createState() => _KDSImageSelectorState();
}

class _KDSImageSelectorState extends State<KDSImageSelector> {
  final KDSResimleriApiService _apiService =
      KDSResimleriApiService(baseUrl: 'http://localhost:3000');
  final ImagePicker _picker = ImagePicker();

  List<File> _selectedImages = [];
  List<dynamic> _existingImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingImages();
  }

  @override
  void didUpdateWidget(KDSImageSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.kdsId != widget.kdsId) {
      _loadExistingImages();
    }
  }

  Future<void> _loadExistingImages() async {
    if (widget.kdsId == null) {
      setState(() {
        _existingImages = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final images = await _apiService.getImagesByKDS(widget.kdsId!);
      setState(() {
        _existingImages = images;
        _isLoading = false;
      });
    } catch (e) {
      print('Resimler yüklenemedi: $e');
      setState(() {
        _existingImages = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resimler yüklenemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        List<File> newFiles = images.map((xFile) => File(xFile.path)).toList();

        setState(() {
          _selectedImages.addAll(newFiles);
        });

        widget.onImagesSelected(_selectedImages);
      }
    } catch (e) {
      print("Resimler seçilirken hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resimler seçilirken bir hata oluştu.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    widget.onImagesSelected(_selectedImages);
  }

  Future<void> _removeExistingImage(int imageId, int index) async {
    try {
      await _apiService.deleteKDSResim(imageId);

      setState(() {
        _existingImages.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resim başarıyla silindi.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Resim silinemedi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resim silinemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showImageFullScreen(BuildContext context, dynamic image) async {
    String? imageUrl;
    Widget imageWidget;

    if (image is File) {
      imageWidget = Image.file(image);
    } else {
      // Var olan resimler için
      imageUrl = _apiService.getKDSResimUrl(image['id']);
      imageWidget = Image.network(
        imageUrl,
        errorBuilder: (context, error, stackTrace) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Resim yüklenemedi',
                  style: TextStyle(color: Colors.grey)),
              Text('URL: $imageUrl',
                  style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          );
        },
      );
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'KDS Soru Resmi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Center(child: imageWidget),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Minimum yükseklik al
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KDS Soru Resimleri',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library, size: 18),
                label: const Text('Resim Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade100,
                  foregroundColor: Colors.deepPurple.shade700,
                  textStyle: const TextStyle(fontSize: 13),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Yükleniyor göstergesi
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          // Resim yok ise mesaj göster
          else if (_existingImages.isEmpty && _selectedImages.isEmpty)
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 32,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Soru resimleri eklemek için tıklayınız',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          // Özet bilgilerle resim durumu göster
          else
            Row(
              children: [
                if (_existingImages.isNotEmpty)
                  _buildImageInfoCard(
                    'Mevcut Resimler',
                    _existingImages.length,
                    Icons.photo_library,
                    Colors.teal,
                    true,
                  ),
                const SizedBox(width: 16),
                if (_selectedImages.isNotEmpty)
                  _buildImageInfoCard(
                    'Yeni Seçilen Resimler',
                    _selectedImages.length,
                    Icons.add_photo_alternate,
                    Colors.deepPurple,
                    false,
                  ),
              ],
            ),
        ],
      ),
    );
  }

// Resim sayısını gösteren kart widget'ı
  Widget _buildImageInfoCard(
      String title, int count, IconData icon, Color color, bool isExisting) {
    return Expanded(
      child: InkWell(
        onTap: () => _showAllImages(isExisting),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, color: color),
                    ),
                    Text(
                      '$count resim',
                      style: TextStyle(
                          fontSize: 12, color: color.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Tüm resimleri görmek için dialog
  void _showAllImages(bool isExisting) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                isExisting ? 'Mevcut Resimler' : 'Yeni Seçilen Resimler',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: isExisting
                      ? _existingImages.length
                      : _selectedImages.length,
                  itemBuilder: (context, index) {
                    return _buildImageTile(
                      isExisting
                          ? _existingImages[index]
                          : _selectedImages[index],
                      index,
                      isExisting,
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kapat'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageTile(dynamic image, int index, bool isExisting) {
    Widget imageWidget;

    if (isExisting) {
      final String imageUrl = _apiService.getKDSResimUrl(image['id']);
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      imageWidget = Image.file(
        image,
        fit: BoxFit.cover,
      );
    }

    return Stack(
      children: [
        InkWell(
          onTap: () => _showImageFullScreen(context, image),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageWidget,
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: InkWell(
            onTap: () {
              if (isExisting) {
                _removeExistingImage(image['id'], index);
              } else {
                _removeSelectedImage(index);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
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
        if (isExisting)
          Positioned(
            bottom: 2,
            left: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Sıra: ${image['order'] ?? index + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}
