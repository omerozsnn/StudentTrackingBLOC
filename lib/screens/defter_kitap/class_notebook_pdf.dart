import 'package:flutter/material.dart';

class ClassNotebookBookTrackingPage extends StatefulWidget {
  final String className;

  const ClassNotebookBookTrackingPage({Key? key, required this.className})
      : super(key: key);

  @override
  State<ClassNotebookBookTrackingPage> createState() =>
      _ClassNotebookBookTrackingPageState();
}

class _ClassNotebookBookTrackingPageState
    extends State<ClassNotebookBookTrackingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.className} Sınıfı Takip Listesi'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          '${widget.className} sınıfı için takip listesi içeriği burada görüntülenecek.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
