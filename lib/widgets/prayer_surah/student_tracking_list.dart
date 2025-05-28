import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';

class StudentTrackingList extends StatelessWidget {
  final List<Student> students;
  final Map<int, Map<String, dynamic>> studentTrackings;
  final Map<int, SingleValueDropDownController> dropdownControllers;
  final List<DropDownValueModel> options;
  final Function(int, bool) onStatusChanged;
  final Function(int, String?) onDegerlendirmeChanged;
  final Function(int, String) onEkGorusChanged;
  final Function(int) onStudentSelected;

  const StudentTrackingList({
    super.key,
    required this.students,
    required this.studentTrackings,
    required this.dropdownControllers,
    required this.options,
    required this.onStatusChanged,
    required this.onDegerlendirmeChanged,
    required this.onEkGorusChanged,
    required this.onStudentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                  width: 80,
                  child: Text('Numara',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade700))),
              Expanded(
                  child: Text('Adı Soyadı',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade700))),
              SizedBox(
                  width: 250,
                  child: Text('Görüş',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade700))),
              SizedBox(
                  width: 100,
                  child: Text('Ek Görüş',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade700))),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final studentId = student.id;

              // Make sure there's a controller for this student
              if (!dropdownControllers.containsKey(studentId)) {
                dropdownControllers[studentId] =
                    SingleValueDropDownController();

                // If there's a value from state, set it in the controller
                if (studentTrackings.containsKey(studentId) &&
                    studentTrackings[studentId]?['degerlendirme'] != null) {
                  final value = studentTrackings[studentId]!['degerlendirme'];
                  dropdownControllers[studentId]?.setDropDown(
                    DropDownValueModel(
                      name: value,
                      value: value,
                    ),
                  );
                }
              }

              // Check if student has tracking data
              final hasDurum = studentTrackings.containsKey(studentId)
                  ? studentTrackings[studentId]!['durum'] == 'Okudu'
                  : false;

              return InkWell(
                onTap: () => onStudentSelected(studentId),
                child: Container(
                  decoration: BoxDecoration(
                    color: hasDurum
                        ? const Color.fromARGB(255, 111, 249, 116)
                        : const Color.fromARGB(255, 190, 76, 68),
                    border:
                        Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            (student.ogrenciNo ?? '').toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(student.adSoyad,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                        SizedBox(
                          width: 250,
                          child: Row(
                            children: [
                              Checkbox(
                                value: hasDurum,
                                onChanged: (bool? value) {
                                  onStatusChanged(studentId, value ?? false);
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 300,
                          child: DropDownTextField(
                            controller: dropdownControllers[studentId],
                            clearOption: true,
                            enableSearch: false,
                            textFieldDecoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: hasDurum
                                  ? const Color.fromARGB(255, 111, 249, 116)
                                  : const Color.fromARGB(255, 190, 76, 68),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  dropdownControllers[studentId]
                                      ?.clearDropDown();
                                  onDegerlendirmeChanged(studentId, null);
                                },
                              ),
                            ),
                            dropDownItemCount: 6,
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            dropDownList: options,
                            onChanged: (val) {
                              if (val is DropDownValueModel) {
                                onDegerlendirmeChanged(studentId, val.value);
                              }
                            },
                            listSpace: 50,
                            listPadding: ListPadding(top: 4, bottom: 4),
                            dropDownIconProperty: IconProperty(
                              icon: Icons.keyboard_arrow_down,
                              color: Colors.black,
                            ),
                            listTextStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 350,
                          child: TextField(
                            textAlign: TextAlign.start,
                            textDirection: TextDirection.ltr,
                            controller: TextEditingController(
                              text: studentTrackings.containsKey(studentId)
                                  ? studentTrackings[studentId]!['ekgorus'] ??
                                      ''
                                  : '',
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                    color: Colors.blueGrey, width: 2),
                              ),
                            ),
                            onChanged: (val) {
                              onEkGorusChanged(studentId, val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
