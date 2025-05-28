import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/screens/defter_kitap/defter_kitap_tracking_screen.dart';

class NotebookBookTrackingPage extends StatefulWidget {
  const NotebookBookTrackingPage({super.key});

  @override
  _NotebookBookTrackingPageState createState() =>
      _NotebookBookTrackingPageState();
}

class _NotebookBookTrackingPageState extends State<NotebookBookTrackingPage> {
  @override
  void initState() {
    super.initState();
    // Redirect to the new screen after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const DefterKitapTrackingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yönlendiriliyor...'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
