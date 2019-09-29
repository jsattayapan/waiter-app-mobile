import 'package:flutter/material.dart';
import 'package:jep_restaurant_waiter_app/brains/login.dart';
import 'package:jep_restaurant_waiter_app/brains/table.dart';

import '../constants.dart';

class TableHeaderBar extends StatelessWidget {
  const TableHeaderBar(
      {Key key, @required this.tableInfo, @required this.userInfo, this.button})
      : super(key: key);

  final TableInfo tableInfo;
  final Login userInfo;
  final FlatButton button;

  @override
  Widget build(BuildContext context) {
    if (tableInfo.timestamp != null) {
      return Container(
        color: primaryColor,
        height: 70.0,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  'โต๊ะ: ${tableInfo.tableNo}',
                  style: tableNoLabel,
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.people,
                      color: Colors.white,
                      size: 20.0,
                    ),
                    Text(
                      ' x ${tableInfo.numberOfGuest}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                button != null ? button : SizedBox()
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  'ZONE: ${tableInfo.zone}',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'โดย: ${tableInfo.createBy}',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'เวลา ${tableInfo.timestamp.hour}:${tableInfo.timestamp.minute < 10 ? '0' + tableInfo.timestamp.minute.toString() : tableInfo.timestamp.minute}',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            )
          ],
        ),
      );
    } else {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: Center(child: Text('Loading...')),
        ),
      );
    }
  }
}
