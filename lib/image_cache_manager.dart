import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Image Cache Manager sınıfı
class StudentImageCache {
  static final StudentImageCache _instance = StudentImageCache._internal();
  factory StudentImageCache() => _instance;
  StudentImageCache._internal();

  final Map<int, Uint8List> _cache = {};
  final Map<int, DateTime> _cacheTimestamps = {};
  final Duration _cacheExpiration = const Duration(minutes: 30);

  void addToCache(int studentId, Uint8List imageData) {
    _cache[studentId] = imageData;
    _cacheTimestamps[studentId] = DateTime.now();
  }

  Uint8List? getFromCache(int studentId) {
    final timestamp = _cacheTimestamps[studentId];
    if (timestamp == null) return null;

    if (DateTime.now().difference(timestamp) > _cacheExpiration) {
      // Cache süresi dolmuş, temizle
      _cache.remove(studentId);
      _cacheTimestamps.remove(studentId);
      return null;
    }

    return _cache[studentId];
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  void removeFromCache(int studentId) {
    _cache.remove(studentId);
    _cacheTimestamps.remove(studentId);
  }
}

// Öğrenci resmi widget'ı
// Şekil seçenekleri için enum
enum StudentImageShape {
  circle,
  rectangle,
}

class StudentImageWidget extends StatefulWidget {
  final int studentId;
  final double width; // Genişlik için yeni parametre
  final double height; // Yükseklik için yeni parametre
  final StudentImageShape shape; // Şekil için yeni parametre
  final VoidCallback? onTap;
  final BoxFit fit; // Resim yerleşimi için yeni parametre

  const StudentImageWidget({
    Key? key,
    required this.studentId,
    this.width = 40,
    this.height = 40,
    this.shape = StudentImageShape.circle,
    this.onTap,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<StudentImageWidget> createState() => _StudentImageWidgetState();
}

class _StudentImageWidgetState extends State<StudentImageWidget> {
  final StudentImageCache _imageCache = StudentImageCache();
  bool _isLoading = false;
  Uint8List? _imageData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // First check cache
      _imageData = _imageCache.getFromCache(widget.studentId);

      if (_imageData == null) {
        try {
          final response = await http.get(
            Uri.parse('http://localhost:3000/student/${widget.studentId}/image'),
          ).timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            _imageData = response.bodyBytes;
            _imageCache.addToCache(widget.studentId, _imageData!);
          } else if (response.statusCode == 404 || response.statusCode == 500) {
            // 404 Not Found veya 500 Server Error - normal bir durum, sessizce ele alalım
            print('Status ${response.statusCode} error when loading image for student ${widget.studentId}. Using placeholder.');
            // Bildirim atmaya gerek yok, placeholder kullanacağız
          } else {
            // Diğer durum kodları için hata fırlat
            throw Exception('Failed to load image: ${response.statusCode}');
          }
        } catch (e) {
          // Ağ hatalarını logla ama UI'da gösterme
          print('Network error when loading student image: $e');
          // Placeholder image kullanacağız
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Resim yüklenemedi';
        });
      }
      print('Error loading student image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  BorderRadius _getBorderRadius() {
    switch (widget.shape) {
      case StudentImageShape.circle:
        return BorderRadius.circular(widget.width / 2);
      case StudentImageShape.rectangle:
        return BorderRadius.circular(
            8); // Köşeleri hafif yuvarlatılmış dikdörtgen
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: _getBorderRadius(),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: _getBorderRadius(),
          child: _buildImageContent(),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (_isLoading) {
      return Center(
        child: SizedBox(
          width: widget.width / 3,
          height: widget.height / 3,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
    }

    if (_imageData != null) {
      return Image.memory(
        _imageData!,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    }

    return _buildErrorPlaceholder();
  }

  Widget _buildErrorPlaceholder() {
    String? displayMessage;
    if (_errorMessage != null && _errorMessage!.isNotEmpty) {
      displayMessage = _errorMessage;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: min(widget.width, widget.height) * 0.5,
            color: Colors.grey.shade400,
          ),
          if (displayMessage != null && widget.width > 60)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                displayMessage,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
        ],
      ),
    );
  }
}
