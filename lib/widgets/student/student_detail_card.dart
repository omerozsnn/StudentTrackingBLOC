import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_state.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';
import 'dart:io';
import 'dart:async';

class StudentDetailCard extends StatefulWidget {
  final Student student;
  final String? className;

  const StudentDetailCard({
    Key? key,
    required this.student,
    this.className,
  }) : super(key: key);
  
  @override
  State<StudentDetailCard> createState() => _StudentDetailCardState();
}

class _StudentDetailCardState extends State<StudentDetailCard> {
  bool _hasRequestedPhoto = false;
  Timer? _photoLoadTimer;
  StudentBloc? _cachedBloc;
  
  @override
  void initState() {
    super.initState();
    _cachedBloc = context.read<StudentBloc>();
    // Immediately ensure photo request when widget initializes
    debugPrint("StudentDetailCard initialized for student: ${widget.student.adSoyad}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPhotoIfNeeded();
    });
  }
  
  void _requestPhotoIfNeeded() {
    if (!_hasRequestedPhoto && _cachedBloc != null && mounted) {
      _hasRequestedPhoto = true;
      debugPrint("Requesting photo for student ID: ${widget.student.id}");
      _cachedBloc!.add(GetStudentPhoto(widget.student.id));
    }
  }
  
  @override
  void dispose() {
    _photoLoadTimer?.cancel();
    _photoLoadTimer = null;
    _cachedBloc = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Öğrenci Bilgileri',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C8997),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildBasicInfoCard(context),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Fotoğraf Container'ı
              _buildPhotoContainer(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temel Bilgiler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C8997),
              ),
            ),
            const SizedBox(height: 16),
            UIHelpers.buildDetailTextField(
                'TC Kimlik', widget.student.tcKimlik?.toString() ?? ''),
            UIHelpers.buildDetailTextField('Ad Soyad', widget.student.adSoyad ?? ''),
            UIHelpers.buildDetailTextField(
                'Öğrenci No', widget.student.ogrenciNo?.toString() ?? ''),
            UIHelpers.buildDetailTextField('Sınıf', widget.className ?? ''),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showDetailModal(context),
              icon: const Icon(Icons.info_outline),
              label: const Text('Detaylı Bilgileri Görüntüle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C8997),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoContainer(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: BlocBuilder<StudentBloc, StudentState>(
              buildWhen: (previous, current) {
                // Sadece ilgili durumlar için yeniden oluştur
                if (current is StudentPhotoLoaded) {
                  return current.studentId == widget.student.id;
                }
                return current is StudentLoading;
              },
              builder: (context, state) {
                // Fotoğraf kontrolü
                Uint8List? photoData;
                bool isLoading = state is StudentLoading;
                
                // Check if we have a photo in the state
                if (state is StudentPhotoLoaded && state.studentId == widget.student.id) {
                  photoData = state.photo;
                  debugPrint("Photo loaded for student: ${widget.student.adSoyad}");
                }
                
                // If we are waiting for a photo to load, make sure timer is not triggered again
                if (!_hasRequestedPhoto && !isLoading && _cachedBloc != null) {
                  _requestPhotoIfNeeded();
                }
                
                // Yükleme durumunda spinner göster
                if (isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                // Resim verisi varsa göster
                if (photoData != null) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          photoData,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            // Hata durumunda fallback avatar göster
                            return _buildInitialsAvatar();
                          },
                        ),
                      ),
                      // Resmin üstünde düzenleme butonu
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.7),
                          radius: 16,
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _uploadStudentImage(context),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                
                // Resim yoksa baş harfleri göster
                return _buildInitialsAvatar();
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _uploadStudentImage(context),
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Fotoğraf Yükle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C8997),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInitialsAvatar() {
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
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF6C8997).withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C8997),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadStudentImage(BuildContext context) async {
    try {
      final imagePicker = ImagePicker();
      final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        UIHelpers.showErrorMessage(context, 'Resim seçilmedi.');
        return;
      }

      // Kullanıcıya geri bildirim göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fotoğraf yükleniyor...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // BLoC ile fotoğraf yükleme
      if (_cachedBloc != null && mounted) {
        _cachedBloc!.add(UploadStudentPhoto(widget.student.id, File(image.path)));
      }
    } catch (e) {
      // Hata durumunu daha iyi yönet
      debugPrint("Fotoğraf seçme hatası: $e");
      if (mounted) {
        UIHelpers.showErrorMessage(context, 'Fotoğraf seçilirken bir hata oluştu: $e');
      }
    }
  }

  void _showDetailModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6C8997),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.student.adSoyad ?? "Öğrenci"} - Detaylı Bilgiler',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: DefaultTabController(
                    length: 4,
                    child: Column(
                      children: [
                        const TabBar(
                          labelColor: Color(0xFF6C8997),
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(icon: Icon(Icons.person), text: "Öğrenci"),
                            Tab(icon: Icon(Icons.woman), text: "Anne"),
                            Tab(icon: Icon(Icons.man), text: "Baba"),
                            Tab(icon: Icon(Icons.family_restroom), text: "Veli/Diğer"),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Öğrenci Tab
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    UIHelpers.buildDetailTextField('Cinsiyet', widget.student.cinsiyeti ?? ''),
                                    UIHelpers.buildDetailTextField(
                                      'Doğum Tarihi',
                                      widget.student.dogumTarihi ?? '',
                                    ),
                                    UIHelpers.buildDetailTextField('Yaş', widget.student.yasi?.toString() ?? ''),
                                  ],
                                ),
                              ),
                              // Anne Tab
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    UIHelpers.buildDetailTextField('Anne Adı', widget.student.anneAdi ?? ''),
                                    UIHelpers.buildDetailTextField('Anne Cep Telefonu', widget.student.anneCepTelefonu ?? ''),
                                    UIHelpers.buildDetailTextField('Anne İş Telefonu', widget.student.anneIsTelefonu ?? ''),
                                    UIHelpers.buildDetailTextField('Anne İş Adresi', widget.student.anneIsAdresi ?? ''),
                                    UIHelpers.buildDetailTextField('Anne Eğitim Durumu', widget.student.anneEgitimDurumu ?? ''),
                                  ],
                                ),
                              ),
                              // Baba Tab
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    UIHelpers.buildDetailTextField('Baba Adı', widget.student.babaAdi ?? ''),
                                    UIHelpers.buildDetailTextField('Baba Cep Telefonu', widget.student.babaCepTelefonu ?? ''),
                                    UIHelpers.buildDetailTextField('Baba Mesleği', widget.student.babaMeslegiIsi ?? ''),
                                    UIHelpers.buildDetailTextField('Baba İş Adresi', widget.student.babaIsAdresi ?? ''),
                                    UIHelpers.buildDetailTextField('Baba Eğitim Durumu', widget.student.babaEgitimDurumu ?? ''),
                                  ],
                                ),
                              ),
                              // Veli/Diğer Tab
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    UIHelpers.buildDetailTextField('Anne/Baba Durumu', widget.student.anneBabaDurumu ?? ''),
                                    UIHelpers.buildDetailTextField('Kiminle Kalıyor', widget.student.kiminleKaliyor ?? ''),
                                    UIHelpers.buildDetailTextField('Veli Kim', widget.student.veliKim ?? ''),
                                    UIHelpers.buildDetailTextField('Veli Ev Adresi', widget.student.veliEvAdresi ?? ''),
                                    UIHelpers.buildDetailTextField('İlave Açıklama', widget.student.ilaveAciklama ?? ''),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}