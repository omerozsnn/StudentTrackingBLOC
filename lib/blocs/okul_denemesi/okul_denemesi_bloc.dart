import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api.dart/okulDenemeleriApi.dart';
import '../../models/okul_denemesi_model.dart';
import 'okul_denemesi_event.dart' as events;
import 'okul_denemesi_state.dart' as states;

class OkulDenemesiBloc
    extends Bloc<events.OkulDenemesiEvent, states.OkulDenemesiState> {
  final ApiService apiService;

  OkulDenemesiBloc({required this.apiService})
      : super(states.OkulDenemesiInitial()) {
    on<events.OkulDenemesiLoaded>(_onLoaded);
    on<events.OkulDenemesiCreated>(_onCreated);
    on<events.OkulDenemesiUpdated>(_onUpdated);
    on<events.OkulDenemesiDeleted>(_onDeleted);
    on<events.OkulDenemesiSelected>(_onSelected);
  }

  Future<void> _onLoaded(
    events.OkulDenemesiLoaded event,
    Emitter<states.OkulDenemesiState> emit,
  ) async {
    emit(states.OkulDenemesiLoading());
    try {
      final result = await apiService.getAllOkulDenemeleri(
        page: event.page,
        limit: event.limit,
      );

      List<OkulDenemesi> denemeler =
          (result['data'] as List<dynamic>).cast<OkulDenemesi>().toList();

      emit(states.OkulDenemesiLoaded(
        denemeler: denemeler,
        totalItems: result['totalItems'] ?? 0,
        totalPages: result['totalPages'] ?? 0,
        currentPage: result['currentPage'] ?? 1,
      ));
    } catch (e) {
      emit(states.OkulDenemesiError(e.toString()));
    }
  }

  Future<void> _onCreated(
    events.OkulDenemesiCreated event,
    Emitter<states.OkulDenemesiState> emit,
  ) async {
    try {
      if (state is states.OkulDenemesiLoaded) {
        // Save current state to restore if needed
        final currentState = state as states.OkulDenemesiLoaded;
        emit(states.OkulDenemesiLoading());

        // Create the okul denemesi
        final createdDenemesi =
            await apiService.createOkulDenemesi(event.denemesi);

        // Get updated list
        final result = await apiService.getAllOkulDenemeleri(
          page: currentState.currentPage,
          limit: 50,
        );

        List<OkulDenemesi> denemeler =
            (result['data'] as List<dynamic>).cast<OkulDenemesi>().toList();

        emit(states.OkulDenemesiLoaded(
          denemeler: denemeler,
          totalItems: result['totalItems'] ?? 0,
          totalPages: result['totalPages'] ?? 0,
          currentPage: result['currentPage'] ?? 1,
        ));
      }
    } catch (e) {
      emit(states.OkulDenemesiError(e.toString()));
    }
  }

  Future<void> _onUpdated(
    events.OkulDenemesiUpdated event,
    Emitter<states.OkulDenemesiState> emit,
  ) async {
    try {
      if (state is states.OkulDenemesiLoaded) {
        // Save current state to restore if needed
        final currentState = state as states.OkulDenemesiLoaded;
        emit(states.OkulDenemesiLoading());

        // Update the okul denemesi
        final updatedDenemesi =
            await apiService.updateOkulDenemesi(event.denemesi);

        // Get updated list
        final result = await apiService.getAllOkulDenemeleri(
          page: currentState.currentPage,
          limit: 50,
        );

        List<OkulDenemesi> denemeler =
            (result['data'] as List<dynamic>).cast<OkulDenemesi>().toList();

        emit(states.OkulDenemesiLoaded(
          denemeler: denemeler,
          totalItems: result['totalItems'] ?? 0,
          totalPages: result['totalPages'] ?? 0,
          currentPage: result['currentPage'] ?? 1,
        ));
      }
    } catch (e) {
      emit(states.OkulDenemesiError(e.toString()));
    }
  }

  Future<void> _onDeleted(
    events.OkulDenemesiDeleted event,
    Emitter<states.OkulDenemesiState> emit,
  ) async {
    try {
      if (state is states.OkulDenemesiLoaded) {
        // Save current state to restore if needed
        final currentState = state as states.OkulDenemesiLoaded;
        emit(states.OkulDenemesiLoading());

        // Delete the okul denemesi
        await apiService.deleteOkulDenemesi(event.id);

        // Get updated list
        final result = await apiService.getAllOkulDenemeleri(
          page: currentState.currentPage,
          limit: 50,
        );

        List<OkulDenemesi> denemeler =
            (result['data'] as List<dynamic>).cast<OkulDenemesi>().toList();

        // If the deleted item was selected, clear selection
        final OkulDenemesi? selectedDenemesi =
            currentState.selectedDenemesi?.id == event.id
                ? null
                : currentState.selectedDenemesi;

        emit(states.OkulDenemesiLoaded(
          denemeler: denemeler,
          selectedDenemesi: selectedDenemesi,
          totalItems: result['totalItems'] ?? 0,
          totalPages: result['totalPages'] ?? 0,
          currentPage: result['currentPage'] ?? 1,
        ));
      }
    } catch (e) {
      emit(states.OkulDenemesiError(e.toString()));
    }
  }

  void _onSelected(
    events.OkulDenemesiSelected event,
    Emitter<states.OkulDenemesiState> emit,
  ) {
    if (state is states.OkulDenemesiLoaded) {
      final currentState = state as states.OkulDenemesiLoaded;
      emit(currentState.withSelectedDenemesi(event.denemesi));
    }
  }
}
