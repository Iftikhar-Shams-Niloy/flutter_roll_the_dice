import 'dart:math';
import 'package:flutter/material.dart';
import 'package:roll_the_dice/styled_text.dart';
import 'dart:async';

final myRandomizer = Random();

class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  @override
  State<DiceRoller> createState() {
    return _DiceRollerState();
  }
}

class _DiceRollerState extends State<DiceRoller> {
  var currentDice = 'assets/dice_images/dice1.png';
  Timer? _diceTimer; // Add this field

  void rollTheDice() {
    _diceTimer?.cancel(); // Cancel any existing timer
    int elapsed = 0;

    _diceTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        int diceNumber = (elapsed % 6) + 1;
        currentDice = 'assets/dice_images/dice$diceNumber.png';
      });
      elapsed++;
      if (elapsed >= 15) {
        timer.cancel();

        int finalDice = myRandomizer.nextInt(6) + 1;

        setState(() {
          currentDice = 'assets/dice_images/dice$finalDice.png';
        });
      }
    });
  }

  @override
  void dispose() {
    _diceTimer?.cancel(); // Clean up timer
    super.dispose();
  }

  @override
  Widget build(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          currentDice,
          width: 225,
          height: 225,
          fit: BoxFit.contain,
        ),
        Container(
          margin: const EdgeInsets.all(16), // 16 pixels margin on all sides
          child: TextButton(
            onPressed: rollTheDice,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue.shade900,
              padding: const EdgeInsets.all(40),
              shape: const CircleBorder(
                side: BorderSide(
                  color: Colors.white,
                  width: 5,
                ),
              ),
            ),
            child: const StyledText('Roll\nDice'),
          ),
        ),
      ],
    );
  }
}
