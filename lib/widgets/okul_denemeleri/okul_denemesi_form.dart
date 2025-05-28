import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/okul_denemesi_model.dart';

class OkulDenemesiForm extends StatefulWidget {
  final OkulDenemesi? initialDenemesi;
  final Function(OkulDenemesi) onSave;
  final VoidCallback? onCancel;

  const OkulDenemesiForm({
    super.key,
    this.initialDenemesi,
    required this.onSave,
    this.onCancel,
  });

  @override
  State<OkulDenemesiForm> createState() => _OkulDenemesiFormState();
}

class _OkulDenemesiFormState extends State<OkulDenemesiForm> {
  final TextEditingController sinavAdiController = TextEditingController();
  final TextEditingController yanlisGoturmeOraniController =
      TextEditingController();
  DateTime? selectedDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.initialDenemesi != null) {
      sinavAdiController.text = widget.initialDenemesi!.sinavAdi;
      yanlisGoturmeOraniController.text =
          widget.initialDenemesi!.yanlisGoturmeOrani.toString();
      selectedDate = widget.initialDenemesi!.sinavTarihi;
    }
  }

  @override
  void dispose() {
    sinavAdiController.dispose();
    yanlisGoturmeOraniController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String sinavAdi = sinavAdiController.text.trim();
    int yanlisGoturmeOrani = int.parse(yanlisGoturmeOraniController.text);

    final denemesi = OkulDenemesi(
      id: widget.initialDenemesi?.id,
      sinavAdi: sinavAdi,
      yanlisGoturmeOrani: yanlisGoturmeOrani,
      sinavTarihi: selectedDate ?? DateTime.now(),
    );

    widget.onSave(denemesi);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: sinavAdiController,
            decoration: InputDecoration(
              labelText: 'Sınav Adı',
              hintText: 'Sınav adını giriniz',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Lütfen sınav adını giriniz';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: yanlisGoturmeOraniController,
            decoration: InputDecoration(
              labelText: 'Kaç yanlış bir doğruyu götürecek?',
              hintText: 'Yanlış götürme oranını giriniz',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lütfen yanlış götürme oranını giriniz';
              }
              try {
                int.parse(value);
              } catch (e) {
                return 'Geçerli bir sayı giriniz';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(selectedDate == null
                  ? 'Sınav Tarihi Seçin'
                  : 'Seçilen Tarih: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Tarih Seç'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: widget.initialDenemesi == null
                        ? Colors.deepPurpleAccent
                        : Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.initialDenemesi == null
                        ? 'Deneme Ekle'
                        : 'Deneme Güncelle',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (widget.onCancel != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onCancel,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'İptal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
