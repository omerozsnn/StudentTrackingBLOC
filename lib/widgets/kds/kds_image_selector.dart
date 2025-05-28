import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds/kds_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds/kds_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds/kds_state.dart';
import 'package:ogrenci_takip_sistemi/models/kds_model.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';

class KDSImageSelector extends StatefulWidget {
  final int? kdsId;
  final List<KDSImage>? initialImages;
  final Function(List<File>) onImagesSelected;

  const KDSImageSelector({
    Key? key,
    this.kdsId,
    this.initialImages,
    required this.onImagesSelected,
  }) : super(key: key);

  @override
  _KDSImageSelectorState createState() => _KDSImageSelectorState();
}

class _KDSImageSelectorState extends State<KDSImageSelector> {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  List<KDSImage> _existingImages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialImages != null) {
      _existingImages = widget.initialImages!;
    } else if (widget.kdsId != null) {
      _loadExistingImages();
    }
  }

  @override
  void didUpdateWidget(KDSImageSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.kdsId != oldWidget.kdsId ||
        widget.initialImages != oldWidget.initialImages) {
      if (widget.initialImages != null) {
        setState(() {
          _existingImages = widget.initialImages!;
        });
      } else if (widget.kdsId != null) {
        _loadExistingImages();
      } else {
        setState(() {
          _existingImages = [];
        });
      }
    }
  }

  void _loadExistingImages() {
    if (widget.kdsId == null) return;

    setState(() => _loading = true);

    BlocProvider.of<KDSBloc>(context).add(LoadKDSImages(widget.kdsId!));
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        final files = pickedFiles.map((xFile) => File(xFile.path)).toList();
        setState(() {
          _selectedImages.addAll(files);
        });
        widget.onImagesSelected(_selectedImages);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resim seçilirken bir hata oluştu: $e')),
      );
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    widget.onImagesSelected(_selectedImages);
  }

  void _removeExistingImage(KDSImage image) {
    if (widget.kdsId == null || image.id == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resmi Sil'),
        content: const Text('Bu resmi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              BlocProvider.of<KDSBloc>(context).add(DeleteKDSImage(image.id!));
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getImageUrl(KDSImage image) {
    if (image.id == null) return '';
    final kdsBloc = BlocProvider.of<KDSBloc>(context);
    return kdsBloc.repository.getKDSImageUrl(image.id!);
  }

  Widget _buildImagePreview() {
    return BlocListener<KDSBloc, KDSState>(
      listener: (context, state) {
        if (state is KDSImagesLoaded) {
          setState(() {
            _existingImages = state.kdsImages;
            _loading = false;
          });
        } else if (state is KDSOperationSuccess) {
          if (state.message.contains('resmi başarıyla silindi')) {
            setState(() {
              _existingImages = state.kdsImages;
            });
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.image,
                color: Colors.deepPurple.shade400,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                "KDS Resimleri",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text("Resim Ekle"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_existingImages.isEmpty && _selectedImages.isEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  "Henüz resim yok. Resim eklemek için 'Resim Ekle' butonuna tıklayın.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_existingImages.isNotEmpty) ...[
                  Text(
                    "Mevcut Resimler",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _existingImages.length,
                      itemBuilder: (context, index) {
                        final image = _existingImages[index];
                        return Card(
                          margin: const EdgeInsets.only(right: 8),
                          elevation: 2,
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () => UIHelpers.showImageDialog(
                                  context,
                                  _getImageUrl(image),
                                  isNetworkImage: true,
                                ),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    image: DecorationImage(
                                      image: NetworkImage(_getImageUrl(image)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeExistingImage(image),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_selectedImages.isNotEmpty) ...[
                  Text(
                    "Eklenecek Yeni Resimler",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        final file = _selectedImages[index];
                        return Card(
                          margin: const EdgeInsets.only(right: 8),
                          elevation: 2,
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () => UIHelpers.showImageDialog(
                                  context,
                                  file.path,
                                  isNetworkImage: false,
                                ),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    image: DecorationImage(
                                      image: FileImage(file),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeSelectedImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
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
      child: _buildImagePreview(),
    );
  }
}
