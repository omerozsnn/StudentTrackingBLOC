import 'package:flutter/material.dart';

class GradeInputDialog extends StatefulWidget {
  final String studentName;
  final String gradeType;
  final String? initialValue;
  final Function(String) onSave;

  const GradeInputDialog({
    Key? key,
    required this.studentName,
    required this.gradeType,
    this.initialValue,
    required this.onSave,
  }) : super(key: key);

  @override
  _GradeInputDialogState createState() => _GradeInputDialogState();
}

class _GradeInputDialogState extends State<GradeInputDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: [
          Icon(Icons.edit, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text('Not Girişi - ${widget.studentName}')),
        ],
      ),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: InputDecoration(
          labelText: '${widget.gradeType} Notunu Giriniz',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          prefixIcon: const Icon(Icons.grade, color: Colors.blue),
        ),
      ),
      actions: [
        TextButton(
          child: Text('İptal', style: TextStyle(color: Colors.grey.shade700)),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Kaydet'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            widget.onSave(_controller.text);
          },
        ),
      ],
    );
  }
}
