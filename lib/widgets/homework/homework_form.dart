import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/homework_model.dart';
import '../../utils/ui_helpers.dart';

class HomeworkForm extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController dueDateController;
  final Function() onSave;
  final Function()? onDelete;
  final bool isEditing;

  const HomeworkForm({
    Key? key,
    required this.titleController,
    required this.dueDateController,
    required this.onSave,
    this.onDelete,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<HomeworkForm> createState() => _HomeworkFormState();
}

class _HomeworkFormState extends State<HomeworkForm> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.deepPurpleAccent,
            colorScheme:
                const ColorScheme.light(primary: Colors.deepPurpleAccent),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        widget.dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: widget.titleController,
                decoration: InputDecoration(
                  labelText: 'Ödev Başlığı',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.assignment,
                      color: Colors.deepPurpleAccent),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen ödev başlığını giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: widget.dueDateController,
                decoration: InputDecoration(
                  labelText: 'Teslim Tarihi',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.calendar_today,
                      color: Colors.deepPurpleAccent),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen teslim tarihini seçiniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(widget.isEditing ? Icons.edit : Icons.add),
                label: Text(widget.isEditing ? 'Güncelle' : 'Ödev Ekle'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSave();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      widget.isEditing ? Colors.green : Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (widget.isEditing && widget.onDelete != null) ...[
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Sil'),
                  onPressed: widget.onDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
