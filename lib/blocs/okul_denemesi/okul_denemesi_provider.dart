import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api.dart/okulDenemeleriApi.dart';
import 'okul_denemesi_bloc.dart';

class OkulDenemesiProvider extends StatelessWidget {
  final Widget child;
  final ApiService apiService;

  const OkulDenemesiProvider({
    super.key,
    required this.child,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OkulDenemesiBloc>(
      create: (context) => OkulDenemesiBloc(apiService: apiService),
      child: child,
    );
  }
}
