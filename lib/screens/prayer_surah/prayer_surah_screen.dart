import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah/prayer_surah_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah/prayer_surah_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah/prayer_surah_state.dart';
import 'package:ogrenci_takip_sistemi/models/prayer_surah_model.dart';
import 'package:ogrenci_takip_sistemi/screens/prayer_surah/prayer_surah_assignment_screen.dart';
import 'package:ogrenci_takip_sistemi/utils/snackbar_helper.dart';
import 'package:ogrenci_takip_sistemi/widgets/prayer_surah/prayer_surah_card.dart';
import 'package:ogrenci_takip_sistemi/widgets/prayer_surah/prayer_surah_form.dart';

class PrayerSurahScreen extends StatefulWidget {
  const PrayerSurahScreen({Key? key}) : super(key: key);

  @override
  State<PrayerSurahScreen> createState() => _PrayerSurahScreenState();
}

class _PrayerSurahScreenState extends State<PrayerSurahScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PrayerSurahBloc>().add(LoadPrayerSurahs());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAdd() {
    if (_controller.text.isEmpty) {
      SnackbarHelper.showWarningSnackBar(
        context,
        'Lütfen sure veya dua adını giriniz',
      );
      return;
    }

    final prayerSurah = PrayerSurah(duaSureAdi: _controller.text);
    context.read<PrayerSurahBloc>().add(AddPrayerSurah(prayerSurah));
    _controller.clear();
  }

  void _onUpdate(PrayerSurah prayerSurah) {
    if (_controller.text.isEmpty) {
      SnackbarHelper.showWarningSnackBar(
        context,
        'Lütfen sure veya dua adını giriniz',
      );
      return;
    }

    final updatedPrayerSurah =
        prayerSurah.copyWith(duaSureAdi: _controller.text);
    context.read<PrayerSurahBloc>().add(UpdatePrayerSurah(updatedPrayerSurah));
    _controller.clear();
  }

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Silme Onayı"),
          content: const Text(
              "Bu sure veya duayı silmek istediğinize emin misiniz?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Hayır"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("Evet"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void _onDelete(int id) async {
    final bool? confirm = await _showConfirmationDialog();
    if (confirm == true) {
      context.read<PrayerSurahBloc>().add(DeletePrayerSurah(id));
      _controller.clear();
    }
  }

  void _onSelectPrayerSurah(PrayerSurah prayerSurah, PrayerSurahState state) {
    if (state.selectedPrayerSurah?.id == prayerSurah.id) {
      context.read<PrayerSurahBloc>().add(const SelectPrayerSurah(null));
      _controller.clear();
    } else {
      context.read<PrayerSurahBloc>().add(SelectPrayerSurah(prayerSurah));
      _controller.text = prayerSurah.duaSureAdi;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sure ve Dualar'),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_ind),
            tooltip: 'Sure ve Dua Atama',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrayerSurahAssignmentScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<PrayerSurahBloc, PrayerSurahState>(
        listener: (context, state) {
          if (state.status == PrayerSurahStatus.failure &&
              state.errorMessage != null) {
            SnackbarHelper.showErrorSnackBar(
              context,
              state.errorMessage!,
            );
          } else if (state.status == PrayerSurahStatus.success) {
            // Success actions if needed
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PrayerSurahForm(
                  controller: _controller,
                  selectedPrayerSurah: state.selectedPrayerSurah,
                  onAdd: _onAdd,
                  onUpdate: () => state.selectedPrayerSurah != null
                      ? _onUpdate(state.selectedPrayerSurah!)
                      : null,
                  onDelete: state.selectedPrayerSurah != null
                      ? () => _onDelete(state.selectedPrayerSurah!.id!)
                      : null,
                ),
                const SizedBox(height: 20),
                Expanded(
                  flex: 2,
                  child: state.status == PrayerSurahStatus.loading
                      ? const Center(child: CircularProgressIndicator())
                      : state.prayerSurahs.isEmpty
                          ? const Center(
                              child: Text('Henüz sure veya dua eklenmemiş.'),
                            )
                          : ListView.builder(
                              itemCount: state.prayerSurahs.length,
                              itemBuilder: (context, index) {
                                final prayerSurah = state.prayerSurahs[index];
                                final isSelected =
                                    state.selectedPrayerSurah?.id ==
                                        prayerSurah.id;
                                return PrayerSurahCard(
                                  prayerSurah: prayerSurah,
                                  isSelected: isSelected,
                                  onTap: (prayerSurah) =>
                                      _onSelectPrayerSurah(prayerSurah, state),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
