import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/ogrenci_okul_denemesi_model.dart';
import 'ogrenci_okul_denemeleri_event.dart';
import 'ogrenci_okul_denemeleri_state.dart';
import 'ogrenci_okul_denemeleri_repository.dart';

class OgrenciOkulDenemeleriBloc
    extends Bloc<OgrenciOkulDenemeleriEvent, OgrenciOkulDenemeleriState> {
  final OgrenciOkulDenemeleriRepository repository;

  OgrenciOkulDenemeleriBloc({required this.repository})
      : super(OgrenciOkulDenemeleriInitial()) {
    on<LoadAllOgrenciOkulDenemeleri>(_onLoadAllOgrenciOkulDenemeleri);
    on<LoadOgrenciOkulDenemeleriByStudent>(
        _onLoadOgrenciOkulDenemeleriByStudent);
    on<UpsertOgrenciOkulDenemesi>(_onUpsertOgrenciOkulDenemesi);
    on<DeleteOgrenciOkulDenemesi>(_onDeleteOgrenciOkulDenemesi);
    on<LoadClassOkulDenemeAverages>(_onLoadClassOkulDenemeAverages);
    on<SelectOgrenciOkulDenemesi>(_onSelectOgrenciOkulDenemesi);
  }

  Future<void> _onLoadAllOgrenciOkulDenemeleri(
    LoadAllOgrenciOkulDenemeleri event,
    Emitter<OgrenciOkulDenemeleriState> emit,
  ) async {
    emit(OgrenciOkulDenemeleriLoading());
    try {
      final denemeleri = await repository.getAllOgrenciOkulDenemeleri();
      emit(OgrenciOkulDenemeleriLoaded(denemeleri: denemeleri));
    } catch (e) {
      emit(OgrenciOkulDenemeleriError(e.toString()));
    }
  }

  Future<void> _onLoadOgrenciOkulDenemeleriByStudent(
    LoadOgrenciOkulDenemeleriByStudent event,
    Emitter<OgrenciOkulDenemeleriState> emit,
  ) async {
    emit(OgrenciOkulDenemeleriLoading());
    try {
      final denemeleri =
          await repository.getOgrenciOkulDenemeleriByStudentId(event.ogrenciId);
      emit(OgrenciOkulDenemeleriLoaded(denemeleri: denemeleri));
    } catch (e) {
      emit(OgrenciOkulDenemeleriError(e.toString()));
    }
  }

  Future<void> _onUpsertOgrenciOkulDenemesi(
    UpsertOgrenciOkulDenemesi event,
    Emitter<OgrenciOkulDenemeleriState> emit,
  ) async {
    try {
      if (state is OgrenciOkulDenemeleriLoaded) {
        final currentState = state as OgrenciOkulDenemeleriLoaded;
        emit(OgrenciOkulDenemeleriLoading());

        // Create or update the deneme sonucu
        final updatedDenemeSonucu =
            await repository.upsertOgrenciOkulDeneme(event.denemeSonucu);

        // Update the list of deneme sonuclari
        List<OgrenciOkulDenemesi> updatedDenemeleri =
            List.from(currentState.denemeleri);
        final index =
            updatedDenemeleri.indexWhere((d) => d.id == updatedDenemeSonucu.id);

        if (index != -1) {
          // Update existing item
          updatedDenemeleri[index] = updatedDenemeSonucu;
        } else {
          // Add new item
          updatedDenemeleri.add(updatedDenemeSonucu);
        }

        // Emit success message
        emit(OgrenciOkulDenemeleriOperationSuccess(
            'Deneme sonucu başarıyla kaydedildi.'));

        // Emit updated state
        emit(OgrenciOkulDenemeleriLoaded(
          denemeleri: updatedDenemeleri,
          selectedDenemeSonucu: updatedDenemeSonucu,
        ));
      }
    } catch (e) {
      emit(OgrenciOkulDenemeleriError(e.toString()));

      // Restore previous state if available
      if (state is OgrenciOkulDenemeleriLoaded) {
        emit(state);
      }
    }
  }

  Future<void> _onDeleteOgrenciOkulDenemesi(
    DeleteOgrenciOkulDenemesi event,
    Emitter<OgrenciOkulDenemeleriState> emit,
  ) async {
    try {
      if (state is OgrenciOkulDenemeleriLoaded) {
        final currentState = state as OgrenciOkulDenemeleriLoaded;
        emit(OgrenciOkulDenemeleriLoading());

        // Delete the deneme sonucu
        await repository.deleteOgrenciOkulDeneme(event.id);

        // Update the list of deneme sonuclari
        final updatedDenemeleri =
            currentState.denemeleri.where((d) => d.id != event.id).toList();

        // Clear selected item if it was deleted
        final selectedDenemeSonucu =
            currentState.selectedDenemeSonucu?.id == event.id
                ? null
                : currentState.selectedDenemeSonucu;

        // Emit success message
        emit(OgrenciOkulDenemeleriOperationSuccess(
            'Deneme sonucu başarıyla silindi.'));

        // Emit updated state
        emit(OgrenciOkulDenemeleriLoaded(
          denemeleri: updatedDenemeleri,
          selectedDenemeSonucu: selectedDenemeSonucu,
        ));
      }
    } catch (e) {
      emit(OgrenciOkulDenemeleriError(e.toString()));

      // Restore previous state if available
      if (state is OgrenciOkulDenemeleriLoaded) {
        emit(state);
      }
    }
  }

  Future<void> _onLoadClassOkulDenemeAverages(
    LoadClassOkulDenemeAverages event,
    Emitter<OgrenciOkulDenemeleriState> emit,
  ) async {
    emit(OgrenciOkulDenemeleriLoading());
    try {
      final averages = await repository.getClassOkulDenemeAverages(
        event.sinifId,
        event.ogrenciId,
      );
      emit(ClassOkulDenemeAveragesLoaded(averages));
    } catch (e) {
      emit(OgrenciOkulDenemeleriError(e.toString()));
    }
  }

  void _onSelectOgrenciOkulDenemesi(
    SelectOgrenciOkulDenemesi event,
    Emitter<OgrenciOkulDenemeleriState> emit,
  ) {
    if (state is OgrenciOkulDenemeleriLoaded) {
      final currentState = state as OgrenciOkulDenemeleriLoaded;
      emit(currentState.copyWith(selectedDenemeSonucu: event.denemeSonucu));
    }
  }
}
