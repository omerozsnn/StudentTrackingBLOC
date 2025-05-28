import 'package:flutter/material.dart';

class AnswerButtonStyle {
  static ButtonStyle defaultStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Colors.white),
    foregroundColor: MaterialStateProperty.all(Colors.black87),
    side: MaterialStateProperty.all(BorderSide(color: Colors.grey.shade300)),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    minimumSize: MaterialStateProperty.all(const Size(32, 32)),
    padding: MaterialStateProperty.all(EdgeInsets.zero),
  );

  static ButtonStyle selectedStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Colors.blue),
    foregroundColor: MaterialStateProperty.all(Colors.white),
    side: MaterialStateProperty.all(BorderSide(color: Colors.blue)),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    minimumSize: MaterialStateProperty.all(const Size(32, 32)),
    padding: MaterialStateProperty.all(EdgeInsets.zero),
  );
}
