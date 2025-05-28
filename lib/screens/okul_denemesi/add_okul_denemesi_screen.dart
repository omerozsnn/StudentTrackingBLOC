import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api.dart/okulDenemeleriApi.dart';
import '../../blocs/okul_denemesi/okul_denemesi_bloc.dart';
import '../../blocs/okul_denemesi/okul_denemesi_event.dart' as events;
import '../../blocs/okul_denemesi/okul_denemesi_state.dart' as states;
import '../../models/okul_denemesi_model.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/okul_denemeleri/okul_denemesi_form.dart';
import '../../widgets/okul_denemeleri/okul_denemesi_item.dart';

class OkulDenemesiScreen extends StatefulWidget {
  final ApiService apiService;

  const OkulDenemesiScreen({
    super.key,
    required this.apiService,
  });

  @override
  State<OkulDenemesiScreen> createState() => _OkulDenemesiScreenState();
}

class _OkulDenemesiScreenState extends State<OkulDenemesiScreen> {
  late final OkulDenemesiBloc _okulDenemesiBloc;

  @override
  void initState() {
    super.initState();
    _okulDenemesiBloc = OkulDenemesiBloc(apiService: widget.apiService);
    _okulDenemesiBloc.add(const events.OkulDenemesiLoaded());
  }

  @override
  void dispose() {
    _okulDenemesiBloc.close();
    super.dispose();
  }

  void _showConfirmDeleteDialog(BuildContext context, int id) {
    UIHelpers.showConfirmationDialog(
      context: context,
      title: 'Okul Denemesi Sil',
      content: 'Bu deneme sınavını silmek istediğinizden emin misiniz?',
    ).then((confirmed) {
      if (confirmed) {
        _okulDenemesiBloc.add(events.OkulDenemesiDeleted(id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Okul Denemesi Yönetimi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: BlocProvider(
        create: (context) => _okulDenemesiBloc,
        child: BlocConsumer<OkulDenemesiBloc, states.OkulDenemesiState>(
          listener: (context, state) {
            if (state is states.OkulDenemesiError) {
              UIHelpers.showErrorMessage(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is states.OkulDenemesiLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is states.OkulDenemesiLoaded) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OkulDenemesiForm(
                      initialDenemesi: state.selectedDenemesi,
                      onSave: (denemesi) {
                        if (denemesi.id == null) {
                          _okulDenemesiBloc
                              .add(events.OkulDenemesiCreated(denemesi));
                        } else {
                          _okulDenemesiBloc
                              .add(events.OkulDenemesiUpdated(denemesi));
                        }
                        // Clear selection after save
                        _okulDenemesiBloc
                            .add(const events.OkulDenemesiSelected(null));
                      },
                      onCancel: state.selectedDenemesi != null
                          ? () => _okulDenemesiBloc
                              .add(const events.OkulDenemesiSelected(null))
                          : null,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Eklenmiş Denemeler:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: state.denemeler.isEmpty
                          ? const Center(
                              child: Text(
                                'Henüz eklenmiş deneme bulunmuyor.',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              itemCount: state.denemeler.length,
                              itemBuilder: (context, index) {
                                final deneme = state.denemeler[index];
                                final isSelected =
                                    state.selectedDenemesi?.id == deneme.id;

                                return Dismissible(
                                  key: Key('deneme_${deneme.id}'),
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (_) async {
                                    bool confirm = false;
                                    await UIHelpers.showConfirmationDialog(
                                      context: context,
                                      title: 'Okul Denemesi Sil',
                                      content:
                                          'Bu deneme sınavını silmek istediğinizden emin misiniz?',
                                    ).then((confirmed) {
                                      confirm = confirmed;
                                      if (confirmed && deneme.id != null) {
                                        _okulDenemesiBloc.add(
                                            events.OkulDenemesiDeleted(
                                                deneme.id!));
                                      }
                                    });
                                    return confirm;
                                  },
                                  child: OkulDenemesiItem(
                                    deneme: deneme,
                                    isSelected: isSelected,
                                    onTap: () {
                                      _okulDenemesiBloc.add(
                                        events.OkulDenemesiSelected(
                                          isSelected ? null : deneme,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child:
                    Text('Lütfen denemeleri yüklemek için sayfayı yenileyin.'),
              );
            }
          },
        ),
      ),
    );
  }
}
