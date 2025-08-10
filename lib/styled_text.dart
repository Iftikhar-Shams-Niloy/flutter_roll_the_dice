import 'package:flutter/material.dart';

class StyledText extends StatelessWidget {
  const StyledText(this.inputText, {super.key});
  final String inputText;

  @override
  Widget build(context) {
    return Text(
      inputText,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 30,
      ),
    );
  }
}
