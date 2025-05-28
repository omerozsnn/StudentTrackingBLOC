import 'package:equatable/equatable.dart';
import '../../models/okul_denemesi_model.dart';

abstract class OkulDenemesiEvent extends Equatable {
  const OkulDenemesiEvent();

  @override
  List<Object?> get props => [];
}

class OkulDenemesiLoaded extends OkulDenemesiEvent {
  final int page;
  final int limit;

  const OkulDenemesiLoaded({this.page = 1, this.limit = 50});

  @override
  List<Object?> get props => [page, limit];
}

class OkulDenemesiCreated extends OkulDenemesiEvent {
  final OkulDenemesi denemesi;

  const OkulDenemesiCreated(this.denemesi);

  @override
  List<Object?> get props => [denemesi];
}

class OkulDenemesiUpdated extends OkulDenemesiEvent {
  final OkulDenemesi denemesi;

  const OkulDenemesiUpdated(this.denemesi);

  @override
  List<Object?> get props => [denemesi];
}

class OkulDenemesiDeleted extends OkulDenemesiEvent {
  final int id;

  const OkulDenemesiDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class OkulDenemesiSelected extends OkulDenemesiEvent {
  final OkulDenemesi? denemesi;

  const OkulDenemesiSelected(this.denemesi);

  @override
  List<Object?> get props => [denemesi];
}
