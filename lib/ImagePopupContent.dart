import 'dart:io';
import 'package:flutter/material.dart';

class ImagePopupContent extends StatefulWidget {
  final File? selectedImage;
  final String? currentImageUrl;
  final String baseUrl;

  const ImagePopupContent({
    Key? key,
    this.selectedImage,
    this.currentImageUrl,
    required this.baseUrl,
  }) : super(key: key);

  @override
  State<ImagePopupContent> createState() => _ImagePopupContentState();
}

class _ImagePopupContentState extends State<ImagePopupContent> {
  int currentIndex = 0;
  List<Map<String, dynamic>> images = [];
  bool isLoading = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() {
    setState(() {
      images = [];
      isLoading = true;
      hasError = false;

      // Mevcut seçilen resmi veya yüklenen resmi ekle
      if (widget.selectedImage != null) {
        images.add({
          'type': 'file',
          'source': widget.selectedImage,
        });
      } else if (widget.currentImageUrl != null) {
        // URL'yi olduğu gibi kullan - kdsEkle.dart tarafından doğru formatta oluşturulduğu varsayılıyor
        images.add({
          'type': 'url',
          'source': widget.currentImageUrl,
        });
      }

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Resimler yüklenirken bir hata oluştu'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadImages,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (images.isEmpty) {
      return const Center(child: Text('Henüz resim eklenmemiş'));
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageData = images[index];
              return Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: imageData['type'] == 'file'
                      ? Image.file(imageData['source'])
                      : Image.network(
                          imageData['source'].toString(),
                          errorBuilder: (context, error, stackTrace) {
                            print('Popup resim hatası: $error');
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.broken_image,
                                    size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text(
                                  'Resim yüklenemedi',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  'URL: ${imageData['source']}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 10),
                                ),
                              ],
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              );
            },
          ),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIndex == index
                        ? Colors.deepPurpleAccent
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${currentIndex + 1} / ${images.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
