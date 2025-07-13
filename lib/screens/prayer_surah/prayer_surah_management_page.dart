import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah/prayer_surah_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah/prayer_surah_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah/prayer_surah_state.dart';
import 'package:ogrenci_takip_sistemi/models/prayer_surah_model.dart';
import 'package:ogrenci_takip_sistemi/screens/prayer_surah/prayer_surah_assignment_screen.dart';
import 'package:ogrenci_takip_sistemi/utils/snackbar_helper.dart';
import 'package:ogrenci_takip_sistemi/widgets/prayer_surah/prayer_surah_list_view.dart';
import 'package:ogrenci_takip_sistemi/widgets/prayer_surah/prayer_surah_stats_bar.dart';
import 'package:ogrenci_takip_sistemi/widgets/prayer_surah/search_and_add_prayer_surah_card.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';

class PrayerSurahManagementPage extends StatefulWidget {
  const PrayerSurahManagementPage({Key? key}) : super(key: key);

  @override
  State<PrayerSurahManagementPage> createState() =>
      _PrayerSurahManagementPageState();
}

class _PrayerSurahManagementPageState extends State<PrayerSurahManagementPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _searchTerm;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<PrayerSurahBloc>().add(LoadPrayerSurahs());
    _controller.addListener(() {
      setState(() {
        if (!_isEditing) {
          _searchTerm = _controller.text;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _resetToDefault() {
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _isEditing = false;
    });
    context.read<PrayerSurahBloc>().add(const SelectPrayerSurah(null));
  }

  void _onAddOrUpdate() {
    if (_controller.text.isEmpty) {
      SnackbarHelper.showWarningSnackBar(
        context,
        'Lütfen sure veya dua adını giriniz.',
      );
      return;
    }

    final state = context.read<PrayerSurahBloc>().state;
    if (state.selectedPrayerSurah != null) {
      // Update
      final updatedPrayerSurah =
          state.selectedPrayerSurah!.copyWith(duaSureAdi: _controller.text);
      context
          .read<PrayerSurahBloc>()
          .add(UpdatePrayerSurah(updatedPrayerSurah));
    } else {
      // Add
      final newPrayerSurah = PrayerSurah(duaSureAdi: _controller.text);
      context.read<PrayerSurahBloc>().add(AddPrayerSurah(newPrayerSurah));
    }
    _resetToDefault();
  }

  void _onEdit(PrayerSurah prayerSurah) {
    context.read<PrayerSurahBloc>().add(SelectPrayerSurah(prayerSurah));
    _controller.text = prayerSurah.duaSureAdi;
    _focusNode.requestFocus();
    setState(() {
      _isEditing = true;
      _searchTerm = null;
    });
  }

  void _onDelete(int id) async {
    final bool? confirm = await _showConfirmationDialog();
    if (confirm == true) {
      context.read<PrayerSurahBloc>().add(DeletePrayerSurah(id));
      _resetToDefault();
    }
  }

  void _onSelect(PrayerSurah prayerSurah) {
    final state = context.read<PrayerSurahBloc>().state;
    if (state.selectedPrayerSurah?.id == prayerSurah.id) {
      _resetToDefault();
    } else {
      context.read<PrayerSurahBloc>().add(SelectPrayerSurah(prayerSurah));
       setState(() {
        _isEditing = false;
        _searchTerm = null;
      });
    }
  }

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Silme Onayı"),
          content:
              const Text("Bu sure veya duayı silmek istediğinize emin misiniz?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Hayır"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text("Evet"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrayerSurahBloc, PrayerSurahState>(
      listener: (context, state) {
        if (state.status == PrayerSurahStatus.failure &&
            state.errorMessage != null) {
          SnackbarHelper.showErrorSnackBar(context, state.errorMessage!);
        } else if (state.status == PrayerSurahStatus.success) {
          // Optional: Show success message if needed
        }
      },
      builder: (context, state) {
        final prayerSurahs = state.prayerSurahs;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SearchAndAddPrayerSurahCard(
                          controller: _controller,
                          focusNode: _focusNode,
                          isEditing: _isEditing,
                          onSearch: () {
                            _focusNode.unfocus();
                            setState(() {
                              _searchTerm = _controller.text;
                            });
                          },
                          onAdd: _onAddOrUpdate,
                        ),
                      ),
                      Expanded(
                        child: state.status == PrayerSurahStatus.loading
                            ? const Center(child: CircularProgressIndicator())
                            : PrayerSurahListView(
                                prayerSurahs: prayerSurahs,
                                selectedPrayerSurah: state.selectedPrayerSurah,
                                onSelect: _onSelect,
                                onEdit: _onEdit,
                                onDelete: _onDelete,
                                searchTerm: _searchTerm,
                              ),
                      ),
                      if (state.status != PrayerSurahStatus.loading)
                        PrayerSurahStatsBar(
                          prayerSurahCount: prayerSurahs.length,
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
