import 'package:flutter/material.dart';
import 'package:roll_the_dice/grad_container.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GradContainer(
          Colors.blue.shade500,
          Colors.blue.shade900,
        ),
      ),
    ),
  );
}
