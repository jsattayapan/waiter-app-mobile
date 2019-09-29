import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jep_restaurant_waiter_app/brains/login.dart';
import 'package:jep_restaurant_waiter_app/brains/table.dart';
import 'package:jep_restaurant_waiter_app/brains/food_items.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jep_restaurant_waiter_app/screens/food_menu_page.dart';
import 'package:jep_restaurant_waiter_app/widgets/container_bar.dart';
import 'package:jep_restaurant_waiter_app/widgets/round_button_icon.dart';
import 'package:jep_restaurant_waiter_app/widgets/table_header_bar.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../constants.dart';

//final _scaffoldKey = GlobalKey<ScaffoldState>();

final formatCurrency = new NumberFormat("#,##0", "en_US");

class OrderFoodPage extends StatefulWidget {
  @override
  _OrderFoodPageState createState() => _OrderFoodPageState();
}

class _OrderFoodPageState extends State<OrderFoodPage> {
  int totalPrice = 0;
  bool showLog = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Container setCurrentItems(items) {
    if (items != null) {
      totalPrice = 0;
      List<Widget> list = List();
      for (var item in items) {
        list.add(FoodItemLine(
          name: item['name'],
          quantity: item['quantity'],
          price: item['price'],
          status: item['status'],
        ));
        setState(() {
          totalPrice += item['price'] * item['quantity'];
        });
      }
      return Container(
        margin: EdgeInsets.all(10.0),
        child: ListView(
          children: list,
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[],
        ),
      );
    }
  }

  Container setTableLogs(logs) {
    List<Widget> list = List();
    for (var log in logs) {
      list.add(LogLine(
        name: log['name'],
        status: log['status'],
        detail: log['detail'],
        timestamp: log['timestamp'],
        short_name: log['short_name'],
        from_table: log['from_table'],
        quantity: log['quantity'],
      ));
    }

    return Container(
      margin: EdgeInsets.all(10.0),
      child: ListView(
        children: list,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var tableInfo = Provider.of<TableInfo>(context);
    var userInfo = Provider.of<Login>(context);

    print('Current Order: ${tableInfo.currentOrders}');

    if (tableInfo.timestamp == null) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: Center(child: Text('Loading...')),
        ),
      );
    } else {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
//          key: _scaffoldKey,
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TableHeaderBar(
                    tableInfo: tableInfo,
                    userInfo: userInfo,
                    button: tableInfo.currentOrders != null
                        ? tableInfo.currentOrders.length != 0
                            ? FlatButton(
                                color: primaryTextColor,
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/tables');
                                  tableInfo.updateTableStatus(
                                      tableInfo.tableNo, 'available', "");
                                  tableInfo.reset();
                                },
                                child: Text('ออก'),
                              )
                            : FlatButton(
                                color: primaryTextColor,
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/tables');
                                  tableInfo.updateTableStatus(
                                      tableInfo.tableNo, 'available', "");
                                  tableInfo.closeTable(tableInfo.id);
                                  tableInfo.reset();
                                },
                                child: Text('ปิดโต๊ะ'),
                              )
                        : null),
                ContainerBar(
                  color: Colors.blue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      showLog
                          ? RoundIconButton(
                              icon: FontAwesomeIcons.infoCircle,
                              color: Colors.white,
                              onPressed: () {
                                setState(() {
                                  showLog = false;
                                });
                              },
                            )
                          : RoundIconButton(
                              icon: FontAwesomeIcons.list,
                              color: Colors.white,
                              onPressed: () {
                                setState(() {
                                  showLog = true;
                                });
                              },
                            ),
                      RoundIconButton(
                        icon: FontAwesomeIcons.exchangeAlt,
                        color: Colors.yellow,
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  child: Container(
                                      width: 200.0,
                                      height: 450.0,
                                      color: Colors.grey.shade900,
                                      child: TransferOrderSection()),
                                );
                              });
                        },
                      ),
                      RoundIconButton(
                        icon: FontAwesomeIcons.creditCard,
                        color: Colors.purpleAccent,
                        onPressed: () {
                          if (tableInfo.currentOrders.length != 0) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                      'ต้องการเก็บเงินโต๊ะ: ${tableInfo.tableNo} ?'),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text("ไม่ใช่"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('ใช่'),
                                      onPressed: () {
                                        //TODO: Check bill

                                        Navigator.of(context).pop();
                                        tableInfo.checkBill(
                                            tableInfo.id, userInfo.id);
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              Future.delayed(
                                                  Duration(seconds: 1), () {
                                                Navigator.of(context).pop(true);
                                                Navigator.of(context).pop(true);
                                                tableInfo.updateTableStatus(
                                                    tableInfo.tableNo,
                                                    'available',
                                                    "");
                                                tableInfo.reset();
                                              });
                                              return AlertDialog(
                                                title:
                                                    Text('กำลังพิมพ์ใบเสร็จ'),
                                              );
                                            });
                                      },
                                    )
                                  ],
                                );
                              },
                            );
                          } else {
//                            final snackBar = SnackBar(
//                                content: Text(
//                                    'ไม่สามารถเช็คบิลได้ เนื่องจากไม่มีรายการอาหาร ณ ปัจุบัน'));
//                            _scaffoldKey.currentState.showSnackBar(snackBar);
                          }
                        },
                      ),
                      RoundIconButton(
                        icon: Icons.note_add,
                        color: Colors.greenAccent,
                        onPressed: () {
                          var foodItems = Provider.of<FoodItems>(context);
                          foodItems.getFoodItems();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FoodMenuPage()));
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: showLog
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  'รายการ',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              //TODO: Display Current Orders
                              Expanded(
                                child: setCurrentItems(tableInfo.currentOrders),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  'Logs',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              //TODO: Display Current Orders
                              Expanded(
                                child: setTableLogs(tableInfo.tableLogs),
                              ),
                            ],
                          ),
                  ),
                ),
                ContainerBar(
                  color: primaryColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'Total: ฿${formatCurrency.format(totalPrice)}.-',
                        style: tableNoLabel,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class LogLine extends StatelessWidget {
  final String status;
  final String timestamp;
  final String detail;
  final String name;
  final int quantity;
  final String short_name;
  final String from_table;
  const LogLine(
      {Key key,
      this.status,
      this.timestamp,
      this.detail,
      this.name,
      this.quantity,
      this.short_name,
      this.from_table})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var time = DateTime.parse(timestamp).toLocal();
    var formatTime =
        'เวลา ${time.hour}:${time.minute < 10 ? '0' + time.minute.toString() : time.minute}';
    if (status == "sent") {
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 1, child: Text('สั่ง')),
              Expanded(
                  flex: 6,
                  child: Text(
                      '$name x ${quantity.toString()} ${from_table != null ? '(#โต๊ะ: $from_table)' : ''}')),
              Expanded(flex: 2, child: Text(short_name)),
              Expanded(flex: 2, child: Text(formatTime)),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      );
    } else if (status == "complete") {
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 1, child: Text('ปรุงเสร็จ')),
              Expanded(
                  flex: 6,
                  child: Text(
                      '$name x ${quantity.toString()} ${from_table != null ? '(#โต๊ะ: $from_table)' : ''}')),
              Expanded(flex: 2, child: Text(short_name)),
              Expanded(flex: 2, child: Text(formatTime)),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      );
    } else if (status == "cancel") {
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 1, child: Text('ยกเลิก')),
              Expanded(flex: 6, child: Text('$name x ${quantity.toString()}')),
              Expanded(flex: 2, child: Text(short_name)),
              Expanded(flex: 2, child: Text(formatTime)),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      );
    } else if (status == "opened") {
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 1, child: Text('')),
              Expanded(flex: 6, child: Text('เปิดโต๊ะ')),
              Expanded(flex: 2, child: Text(short_name)),
              Expanded(flex: 2, child: Text(formatTime)),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      );
    } else if (status == "checked") {
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 1, child: Text('')),
              Expanded(flex: 6, child: Text('เรียกเช็คบิล')),
              Expanded(flex: 2, child: Text(short_name)),
              Expanded(flex: 2, child: Text(formatTime)),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      );
    } else if (status == "discount") {
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 1, child: Text('ส่วนลด')),
              Expanded(flex: 6, child: Text(detail)),
              Expanded(flex: 2, child: Text(short_name)),
              Expanded(flex: 2, child: Text(formatTime)),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      );
    } else {
      return Column();
    }
  }
}

class FoodItemLine extends StatelessWidget {
  final String name;
  final int quantity;
  final int price;
  final String status;

  FoodItemLine({this.name, this.quantity, this.price, this.status});

  @override
  Widget build(BuildContext context) {
    var icon = status == 'sent'
        ? Icon(
            FontAwesomeIcons.hotjar,
            color: Colors.deepOrange,
          )
        : status == 'complete'
            ? Icon(
                FontAwesomeIcons.checkCircle,
                color: Colors.green,
              )
            : Icon(
                FontAwesomeIcons.timesCircle,
                color: Colors.red,
              );
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: icon,
            ),
            Expanded(flex: 7, child: Text(name)),
            Expanded(flex: 1, child: Text(quantity.toString())),
            Expanded(
                flex: 2,
                child: Text(
                    '${formatCurrency.format((price * quantity)).toString()}.-')),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
      ],
    );
  }
}

class FoodCatButton extends StatelessWidget {
  final String label;

  FoodCatButton({this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(5.0),
        color: Colors.deepOrange,
        height: 40.0,
        child: Center(
            child: Text(
          label,
          style: TextStyle(fontSize: 18.0),
        )),
      ),
    );
  }
}

class TransferOrderSection extends StatefulWidget {
  @override
  _TransferOrderSectionState createState() => _TransferOrderSectionState();
}

class _TransferOrderSectionState extends State<TransferOrderSection> {
  var selectTable = '-';
  var selectTableId = '-';
  var listItem = [];
  var items = [];
  var isChecked = false;
  @override
  Widget build(BuildContext context) {
    var tableInfo = Provider.of<TableInfo>(context);
    var userInfo = Provider.of<Login>(context);

    void addItem(id, quantity) {
      listItem.add({"id": id, "quantity": quantity});
      var list = listItem;
      setState(() {
        listItem = list;
      });
      print(listItem.length);
    }

    void removeItem(id) {
      print(id);
      listItem.removeWhere((item) => item["id"] == id);
      var list = listItem;
      setState(() {
        listItem = list;
      });
      print(listItem.length);
    }

    void submitTransferOrder(newTableNumber, orders, oldTableId) {
      print('submitTransferOrder: $orders');
      var totalQuantity =
          items.fold(0, (value, item) => value + item['quantity']);
      var selectQuantity =
          orders.fold(0, (value, item) => value + item['quantity']);

      var transferType = totalQuantity == selectQuantity ? 'full' : 'partial';
      tableInfo.transferOrder(
          newTableNumber, orders, userInfo.id, transferType, oldTableId,
          (response) {
        tableInfo.updateTableStatus(tableInfo.tableNo, 'available', "");
        tableInfo.reset();
        var alertStyle = AlertStyle(
          isCloseButton: false,
          isOverlayTapDismiss: false,
        );
        if (response['status']) {
          Alert(
            context: context,
            style: alertStyle,
            type: AlertType.success,
            title: "RFLUTTER ALERT",
            desc: "ย้ายโต๊ะสำเร็จ.",
            buttons: [
              DialogButton(
                child: Text(
                  "ปิด",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/tables');
                },
                width: 120,
              )
            ],
          ).show();
        } else {
          Alert(
              context: context,
              style: alertStyle,
              type: AlertType.error,
              title: "RFLUTTER ALERT",
              desc: "ย้ายโต๊ะล้มเหลว.",
              buttons: [
                DialogButton(
                  child: Text(
                    "ปิด",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/tables');
                  },
                  width: 120,
                )
              ]).show();
        }
      });
    }

    ListView setTransferTable(data) {
      List<Widget> list = List();
      for (var tableSection in data) {
        for (var table in tableSection['tables']) {
          if (table['status'] != null && table['number'] != tableInfo.tableNo) {
            list.add(
              GestureDetector(
                onTap: () async {
                  var response = await tableInfo.getCurrentOrder(table['id']);
                  if (selectTable == '-') {
                    setState(() {
                      items = response;
                      selectTable = table['number'];
                      listItem = [];
                      selectTableId = table['id'];
                    });
                  } else if (selectTable == table['number']) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                                'คุณต้องการย้ายทุกรายการจากโต๊ะ ${table['number']} ไปยังโต๊ะ ${tableInfo.tableNo}'),
                            actions: <Widget>[
                              new FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('ปิด'),
                              ),
                              new FlatButton(
                                onPressed: () {
                                  submitTransferOrder(tableInfo.tableNo,
                                      response, selectTableId);
                                },
                                child: Text('ยืนยัน'),
                              ),
                            ],
                          );
                        });
                  } else {
                    setState(() {
                      items = [];
                      selectTable = '-';
                      listItem = [];
                    });
                  }
                },
                child: Container(
                  margin: EdgeInsets.all(10.0),
                  width: 100.0,
                  color: table['status'] == 'opened'
                      ? Colors.greenAccent
                      : Colors.red,
                  child: Center(
                      child: Text(
                    table['number'],
                    style: TextStyle(fontSize: 25.0),
                  )),
                ),
              ),
            );
          }
        }
      }
      return ListView(
        scrollDirection: Axis.horizontal,
        children: list,
      );
    }

    List<Widget> loadItemList(items) {
      List<Widget> list = [];
      for (var item in items) {
        list.add(
          TransferItemLine(
            name: item['name'],
            quantity: item['quantity'],
            id: item['id'],
            addItem: addItem,
            removeItem: removeItem,
            isChecked: isChecked,
          ),
        );
      }
      return list;
    }

    return Column(
      children: <Widget>[
        Text(
          'ย้ายรายการจากโต๊ะ: ',
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        SizedBox(
          height: 70.0,
          child: setTransferTable(tableInfo.tablesData),
        ),
        Text(
          'โต๊ะ: $selectTable',
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        Container(
          margin: EdgeInsets.all(10.0),
          color: Colors.white,
          height: 250,
          child: Container(
              child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return new TransferItemLine(
                      name: items[index]['name'],
                      quantity: items[index]['quantity'],
                      id: items[index]['id'],
                      addItem: addItem,
                      removeItem: removeItem,
                      isChecked: isChecked,
                    );
                  })),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FlatButton(
              color: Colors.yellow,
              textColor: Colors.black,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: EdgeInsets.all(8.0),
              splashColor: Colors.blueAccent,
              child: Text(
                'ปืด',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: Colors.green,
              textColor: Colors.white,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: EdgeInsets.all(8.0),
              splashColor: Colors.blueAccent,
              child: Text(
                'ยืนยัน',
              ),
              onPressed: listItem.length != 0 && selectTable != '-'
                  ? () {
                      submitTransferOrder(
                          tableInfo.tableNo, listItem, selectTableId);
                    }
                  : null,
            )
          ],
        )
      ],
    );
  }
}

class TransferItemLine extends StatefulWidget {
  final String name;
  final int quantity;
  final Function addItem;
  final Function removeItem;
  final String id;
  final isChecked;
  TransferItemLine(
      {Key key,
      this.name,
      this.quantity,
      this.addItem,
      this.removeItem,
      this.id,
      this.isChecked})
      : super(key: key);
  @override
  _TransferItemLineState createState() => _TransferItemLineState();
}

class _TransferItemLineState extends State<TransferItemLine> {
  int quantity;
  bool isChecked;
  @override
  void initState() {
    quantity = widget.quantity;
    isChecked = widget.isChecked;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void increaseQuantity() {
      if (widget.quantity > quantity) {
        setState(() {
          quantity++;
        });
      }
    }

    void decreaseQuantity() {
      if (0 < quantity) {
        setState(() {
          quantity--;
        });
      }
    }

    void checkboxTap(value) {
      if (value) {
        widget.addItem(widget.id, quantity);
        setState(() {
          isChecked = value;
        });
      } else {
        widget.removeItem(widget.id);
        setState(() {
          quantity = widget.quantity;
          isChecked = value;
        });
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Checkbox(
                value: isChecked,
                onChanged: checkboxTap,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: GestureDetector(
                child: Icon(
                  FontAwesomeIcons.minus,
                  size: 25,
                ),
                onTap: () {
                  decreaseQuantity();
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              quantity.toString(),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              child: Icon(
                FontAwesomeIcons.plus,
                size: 25,
              ),
              onTap: () {
                increaseQuantity();
              },
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(widget.name),
            ),
          ),
        ],
      ),
    );
  }
}
