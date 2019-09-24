import 'package:flutter/material.dart';

import '../constants.dart';

class RoundIconButton extends StatelessWidget {
  final Function onPressed;
  final IconData icon;
  final Color color;
  RoundIconButton({@required this.onPressed, @required this.icon, this.color});
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      child: Icon(
        icon,
        color: color,
      ),
      onPressed: onPressed,
      elevation: 6.0,
      shape: CircleBorder(),
      fillColor: primaryColor,
      constraints: BoxConstraints.tightFor(width: 40.0, height: 40.0),
    );
  }
}
