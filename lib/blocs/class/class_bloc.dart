import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';
import 'class_event.dart';
import 'class_state.dart';
import 'class_repository.dart';

class ClassBloc extends Bloc<ClassEvent, ClassState> {
  final ClassRepository repository;
  List<Classes> classes = [];
  Classes? selectedClass;

  ClassBloc({required this.repository}) : super(ClassInitial()) {
    on<LoadClasses>(_onLoadClasses);
    on<LoadClassesForDropdown>(_onLoadClassesForDropdown);
    on<LoadClassesForScroll>(_onLoadClassesForScroll);
    on<LoadClassesWithPagination>(_onLoadClassesWithPagination);
    on<UpdateClass>(_onUpdateClass);
    on<LoadClassById>(_onLoadClassById);
    on<LoadClassesByName>(_onLoadClassByName);
    on<DeleteClass>(_onDeleteClass);
    on<AddClass>(_onAddClass);
    on<UploadClassExcel>(_onUploadClassExcel);
    on<SelectClass>(_onSelectClass);
    on<UnselectClass>(_onUnselectClass);
  }
  
  // Handle class selection
  void _onSelectClass(SelectClass event, Emitter<ClassState> emit) {
    selectedClass = event.selectedClass;
    emit(ClassesLoaded(classes, selectedClass: selectedClass));
  }
  
  // Handle class unselection
  void _onUnselectClass(UnselectClass event, Emitter<ClassState> emit) {
    print('Sınıf seçimi temizlendi');
    selectedClass = null;
    emit(ClassesLoaded(classes, selectedClass: null));
  }
  
  //Siniflari yukleme
  Future<void> _onLoadClasses(
      LoadClasses event, Emitter<ClassState> emit) async {
    emit(ClassLoading());
    try {
      classes = await repository.getClasses();
      emit(ClassesLoaded(classes, selectedClass: selectedClass));
    } catch (e) {
      print('Error loading classes: $e');
      emit(ClassError(e.toString()));
    }
  }

  // Siniflari dropdowwn ile yukleme
  Future<void> _onLoadClassesForDropdown(
      LoadClassesForDropdown event, Emitter<ClassState> emit) async {
    emit(ClassLoading());
    try {
      classes = await repository.getClassesForDropdown();
      emit(ClassesLoaded(classes, selectedClass: selectedClass));
    } catch (e) {
      emit(ClassError(e.toString()));
    }
  }

  // Siniflari Scroll ile yukleme
  Future<void> _onLoadClassesForScroll(
    LoadClassesForScroll event,
    Emitter<ClassState> emit,
  ) async {
    emit(ClassLoading());
    try {
      classes = await repository.getClassesForScroll(
        offset: event.offset,
        limit: event.limit,
      );
      emit(ClassesLoaded(classes, selectedClass: selectedClass));
    } catch (e) {
      emit(ClassError(e.toString()));
    }
  }
  
  // Siniflari sayfalama ile yukleme
  Future<void> _onLoadClassesWithPagination(
    LoadClassesWithPagination event,
    Emitter<ClassState> emit,
  ) async {
    emit(ClassLoading());
    try {
      final newClasses = await repository.getClasses(
        page: event.page,
        limit: event.limit,
      );
      
      // If it's the first page, replace existing classes
      // Otherwise append the new classes to the existing list
      if (event.page == 1) {
        classes = newClasses;
      } else {
        // Check for duplicates before adding
        for (final newClass in newClasses) {
          if (!classes.any((existingClass) => existingClass.id == newClass.id)) {
            classes.add(newClass);
          }
        }
      }
      
      emit(ClassesLoaded(classes, selectedClass: selectedClass));
    } catch (e) {
      print('Error loading classes with pagination: $e');
      emit(ClassError(e.toString()));
    }
  }

  // Siniflari guncelleme
  Future<void> _onUpdateClass(
      UpdateClass event, Emitter<ClassState> emit) async {
    emit(ClassLoading());
    try {
      await repository.updateClass(event.classData.id, event.classData);
      final index = classes.indexWhere((cls) => cls.id == event.classData.id);
      if (index != -1) {
        classes[index] =
            classes[index].copyWith(sinifAdi: event.classData.sinifAdi);
      }
      emit(ClassesLoaded(classes, selectedClass: selectedClass));
    } catch (e) {
      emit(ClassError(e.toString()));
    }
  }

  // Sinif id'sine gore sinifi getir
  Future<void> _onLoadClassById(
      LoadClassById event, Emitter<ClassState> emit) async {
    emit(ClassLoading());
    try {
      final classData = await repository.getClassById(event.classId);
      emit(ClassLoaded(classData, classes: classes, selectedClass: selectedClass));
    } catch (e) {
      emit(ClassError(e.toString()));
    }
  }

  // Sinif adina gore sinifi getir
  Future<void> _onLoadClassByName(
      LoadClassesByName event, Emitter<ClassState> emit) async {
    emit(ClassLoading());
    try {
      final classData = await repository.getClassByName(event.className);
      emit(ClassesLoaded(classData, selectedClass: selectedClass));
    } catch (e) {
      emit(ClassError(e.toString()));
    }
  }

  // Sinif Silme
  Future<void> _onDeleteClass(
      DeleteClass event, Emitter<ClassState> emit) async {
    emit(ClassLoading());
    try {
      await repository.deleteClass(event.classId);
      classes.removeWhere((cls) => cls.id == event.classId);
      // If the selected class was deleted, reset it
      if (selectedClass != null && selectedClass!.id == event.classId) {
        selectedClass = null;
      }
      emit(ClassesLoaded(classes, selectedClass: selectedClass));
    } catch (e) {
      emit(ClassError(e.toString()));
    }
  }

  // Sinif ekleme
  Future<void> _onAddClass(AddClass event, Emitter<ClassState> emit) async {
    emit(ClassLoading());
    try {
      await repository.addClass(event.classData, event.classData.sinifAdi);
      
      // Reload all classes instead of just adding the new one
      // This ensures we get the server-generated ID and timestamps
      classes = await repository.getClasses();
      emit(ClassesLoaded(classes, selectedClass: selectedClass));
    } catch (e) {
      emit(ClassError(e.toString()));
    }
  }

  // Excel dosyasindan sinif yukleme
  Future<void> _onUploadClassExcel(
      UploadClassExcel event, Emitter<ClassState> emit) async {
    // 1. Başlangıç durumu
    emit(ClassLoading());

    try {
      // 2. İşlemi gerçekleştir
      await repository.uploadClassExcel(event.filePath);

      // 3. Başarı durumu
      emit(ClassOperationSuccess('Sınıf Excel dosyası başarıyla yüklendi.'));

      // 4. Veri güncelleme durumu
      try {
        classes = await repository.getClasses();
        emit(ClassesLoaded(classes, selectedClass: selectedClass));
      } catch (loadError) {
        print('Error reloading classes after upload: $loadError');
        // Upload was successful but reloading failed
        // We'll still report success but log the error
      }
    } catch (e) {
      // 5. Hata durumu
      print('Error uploading excel: $e');
      emit(ClassError(e.toString()));
    }
  }
}
