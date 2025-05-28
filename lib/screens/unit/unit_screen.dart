import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_state.dart';
import 'package:ogrenci_takip_sistemi/models/units_model.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/loading_indicator.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/error_banner.dart';

class UnitScreen extends StatefulWidget {
  const UnitScreen({super.key});

  @override
  _UnitScreenState createState() => _UnitScreenState();
}

class _UnitScreenState extends State<UnitScreen> {
  final TextEditingController unitNameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    context.read<UnitBloc>().add(LoadUnits());
  }
  
  @override
  void dispose() {
    unitNameController.dispose();
    super.dispose();
  }

  void _handleAddOrUpdate() {
    if (unitNameController.text.isEmpty) return;
    
    final UnitBloc unitBloc = context.read<UnitBloc>();
    final selectedUnit = unitBloc.selectedUnit;
    
    if (selectedUnit != null) {
      // Update
      final updatedUnit = Unit(
        id: selectedUnit.id,
        unitName: unitNameController.text,
        educationYearId: selectedUnit.educationYearId,
      );
      unitBloc.add(UpdateUnit(updatedUnit));
    } else {
      // Add
      final newUnit = Unit(
        unitName: unitNameController.text,
      );
      unitBloc.add(AddUnit(newUnit));
    }
    
    unitNameController.clear();
  }

  void _handleSelectUnit(Unit unit) {
    final UnitBloc unitBloc = context.read<UnitBloc>();
    
    if (unitBloc.selectedUnit?.id == unit.id) {
      // Deselect
      unitBloc.add(const SelectUnit(null));
      unitNameController.clear();
    } else {
      // Select
      unitBloc.add(SelectUnit(unit));
      unitNameController.text = unit.unitName;
    }
  }

  void _handleDeleteUnit(int id) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Üniteyi Sil'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bu üniteyi silmek istediğinize emin misiniz?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hayır'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Evet'),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<UnitBloc>().add(DeleteUnit(id));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ünite Ekleme'),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<UnitBloc, UnitState>(
        listener: (context, state) {
          if (state is UnitOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is UnitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Ünite adı girişi
              TextField(
                controller: unitNameController,
                decoration: InputDecoration(
                  labelText: 'Ünite Adı',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 10),
              // Ekle, Güncelle, Sil butonları
              BlocBuilder<UnitBloc, UnitState>(
                builder: (context, state) {
                  final bool isSelected = state.selectedUnit != null;
                  
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleAddOrUpdate,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: isSelected ? Colors.orange : Colors.deepPurpleAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isSelected ? 'Güncelle' : 'Ekle',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (isSelected)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleDeleteUnit(state.selectedUnit!.id!),
                            icon: const Icon(Icons.delete),
                            label: const Text('Sil'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              // Üniteler listesi
              Expanded(
                child: BlocBuilder<UnitBloc, UnitState>(
                  builder: (context, state) {
                    if (state is UnitLoading) {
                      return const Center(child: LoadingIndicator());
                    } else if (state is UnitError) {
                      return ErrorBanner(message: state.message);
                    } else {
                      final units = state.units;
                      final selectedUnit = state.selectedUnit;
                      
                      if (units.isEmpty) {
                        return const Center(child: Text('Henüz ünite bulunmamaktadır.'));
                      }
                      
                      return ListView.builder(
                        itemCount: units.length,
                        itemBuilder: (context, index) {
                          final unit = units[index];
                          final isSelected = selectedUnit?.id == unit.id;

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isSelected ? BorderSide(color: Colors.deepPurpleAccent, width: 2) : BorderSide.none,
                            ),
                            color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
                            elevation: isSelected ? 8 : 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Text(
                                unit.unitName,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.deepPurple : Colors.black,
                                ),
                              ),
                              selected: isSelected,
                              onTap: () => _handleSelectUnit(unit),
                              trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.deepPurpleAccent) : null,
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 