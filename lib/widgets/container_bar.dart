import 'package:flutter/material.dart';

class ContainerBar extends StatelessWidget {
  final Color color;
  final Widget child;

  ContainerBar({this.color, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10.0),
        height: 70.0,
        color: color,
        child: child);
  }
}
