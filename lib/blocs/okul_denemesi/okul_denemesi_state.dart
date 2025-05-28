import 'package:equatable/equatable.dart';
import '../../models/okul_denemesi_model.dart';

abstract class OkulDenemesiState extends Equatable {
  const OkulDenemesiState();

  @override
  List<Object?> get props => [];
}

class OkulDenemesiInitial extends OkulDenemesiState {}

class OkulDenemesiLoading extends OkulDenemesiState {}

class OkulDenemesiLoaded extends OkulDenemesiState {
  final List<OkulDenemesi> denemeler;
  final OkulDenemesi? selectedDenemesi;
  final int totalItems;
  final int totalPages;
  final int currentPage;

  const OkulDenemesiLoaded({
    required this.denemeler,
    this.selectedDenemesi,
    this.totalItems = 0,
    this.totalPages = 0,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props =>
      [denemeler, selectedDenemesi, totalItems, totalPages, currentPage];

  OkulDenemesiLoaded copyWith({
    List<OkulDenemesi>? denemeler,
    OkulDenemesi? selectedDenemesi,
    int? totalItems,
    int? totalPages,
    int? currentPage,
  }) {
    return OkulDenemesiLoaded(
      denemeler: denemeler ?? this.denemeler,
      selectedDenemesi: selectedDenemesi ?? this.selectedDenemesi,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  OkulDenemesiLoaded withSelectedDenemesi(OkulDenemesi? denemesi) {
    return copyWith(selectedDenemesi: denemesi);
  }
}

class OkulDenemesiError extends OkulDenemesiState {
  final String message;

  const OkulDenemesiError(this.message);

  @override
  List<Object> get props => [message];
}
