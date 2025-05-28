import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/styles/answer_button_styles.dart';

class KDSAnswerSheet extends StatefulWidget {
  final int questionCount;
  final List<String?> initialAnswers;
  final Function(List<String?>) onAnswersChanged;
  final List<String> answerOptions;

  const KDSAnswerSheet({
    Key? key,
    required this.questionCount,
    required this.initialAnswers,
    required this.onAnswersChanged,
    this.answerOptions = const ['A', 'B', 'C', 'D', 'E'],
  }) : super(key: key);

  @override
  _KDSAnswerSheetState createState() => _KDSAnswerSheetState();
}

class _KDSAnswerSheetState extends State<KDSAnswerSheet> {
  late List<String?> _answers;

  @override
  void initState() {
    super.initState();
    _initializeAnswers();
  }

  @override
  void didUpdateWidget(KDSAnswerSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.questionCount != oldWidget.questionCount ||
        widget.initialAnswers != oldWidget.initialAnswers) {
      _initializeAnswers();
    }
  }

  void _initializeAnswers() {
    // Make a copy of the initial answers
    _answers = List.from(widget.initialAnswers);

    // Resize the list if needed
    if (_answers.length < widget.questionCount) {
      _answers = [
        ..._answers,
        ...List.filled(widget.questionCount - _answers.length, null)
      ];
    } else if (_answers.length > widget.questionCount) {
      _answers = _answers.sublist(0, widget.questionCount);
    }
  }

  void _updateAnswer(int questionIndex, String? answer) {
    setState(() {
      _answers[questionIndex] = answer;
    });
    widget.onAnswersChanged(_answers);
  }

  Widget _buildAnswerButtonRow(int questionIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.answerOptions.map((option) {
        bool isSelected = _answers[questionIndex] == option;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: ElevatedButton(
              onPressed: () => _updateAnswer(questionIndex, option),
              style: isSelected
                  ? AnswerButtonStyle.selectedStyle
                  : AnswerButtonStyle.defaultStyle,
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabularAnswersheet() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Tablo başlığı
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Number',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    'Answer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tablo içeriği
          for (int i = 0; i < widget.questionCount; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: i % 2 == 0 ? Colors.white : Colors.grey.shade50,
                border: Border(
                  bottom: i < widget.questionCount - 1
                      ? BorderSide(color: Colors.grey.shade200)
                      : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  // Soru numarası
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Cevap butonları
                  Expanded(
                    flex: 5,
                    child: _buildAnswerButtonRow(i),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTabularAnswersheet();
  }
}
