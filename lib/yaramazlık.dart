import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/misbehaviour_model.dart';
import 'api.dart/misbehaviorApi.dart';
import 'yaramazlikkontrol.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yaramazlık Takibi',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: MisbehaviourPage(),
    );
  }
}

class MisbehaviourPage extends StatefulWidget {
  const MisbehaviourPage({super.key});

  @override
  _MisbehaviourPageState createState() => _MisbehaviourPageState();
}

class _MisbehaviourPageState extends State<MisbehaviourPage> {
  final MisbehaviourApiService apiService =
      MisbehaviourApiService(baseUrl: 'http://localhost:3000');
  final TextEditingController _misbehaviourController = TextEditingController();
  List<dynamic> misbehaviours = [];
  int? _selectedMisbehaviourId;

  @override
  void initState() {
    super.initState();
    _fetchMisbehaviours();
  }

  Future<void> _fetchMisbehaviours() async {
    try {
      final data = await apiService.getAllMisbehaviours();
      setState(() {
        misbehaviours = data;
      });
    } catch (e) {
      print("Failed to fetch misbehaviours: $e");
    }
  }

  Future<void> _addMisbehaviour() async {
    if (_misbehaviourController.text.isEmpty) return;

    try {
      final newMisbehaviour = Misbehaviour(
        yaramazlikAdi: _misbehaviourController.text,
      );
      await apiService.addMisbehaviour(newMisbehaviour);
      _misbehaviourController.clear();
      _fetchMisbehaviours();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yaramazlık başarıyla eklendi')));
    } catch (e) {
      print("Failed to add misbehaviour: $e");
    }
  }

  Future<void> _updateMisbehaviour() async {
    if (_selectedMisbehaviourId == null) return;

    try {
      // Seçili yaramazlığı bul
      final selectedMisbehaviour = misbehaviours.firstWhere(
        (m) => m.id == _selectedMisbehaviourId,
      );

      // Yeni değerlerle güncelle
      final updatedMisbehaviour = selectedMisbehaviour.copyWith(
        yaramazlikAdi: _misbehaviourController.text,
      );

      await apiService.updateMisbehaviour(
          _selectedMisbehaviourId!, updatedMisbehaviour);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yaramazlık başarıyla güncellendi')));
      _clearSelection();
      _fetchMisbehaviours();
    } catch (e) {
      print("Failed to update misbehaviour: $e");
    }
  }

  Future<void> _deleteMisbehaviour() async {
    if (_selectedMisbehaviourId == null) return;
    try {
      await apiService.deleteMisbehaviour(_selectedMisbehaviourId!);
      _clearSelection();
      _fetchMisbehaviours();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yaramazlık başarıyla silindi')));
    } catch (e) {
      print("Failed to delete misbehaviour: $e");
    }
  }

  void _confirmDelete() {
    if (_selectedMisbehaviourId == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Silme Onayı"),
          content: const Text(
              "Bu yaramazlık kaydını silmek istediğinizden emin misiniz?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Hayır"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Evet"),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMisbehaviour();
              },
            ),
          ],
        );
      },
    );
  }

  void _onMisbehaviourTap(int id, String name) {
    setState(() {
      if (_selectedMisbehaviourId == id) {
        _clearSelection();
      } else {
        _selectedMisbehaviourId = id;
        _misbehaviourController.text = name;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedMisbehaviourId = null;
      _misbehaviourController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yaramazlık Ekleme',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.track_changes),
            tooltip: 'Yaramazlık Kontrol',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MisbehaviourControlPage(),
                ),
              ).then((_) {
                // Refresh misbehaviours list when returning
                _fetchMisbehaviours();
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Field
            TextField(
              controller: _misbehaviourController,
              decoration: InputDecoration(
                labelText: 'Yaramazlık Adı',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 10),
            // Buttons for Add, Update, and Delete
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedMisbehaviourId == null
                        ? _addMisbehaviour
                        : _updateMisbehaviour,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedMisbehaviourId == null
                          ? Colors.deepPurpleAccent
                          : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                        _selectedMisbehaviourId == null ? 'Ekle' : 'Güncelle'),
                  ),
                ),
                const SizedBox(width: 5),
                if (_selectedMisbehaviourId != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirmDelete,
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
            // List of Misbehaviours
            Expanded(
              child: ListView.builder(
                itemCount: misbehaviours.length,
                itemBuilder: (context, index) {
                  final misbehaviour = misbehaviours[index];
                  int id = misbehaviour['id'];
                  String name = misbehaviour['yaramazlık_adi'];
                  bool isSelected = _selectedMisbehaviourId == id;

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
                      title: Text(name),
                      onTap: () => _onMisbehaviourTap(id, name),
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
