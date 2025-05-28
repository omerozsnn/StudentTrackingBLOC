import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_state.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'dart:async';

class StudentListItem extends StatefulWidget {
  final Student student;
  final bool isSelected;
  final VoidCallback onTap;

  const StudentListItem({
    Key? key,
    required this.student,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<StudentListItem> createState() => _StudentListItemState();
}

class _StudentListItemState extends State<StudentListItem> {
  bool _hasAttemptedImageLoad = false;
  bool _imageLoadFailed = false;
  Timer? _photoLoadTimer;
  StudentBloc? _cachedBloc;
  
  @override
  void initState() {
    super.initState();
    // Bloc referansını güvenli bir şekilde saklayalım
    _cachedBloc = context.read<StudentBloc>();
    
    // Immediately try to load image with a short delay to prevent UI blocking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPhotoIfNeeded();
    });
  }
  
  void _requestPhotoIfNeeded() {
    if (!_hasAttemptedImageLoad && !_imageLoadFailed && _cachedBloc != null && mounted) {
      // Mark as attempted to prevent multiple requests
      _hasAttemptedImageLoad = true;
      
      // Cancel any existing timer
      _photoLoadTimer?.cancel();
      
      // Use a small staggered delay to prevent all items from requesting simultaneously
      // This helps distribute network requests
      _photoLoadTimer = Timer(Duration(milliseconds: (widget.student.id * 17) % 800 + 100), () {
        if (mounted && _cachedBloc != null) {
          _cachedBloc!.add(GetStudentPhoto(widget.student.id));
        }
      });
    }
  }
  
  @override
  void dispose() {
    // Timer'ı iptal et
    _photoLoadTimer?.cancel();
    _photoLoadTimer = null;
    _cachedBloc = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.isSelected ? 4 : 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: widget.isSelected 
            ? const BorderSide(color: Color(0xFF6C8997), width: 2) 
            : BorderSide.none,
      ),
      color: widget.isSelected ? const Color(0xFF6C8997).withOpacity(0.2) : null,
      child: ListTile(
        leading: _buildStudentAvatar(),
        title: Text(
          '${widget.student.ogrenciNo ?? ''} - ${widget.student.adSoyad ?? 'Bilinmeyen İsim'}',
          style: TextStyle(
            fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: widget.onTap,
        selected: widget.isSelected,
        selectedTileColor: const Color(0xFF6C8997).withOpacity(0.1),
      ),
    );
  }

  Widget _buildStudentAvatar() {
    return BlocBuilder<StudentBloc, StudentState>(
      buildWhen: (previous, current) {
        // Only rebuild when the photo for this specific student is loaded
        if (current is StudentPhotoLoaded) {
          return current.studentId == widget.student.id;
        }
        // Or when we're in a loading state
        return current is StudentLoading;
      },
      builder: (context, state) {
        // Fotoğraf durumunu kontrol et
        Uint8List? photoData;
        bool isLoading = state is StudentLoading && !_hasAttemptedImageLoad;

        // Sadece StudentPhotoLoaded durumunu kontrol et, diğer durumları önemseme
        if (state is StudentPhotoLoaded && 
            state.studentId == widget.student.id) {
          photoData = state.photo;
          _hasAttemptedImageLoad = true;
        }

        // Resim henüz yüklenmediyse ve hata yoksa, yüklemeyi başlat
        if (photoData == null && !isLoading && !_hasAttemptedImageLoad && !_imageLoadFailed) {
          _requestPhotoIfNeeded();
        }

        // Yükleme durumunda spinner göster
        if (isLoading) {
          return const CircleAvatar(
            backgroundColor: Color(0xFF6C8997),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        // Resim varsa göster
        if (photoData != null) {
          return CircleAvatar(
            backgroundImage: MemoryImage(photoData),
            backgroundColor: Colors.grey.shade200,
            radius: 22,
            onBackgroundImageError: (exception, stackTrace) {
              // Resim görüntülenirken hata olursa, sessizce fallback'e geç
              if (mounted) {
                setState(() {
                  _imageLoadFailed = true;
                });
              }
              debugPrint('Resim gösterme hatası: $exception');
            },
            // Hata olma ihtimaline karşı fallback avatar hazırla
            child: _imageLoadFailed ? _buildInitialsWidget() : null,
          );
        }

        // Fotoğraf yoksa baş harfi göster
        return CircleAvatar(
          backgroundColor: const Color(0xFF6C8997),
          radius: 22,
          child: _buildInitialsWidget(),
        );
      },
    );
  }
  
  Widget _buildInitialsWidget() {
    // Get initials safely
    String initials = '?';
    if (widget.student.adSoyad != null && widget.student.adSoyad!.isNotEmpty) {
      final nameParts = widget.student.adSoyad!.split(' ');
      if (nameParts.isNotEmpty) {
        // Get first letter of first name
        initials = nameParts.first.isNotEmpty ? nameParts.first[0].toUpperCase() : '';
        // If there's a last name, add its first letter too
        if (nameParts.length > 1 && nameParts.last.isNotEmpty) {
          initials += nameParts.last[0].toUpperCase();
        }
      }
    }
    
    return Text(
      initials,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
} 