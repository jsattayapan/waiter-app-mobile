import 'package:flutter/material.dart';
import 'package:jep_restaurant_waiter_app/brains/table.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class ReusableCard extends StatelessWidget {
  final String label;
  final double width;
  final double height;
  final String type;

  ReusableCard({@required this.label, this.width, this.height, this.type});

  @override
  Widget build(BuildContext context) {
    var tableInfo = Provider.of<TableInfo>(context);
    var checker = type == 'zone' ? tableInfo.zone : tableInfo.language;
    return GestureDetector(
      onTap: () {
        type == 'zone'
            ? tableInfo.setZone(label)
            : tableInfo.setLanguage(label);
      },
      child: Container(
          width: width != null ? width : 100,
          height: height != null ? height : 100,
          margin: const EdgeInsets.all(5.0),
          color: label == checker ? primaryTextColor : darkPrimaryColor,
          child: Center(
              child: Text(
            label,
            style: TextStyle(
                fontSize: 20.0,
                color: label == checker ? Colors.black : Colors.white),
          ))),
    );
  }
}
