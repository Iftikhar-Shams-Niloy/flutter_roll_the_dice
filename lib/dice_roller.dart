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

class _DiceRollerState extends State<DiceRoller>
    with SingleTickerProviderStateMixin {
  var currentDice = 'assets/dice_images/dice1.png';
  Timer? _diceTimer; // Add this field
  late final AnimationController _floatController;
  late Animation<double> _angleAnimation; //* <--- angle in radians --->
  double _floatRadius = 0.0;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // start the angle so the dice sits at the top (above the button)
    const startAngle = -pi / 2;
    _angleAnimation = Tween<double>(
      begin: startAngle,
      end: startAngle,
    ).animate(_floatController);
  }

  void rollTheDice() {
    _diceTimer?.cancel(); // Cancel any existing timer
    int elapsed = 0;

    _floatRadius = 24;
    final revolutions = 3 + myRandomizer.nextInt(5);
    //* <--- start the circle at the top (-pi/2) so it returns to top after full revolutions --->
    const startAngle = -pi / 2;
    final endAngle = startAngle + 2 * pi * revolutions;
    _angleAnimation = Tween<double>(begin: startAngle, end: endAngle).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    // set controller duration to match roll length (total ticks * period)
    const tickMs = 350;
    const ticks = 15;
    _floatController.duration = Duration(milliseconds: tickMs * ticks);
    _floatController.forward(from: 0.0);

    _diceTimer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      setState(() {
        int diceNumber = (elapsed % 6) + 1;
        currentDice = 'assets/dice_images/dice$diceNumber.png';
      });
      elapsed++;
      if (elapsed >= 15) {
        timer.cancel();

        final int finalDice = myRandomizer.nextInt(6) + 1;

        _floatController.value = 1.0;

        setState(() {
          currentDice = 'assets/dice_images/dice$finalDice.png';
        });
      }
    });
  }

  @override
  void dispose() {
    _diceTimer?.cancel(); // Clean up timer
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 225,
          height: 225,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.bounceInOut,
            switchOutCurve: Curves.bounceIn,
            transitionBuilder: (Widget child, Animation<double> myAnimation) {
              final opacity = myAnimation;
              final scale = Tween<double>(
                begin: 0.75,
                end: 1.0,
              ).animate(myAnimation);
              return FadeTransition(
                opacity: opacity,
                child: ScaleTransition(
                  scale: scale,
                  child: child,
                ),
              );
            },

            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                final angle = _angleAnimation.value;
                final dx = cos(angle) * _floatRadius;
                final dy = sin(angle) * _floatRadius;
                return Transform.translate(
                  offset: Offset(dx, dy),
                  child: child,
                );
              },
              child: Image.asset(
                currentDice,
                //*<--- trigger AnimatedSwitcher --->
                key: ValueKey<String>(
                  currentDice,
                ),
                width: 225,
                height: 225,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        Container(
          margin: const EdgeInsets.all(16),
          child: TextButton(
            onPressed: rollTheDice,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue.shade900,
              padding: const EdgeInsets.all(40),
              shape: const CircleBorder(
                side: BorderSide(
                  color: Colors.white,
                  width: 8,
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
