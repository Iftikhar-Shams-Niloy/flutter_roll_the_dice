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
    _diceTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        // Cycle through dice images 1-6
        int diceNumber = (elapsed % 6) + 1;
        currentDice = 'assets/dice_images/dice$diceNumber.png';
      });
      elapsed++;
      if (elapsed >= 15) {
        // 20 * 100ms = 2s
        timer.cancel();
        // Show a random dice image at the end
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

  Widget build(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          currentDice,
          width: 225,
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: rollTheDice,
          // style: TextButton.styleFrom(padding: EdgeInsets.only(top: 20)),
          child: const StyledText('Roll The Dice'),
        ),
      ],
    );
  }
}
