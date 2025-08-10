import 'package:flutter/material.dart';
import 'package:roll_the_dice/dice_roller.dart';

const gradBeginAlignment = Alignment.topLeft;
const gradEndAlignment = Alignment.bottomRight;

class GradContainer extends StatelessWidget {
  const GradContainer(this.gradColorStart, this.gradColorEnd, {super.key});

  final Color gradColorStart;
  final Color gradColorEnd;

  @override
  Widget build(context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradColorStart, gradColorEnd],
          begin: gradBeginAlignment,
          end: gradEndAlignment,
        ),
      ),

      child: Center(
        child: DiceRoller(),
      ),
    );
  }
}
