import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../../core/utils/screen_size.dart';

class SpeedButton extends StatelessWidget {
  const SpeedButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      buttonSize: Size(screenWidth(context) * 0.2, screenHeight(context) * 0.09),
      spacing: screenHeight(context) * 0.02,
      animatedIcon: AnimatedIcons.add_event,
      animatedIconTheme: const IconThemeData(),
      children: [
        SpeedDialChild(
            child: const Icon(Icons.assignment),
            label: 'Create Test Paper',
            onTap: (){}
        ),
        SpeedDialChild(
            child: const Icon(Icons.assessment),
            label: 'Create Result',
            onTap: (){}
        ),
      ],
    );;
  }
}
