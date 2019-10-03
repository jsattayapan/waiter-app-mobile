import 'package:flutter/material.dart';
import 'package:jep_restaurant_waiter_app/brains/login.dart';
import 'package:jep_restaurant_waiter_app/brains/table.dart';
import 'package:jep_restaurant_waiter_app/constants.dart';
import 'package:jep_restaurant_waiter_app/screens/cutomer_table_page.dart';
import 'package:jep_restaurant_waiter_app/widgets/create_table_contents.dart';
import 'package:provider/provider.dart';

class TableBox extends StatefulWidget {
  final String tableNo;
  final String status;
  final int numberOfGuest;
  final String zone;
  final String id;
  final String language;
  final String createBy;
  final String section;
  var timestamp;
  TableBox(
      {this.tableNo,
      this.status,
      this.numberOfGuest,
      this.zone,
      this.id,
      this.language,
      this.createBy,
      this.timestamp,
      this.section});

  @override
  _TableBoxState createState() => _TableBoxState();
}

class _TableBoxState extends State<TableBox> {
  @override
  Widget build(BuildContext context) {
    var tableInfo = Provider.of<TableInfo>(context);
    var userInfo = Provider.of<Login>(context);

    return GestureDetector(
      onTap: () async {
        //TODO: is table no hold
        var isOnHold = await tableInfo.isTableOnHold(widget.tableNo);
        print('Widget ID: ${widget.id}');
        if (isOnHold[0] == 'available') {
          if (widget.id != null) {
            //TODO: Update table status to on_order
            tableInfo.updateTableStatus(
                widget.tableNo, 'on_order', userInfo.id);
            tableInfo.setTableLog(widget.id);
            tableInfo.setTableInfo(
                widget.id,
                widget.tableNo,
                widget.numberOfGuest,
                widget.zone,
                widget.language,
                widget.createBy,
                widget.timestamp,
                widget.section);
            tableInfo.setCurrentOrder(widget.id);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => OrderFoodPage()));
          } else {
            //TODO: Update table status to on_create
            tableInfo.updateTableStatus(
                widget.tableNo, 'on_create', userInfo.id);
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Dialog(
                    child: Container(
                      width: 200.0,
                      height: 450.0,
                      color: Colors.grey.shade900,
                      child: WillPopScope(
                          onWillPop: () async => false,
                          child: DialogContent(tableNo: widget.tableNo)),
                    ),
                  );
                });
          }
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title:
                    Text('${isOnHold[1]} กำลังให้บริการโต๊ะ ${widget.tableNo}'),
                actions: <Widget>[
                  new FlatButton(
                    child: Text("ปิด"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        padding: EdgeInsets.symmetric(vertical: 5.0),
        color: widget.status == 'opened'
            ? Colors.greenAccent
            : widget.status == 'checked'
                ? Colors.redAccent
                : Colors.grey.shade300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              widget.tableNo,
              style: TextStyle(fontSize: 25.0),
            ),
            widget.id != null
                ? Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.people,
                            color: Colors.black,
                            size: 20.0,
                          ),
                          Text(
                              ' x ${widget.numberOfGuest != null ? widget.numberOfGuest : 0}'),
                        ],
                      ),
                      Text('Zone: ${widget.zone}')
                    ],
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
