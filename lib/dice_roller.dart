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
  Timer? _diceTimer;
  late final AnimationController _floatController;
  late Animation<double> _angleAnimation; //* <--- angle in radians --->
  late Animation<double> _rotationAnimation; //* <--- rotation in radians --->
  double _floatRadius = 0.0;
  int _jumpHops = 0;
  double _jumpAmplitude = 0.0;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    //* <--- start the angle so the dice sits at the top (above the button) --->
    const startAngle = -pi / 2;
    _angleAnimation = Tween<double>(
      begin: startAngle,
      end: startAngle,
    ).animate(_floatController);
    //* <--- rotation starts at 0 --->
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(_floatController);
  }

  void rollTheDice() {
    _diceTimer?.cancel(); //* Cancel any existing timer
    int elapsed = 0;

    _floatRadius = 24;
    final revolutions = 6 + myRandomizer.nextInt(3);
    final spins = 3 + myRandomizer.nextInt(4);
    _jumpHops = 6 + myRandomizer.nextInt(6);
    _jumpAmplitude = 24 + myRandomizer.nextDouble() * 24;
    //* <--- start the circle at the top (-pi/2) so it returns to top after full revolutions --->
    const startAngle = -pi / 2;
    final endAngle = startAngle + 2 * pi * revolutions;
    _angleAnimation = Tween<double>(begin: startAngle, end: endAngle).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    //* <--- Rotation Animation --->
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * pi * spins).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeOut),
    );
    //* set controller duration to match roll length (total ticks * period)
    const tickMs = 355;
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

        // smoothly animate controller to completion (this eases out rotation and jump)
        _floatController
            .animateTo(
              1.0,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
            )
            .then((_) {
              // update the final dice image after the motion finishes
              if (mounted) {
                setState(() {
                  currentDice = 'assets/dice_images/dice$finalDice.png';
                });
              }
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
            duration: const Duration(milliseconds: 250),
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
                final rotation = _rotationAnimation.value;
                // compute vertical jump (sin-based) using controller progress so it starts/ends at 0
                final progress = _floatController.value.clamp(0.0, 1.0);
                // reduce jump amplitude near the end for a smooth stop
                final ampFade = Curves.easeOut.transform(1.0 - progress);
                final effectiveAmplitude = _jumpAmplitude * ampFade;
                final jump =
                    -sin(progress * 2 * pi * _jumpHops) * effectiveAmplitude;
                // rotate the image around its center, then translate its center along the circular path plus jump
                return Transform.translate(
                  offset: Offset(dx, dy + jump),
                  child: Transform.rotate(
                    angle: rotation,
                    child: child,
                  ),
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

        SizedBox(height: 32),

        Container(
          margin: const EdgeInsets.symmetric(vertical: 32),
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
