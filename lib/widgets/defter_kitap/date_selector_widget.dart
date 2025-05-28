import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/defter_kitap/defter_kitap_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/defter_kitap/defter_kitap_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/defter_kitap/defter_kitap_state.dart';

class DateSelectorWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final Function() onSaveRequested;
  final DateTime? initialDate;
  final List<String> availableDates;
  final int? courseClassId;
  final bool isEnabled;

  const DateSelectorWidget({
    Key? key,
    required this.onDateSelected,
    required this.onSaveRequested,
    this.initialDate,
    this.availableDates = const [],
    this.courseClassId,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<DateSelectorWidget> createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void didUpdateWidget(DateSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != null &&
        widget.initialDate != oldWidget.initialDate) {
      selectedDate = widget.initialDate!;
    }
  }

  // Convert date to display format (DD-MM-YYYY)
  String _formatDateForDisplay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  // Convert display format to DateTime
  DateTime _parseDisplayDate(String displayDate) {
    final parts = displayDate.split('-');
    return DateTime(
        int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      locale: const Locale('tr', 'TR'), // Turkish locale
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 800;

    return Column(
      children: [
        _buildDateSelector(),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: _buildAvailableDates(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tarih Seçimi',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: widget.isEnabled ? () => _selectDate(context) : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: widget.isEnabled
                          ? Colors.grey.shade400
                          : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: widget.isEnabled ? null : Colors.grey.shade100,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDateForDisplay(selectedDate),
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.isEnabled
                            ? Colors.blueGrey.shade700
                            : Colors.grey.shade600,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: widget.isEnabled
                          ? Colors.blueGrey.shade700
                          : Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isEnabled
                    ? Colors.blue.shade600
                    : Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('Kontrolü Kaydet',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              onPressed: widget.isEnabled ? widget.onSaveRequested : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableDates() {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.4;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.blueGrey.shade400, size: 20),
                SizedBox(width: 8),
                Text(
                  'Geçmiş Kontroller',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: widget.availableDates.isEmpty
                ? _buildEmptyDatesList()
                : Scrollbar(
                    thumbVisibility: true,
                    child: _buildDatesList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDatesList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, color: Colors.grey.shade400, size: 36),
            SizedBox(height: 10),
            Text(
              'Henüz kontrol yapılmamış',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.availableDates.length,
      itemBuilder: (context, index) {
        final date = widget.availableDates[index];
        final isSelected = date == _formatDateForDisplay(selectedDate);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.shade50 : Colors.transparent,
            border: Border.all(
              color: isSelected ? Colors.green.shade200 : Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            title: Text(
              date,
              style: TextStyle(
                color: isSelected ? Colors.green.shade700 : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            leading: isSelected
                ? Icon(Icons.check_circle,
                    color: Colors.green.shade400, size: 20)
                : Icon(Icons.calendar_month,
                    color: Colors.grey.shade500, size: 20),
            onTap: () {
              final DateTime parsedDate = _parseDisplayDate(date);
              setState(() {
                selectedDate = parsedDate;
              });
              widget.onDateSelected(parsedDate);
            },
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
}
