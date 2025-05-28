import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api.dart/egitimOgretimYılıApi.dart';

class AddEducationYearPage extends StatefulWidget {
  const AddEducationYearPage({super.key});

  @override
  _AddEducationYearPageState createState() => _AddEducationYearPageState();
}

class _AddEducationYearPageState extends State<AddEducationYearPage> {
  final ApiService apiService = ApiService(baseUrl: 'http://localhost:3000');
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStart ? startDate : endDate)) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, 
                   color: Theme.of(context).primaryColor),
              const SizedBox(width: 10),
              const Text('Emin misiniz?'),
            ],
          ),
          content: const Text(
            'Eklemekte olduğunuz eğitim öğretim yılı otomatik olarak aktifleşecektir. Kabul ediyor musunuz?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Reddet'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Kabul Et'),
              onPressed: () {
                Navigator.of(context).pop();
                _createNewYear();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _createNewYear() async {
    if (!_formKey.currentState!.validate()) return;

    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen başlangıç ve bitiş tarihlerini seçin')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final newYearData = {
        'baslangic_tarihi': DateFormat('yyyy-MM-dd').format(startDate!),
        'bitis_tarihi': DateFormat('yyyy-MM-dd').format(endDate!),
      };
      await apiService.createNewYear(newYearData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eğitim öğretim yılı başarıyla eklendi')),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${error.toString()}')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildDateSelector({
    required String title,
    required DateTime? selectedDate,
    required VoidCallback onSelect,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSelect,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate != null
                          ? DateFormat('dd MMMM yyyy', 'tr_TR').format(selectedDate)
                          : 'Tarih seçilmedi',
                      style: TextStyle(
                        color: selectedDate != null
                            ? Theme.of(context).textTheme.bodyLarge?.color
                            : Colors.grey,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _showConfirmationDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline),
                  SizedBox(width: 12),
                  Text(
                    'Eğitim Öğretim Yılı Ekle',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Eğitim Öğretim Yılı'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDateSelector(
              title: 'Başlangıç Tarihi',
              selectedDate: startDate,
              onSelect: () => _selectDate(context, true),
              icon: Icons.start,
            ),
            const SizedBox(height: 16),
            _buildDateSelector(
              title: 'Bitiş Tarihi',
              selectedDate: endDate,
              onSelect: () => _selectDate(context, false),
              icon: Icons.stop,
            ),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }
}