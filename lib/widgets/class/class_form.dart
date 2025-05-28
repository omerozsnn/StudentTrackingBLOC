import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_state.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/custom_button.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/custom_text_field.dart';

class ClassForm extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAddClass;
  final VoidCallback onUpdateClass;
  final VoidCallback onDeleteClass;

  const ClassForm({
    Key? key,
    required this.controller,
    required this.onAddClass,
    required this.onUpdateClass,
    required this.onDeleteClass,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controller,
          labelText: 'Sınıf Adı',
        ),
        const SizedBox(height: 20),
        BlocBuilder<ClassBloc, ClassState>(
          builder: (context, state) {
            final isLoading = state is ClassLoading;
            final selectedClass = state.selectedClass;
            
            return Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: selectedClass == null
                        ? 'Sınıfı Ekle'
                        : 'Güncelle',
                    onPressed: isLoading
                        ? null
                        : (selectedClass == null
                            ? onAddClass
                            : onUpdateClass),
                    backgroundColor: selectedClass == null
                        ? Colors.deepPurpleAccent
                        : Colors.orange,
                  ),
                ),
                if (selectedClass != null) const SizedBox(width: 10),
                if (selectedClass != null)
                  Expanded(
                    child: CustomButton(
                      text: 'Sil',
                      onPressed: isLoading ? null : onDeleteClass,
                      backgroundColor: Colors.red,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
