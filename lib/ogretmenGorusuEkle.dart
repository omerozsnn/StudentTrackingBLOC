import 'package:flutter/material.dart';
import 'api.dart/teacherFeedbackApi.dart';
import 'package:ogrenci_takip_sistemi/screens/feedback/teacher_comment_screen.dart';

class OgretmenGorusuEklemePage extends StatefulWidget {
  const OgretmenGorusuEklemePage({super.key});

  @override
  _OgretmenGorusuEklemePageState createState() =>
      _OgretmenGorusuEklemePageState();
}

class _OgretmenGorusuEklemePageState extends State<OgretmenGorusuEklemePage> {
  final ApiService apiService = ApiService(baseUrl: 'http://localhost:3000');
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> ogretmenGorusleri = [];
  Map<String, dynamic>? _selectedGorus;

  @override
  void initState() {
    super.initState();
    loadOgretmenGorusleri();
  }

  Future<void> loadOgretmenGorusleri() async {
    try {
      final List<dynamic> data =
          await apiService.getTeacherFeedbackOptionsForDropdown();
      setState(() {
        ogretmenGorusleri = List<Map<String, dynamic>>.from(data);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Öğretmen görüşleri yüklenemedi: $error')),
      );
    }
  }

  Future<void> _addGorus() async {
    if (_controller.text.isNotEmpty) {
      try {
        await apiService
            .addTeacherFeedbackOption({'gorus_metni': _controller.text});
        _controller.clear();
        loadOgretmenGorusleri();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Görüş başarıyla eklendi')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Görüş eklenemedi: $error')),
        );
      }
    }
  }

  Future<void> _removeGorus() async {
    if (_selectedGorus != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Emin misiniz?'),
            content:
                const Text('Bu görüşü silmek istediğinizden emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hayır'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Evet'),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        try {
          await apiService.deleteTeacherFeedbackOption(_selectedGorus!['id']);
          setState(() {
            _selectedGorus = null;
            _controller.clear();
          });
          loadOgretmenGorusleri();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Görüş başarıyla silindi')),
          );
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Görüş silinemedi: $error')),
          );
        }
      }
    }
  }

  Future<void> _updateGorus() async {
    if (_selectedGorus != null && _controller.text.isNotEmpty) {
      try {
        await apiService.updateTeacherFeedbackOption(
            _selectedGorus!['id'], {'gorus_metni': _controller.text});
        setState(() {
          _selectedGorus = null;
          _controller.clear();
        });
        loadOgretmenGorusleri();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Görüş başarıyla güncellendi')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Görüş güncellenemedi: $error')),
        );
      }
    }
  }

  void _onGorusTap(Map<String, dynamic> gorus) {
    setState(() {
      if (_selectedGorus != null && _selectedGorus!['id'] == gorus['id']) {
        _selectedGorus = null;
        _controller.clear();
      } else {
        _selectedGorus = gorus;
        _controller.text = gorus['gorus_metni'] ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğretmen Görüşü Ekleme'),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_ind),
            tooltip: 'Görüş Atama',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherCommentPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Öğretmen Görüşü Girişi
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Öğretmen Görüşü',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 10),
            // Ekle, Sil ve Güncelle Butonları
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _selectedGorus == null ? _addGorus : _updateGorus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedGorus == null
                          ? Colors.deepPurpleAccent
                          : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_selectedGorus == null ? 'Ekle' : 'Güncelle'),
                  ),
                ),
                const SizedBox(width: 5),
                if (_selectedGorus != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _removeGorus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Sil'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            // Öğretmen Görüşleri Listesi
            Expanded(
              child: ListView.builder(
                itemCount: ogretmenGorusleri.length,
                itemBuilder: (context, index) {
                  final gorus = ogretmenGorusleri[index];
                  final isSelected = _selectedGorus != null &&
                      gorus['id'] == _selectedGorus!['id'];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isSelected
                          ? BorderSide(color: Colors.deepPurpleAccent, width: 2)
                          : BorderSide.none,
                    ),
                    color:
                        isSelected ? Colors.deepPurple.shade50 : Colors.white,
                    elevation: isSelected ? 8 : 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        gorus['gorus_metni'] ?? 'Bilinmeyen Görüş',
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.deepPurple : Colors.black,
                        ),
                      ),
                      selected: isSelected,
                      onTap: () => _onGorusTap(gorus),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: Colors.deepPurpleAccent)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
