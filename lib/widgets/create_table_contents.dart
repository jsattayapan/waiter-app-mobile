import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jep_restaurant_waiter_app/brains/login.dart';
import 'package:jep_restaurant_waiter_app/brains/table.dart';
import 'package:jep_restaurant_waiter_app/screens/cutomer_table_page.dart';

import 'package:jep_restaurant_waiter_app/widgets/reusable_card.dart';
import 'package:jep_restaurant_waiter_app/widgets/round_button_icon.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class DialogContent extends StatefulWidget {
  final String tableNo;
  DialogContent({this.tableNo});
  @override
  _DialogContentState createState() => _DialogContentState();
}

class _DialogContentState extends State<DialogContent> {
  @override
  Widget build(BuildContext context) {
    var tableInfo = Provider.of<TableInfo>(context);
    var userInfo = Provider.of<Login>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: <Widget>[
            Text(
              'โต๊ะ: ${widget.tableNo}',
              style: TextStyle(
                  fontSize: 25.0,
                  color: lightPrimaryColor,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              'Zone:',
              style: TextStyle(
                  fontSize: 25.0,
                  color: lightPrimaryColor,
                  fontWeight: FontWeight.bold),
            ),
            Container(
              height: 150,
              child: GridView.count(
                crossAxisCount: 4,
                children: <Widget>[
                  ReusableCard(
                    label: 'A1',
                    type: 'zone',
                  ),
                  ReusableCard(
                    label: 'B1',
                    type: 'zone',
                  ),
                  ReusableCard(
                    label: 'B2',
                    type: 'zone',
                  ),
                  ReusableCard(
                    label: 'B3',
                    type: 'zone',
                  ),
                  ReusableCard(
                    label: 'B4',
                    type: 'zone',
                  ),
                  ReusableCard(
                    label: 'B5',
                    type: 'zone',
                  ),
                  ReusableCard(
                    label: 'B6',
                    type: 'zone',
                  ),
                  ReusableCard(
                    label: 'B7',
                    type: 'zone',
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'จำนวนลูกค้า:',
              style: TextStyle(
                  fontSize: 20.0,
                  color: lightPrimaryColor,
                  fontWeight: FontWeight.bold),
            ),
            RoundIconButton(
              icon: FontAwesomeIcons.minus,
              onPressed: () {
                setState(() {
                  tableInfo.minusGuest();
                });
              },
            ),
            Text(
              tableInfo.numberOfGuest.toString(),
              style: TextStyle(
                  color: lightPrimaryColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            RoundIconButton(
              icon: FontAwesomeIcons.plus,
              onPressed: () {
                setState(() {
                  tableInfo.addGuest();
                });
              },
            ),
          ],
        ),
        Text(
          'ภาษา: ',
          style: TextStyle(
              fontSize: 20.0,
              color: lightPrimaryColor,
              fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ReusableCard(
              label: 'ไทย',
              width: 100.0,
              height: 50.0,
              type: 'language',
            ),
            ReusableCard(
              label: 'อังกฤษ',
              width: 100.0,
              height: 50.0,
              type: 'language',
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: () {
                tableInfo.reset();
                tableInfo.updateTableStatus(widget.tableNo, 'available', '');
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.cancel,
                color: lightPrimaryColor,
                size: 35.0,
              ),
            ),
            IconButton(
              onPressed: () {
                if (tableInfo.zone != null && tableInfo.language != null) {
                  print('Passes');
                  tableInfo.updateTableStatus(
                      widget.tableNo, 'on_order', userInfo.id);
                  tableInfo.createCustomerTable(
                      userInfo.id, widget.tableNo, userInfo.shortName);
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => OrderFoodPage()));
                } else {
                  print('Not Pass !!');
                }
              },
              icon: Icon(
                Icons.navigate_next,
                color: lightPrimaryColor,
                size: 35.0,
              ),
            )
          ],
        )
      ],
    );
  }
}
