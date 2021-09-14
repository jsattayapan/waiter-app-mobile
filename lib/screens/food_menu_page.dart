import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jep_restaurant_waiter_app/brains/food_items.dart';
import 'package:jep_restaurant_waiter_app/brains/login.dart';
import 'package:jep_restaurant_waiter_app/brains/table.dart';
import 'package:jep_restaurant_waiter_app/widgets/container_bar.dart';
import 'package:jep_restaurant_waiter_app/widgets/custom_alert.dart';
import 'package:jep_restaurant_waiter_app/widgets/round_button_icon.dart';

import 'package:jep_restaurant_waiter_app/widgets/table_header_bar.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../constants.dart';

int currentPage = 0;
final formatCurrency = new NumberFormat("#,##0", "en_US");

class FoodMenuPage extends StatefulWidget {
  @override
  _FoodMenuPageState createState() => _FoodMenuPageState();
}

class _FoodMenuPageState extends State<FoodMenuPage> {
  var newOrderItems = [];
  var allItems = [];
  var filterItem = [];

  addNewOrderItem(item) {
    setState(() {
      newOrderItems.add({
        'name': item['name'],
        'english_name': item['english_name'],
        'code': item['code'],
        'quantity': item['quantity'],
        'remark': item['remark'],
        'price': item['price']
      });
      filterItem = [];
    });
  }

  adjustOrderItem(item) {
    print(item['code']);
    final tile = newOrderItems.firstWhere((i) => i['code'] == item['code']);
    print(tile);
    setState(() {
      tile['quantity'] = item['quantity'];
      tile['remark'] = item['remark'];
    });
    print(newOrderItems);
  }

  removeOrderItem(code) {
    setState(() {
      newOrderItems.removeWhere((item) => item['code'] == code);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    var tableInfo = Provider.of<TableInfo>(context);
    var userInfo = Provider.of<Login>(context);
    var foodItems = Provider.of<FoodItems>(context);

    final pageController = PageController();
    final SlidableController slidableController = SlidableController();

    final codeController = TextEditingController();

    ListView setCategorySection(data) {
      List<Widget> list = new List();
      var count = 0;
      for (var category in data) {
        list.add(
          Container(
            child: Container(
                child: FoodCatButton(
                    label: category['category'],
                    color: secondaryColor,
                    pageController: pageController,
                    page: count)),
          ),
        );
        count++;
      }
      return ListView(
        scrollDirection: Axis.horizontal,
        children: list,
      );
    }

    PageView setItemBox(data) {
      allItems = [];
      List<Widget> list = new List();
      for (var cate in data) {
        List<Widget> column = new List();
        for (var sub_cate in cate['sub_category']) {
          List<Widget> listItem = new List();
          for (var item in sub_cate['items']) {
            allItems.add({
              'code': item['code'].toString(),
              'name': item['name'],
              'english_name': item['english_name'],
              'price': item['price']
            });
            listItem.add(ItemContainer(
              label: item['name'],
              code: item['code'].toString(),
              english_name: item['english_name'],
              price: item['price'],
              addNewOrderItem: addNewOrderItem,
            ));
          }
          if (listItem.length != 0) {
            column.add(Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    sub_cate['sub_category'],
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ));
            column.add(Flexible(
              child: GridView.count(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  childAspectRatio: (1 / 1.3),
                  primary: false,
                  padding: const EdgeInsets.all(10.0),
                  crossAxisSpacing: 10.0,
                  crossAxisCount: 4,
                  children: listItem),
            ));
          }
        }
        list.add(ListView(
          children: <Widget>[
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: column,
              ),
            ),
            SizedBox(
              height: 10,
            )
          ],
        ));
      }
      return PageView(
        controller: pageController,
        children: list,
        onPageChanged: (int value) {
          setState(() {
            currentPage = value;
          });
        },
      );
    }

    List currentNewOrder(orders) {
      List<Widget> list = new List();

      if (orders.length != 0) {
        for (var order in orders) {
          if (order['remark'] == '') {
            list.add(Slidable(
              controller: slidableController,
              actions: <Widget>[
                IconSlideAction(
                  caption: 'แก้ไข',
                  color: Colors.blue,
                  icon: Icons.build,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Container(
                              width: 200.0,
                              height: 450.0,
                              color: Colors.grey.shade900,
                              child: AdjustFoodItemContent(
                                  label: order['name'],
                                  code: order['code'],
                                  remark: order['remark'],
                                  quantity: order['quantity'].toInt(),
                                  adjustOrderItem: adjustOrderItem,
                                  removeOrderItem: removeOrderItem),
                            ),
                          );
                        });
                  },
                ),
              ],
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                            flex: 1, child: Text(order['quantity'].toString())),
                        Expanded(flex: 15, child: Text(order['name'])),
                        //TODO: TO FIX
                        Expanded(
                            flex: 3,
                            child: Text(
                                '฿ ${formatCurrency.format((order['price'] * order['quantity'])).toString()}.-')),
                        SizedBox(
                          height: 30,
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        '${order['english_name']}',
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
              ),
            ));
          } else {
            list.add(Slidable(
              controller: slidableController,
              actions: <Widget>[
                IconSlideAction(
                  caption: 'แก้ไข',
                  color: Colors.blue,
                  icon: Icons.build,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Container(
                              width: 200.0,
                              height: 450.0,
                              color: Colors.grey.shade900,
                              child: AdjustFoodItemContent(
                                  label: order['name'],
                                  code: order['code'],
                                  remark: order['remark'],
                                  quantity: order['quantity'].toInt(),
                                  adjustOrderItem: adjustOrderItem,
                                  removeOrderItem: removeOrderItem),
                            ),
                          );
                        });
                  },
                ),
              ],
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                            flex: 1, child: Text(order['quantity'].toString())),
                        Expanded(flex: 15, child: Text(order['name'])),
                        Expanded(
                            flex: 3,
                            child: Text(
                                '฿ ${formatCurrency.format((order['price'] * order['quantity'])).toString()}.-')),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        '${order['english_name']}',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        '** ${order['remark']}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
              ),
            ));
          }
        }
      } else {
        list = [];
      }
      return list;
    }

    codeSubmited() async {
      var code = codeController.text;
      var firstChar = code[0];
      if (firstChar == '#') {
        print(code.substring(1));
        var items = await foodItems.getOnlineItemsByNumber(code.substring(1));
        print('ok');
        print(items);
        if (items['items'].length != 0) {
          for (var x in items['items']) {
            var item = allItems.where((i) => i['code'] == x['code']).toList();
            addNewOrderItem({
              'name': item[0]['name'],
              'english_name': item[0]['english_name'],
              'code': item[0]['code'],
              'quantity': x['quantity'],
              'remark': '',
              'price': item[0]['price']
            });
          }
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                  label: 'เพิ่ม ' +
                      items['items'].length.toString() +
                      'รายการใหม่');
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(label: 'รหัสรายการไม่ถูกต้อง');
            },
          );
        }
      } else {
        var item = allItems.where((i) => i['code'] == code).toList();
        print(item.length);
        codeController.text = '';
        if (item.length != 0) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  child: Container(
                    width: 200.0,
                    height: 450.0,
                    color: Colors.grey.shade900,
                    child: CreateFoodItemContent(
                      label: item[0]['name'],
                      english_name: item[0]['english_name'],
                      price: item[0]['price'],
                      code: code,
                      addNewOrderItem: addNewOrderItem,
                    ),
                  ),
                );
              });
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(label: 'รหัสรายการไม่ถูกต้อง');
            },
          );
        }
      }
    }

    if (foodItems.itemsData == null) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: Center(child: Text('Loading...')),
        ),
      );
    } else {
      return Scaffold(
        body: SlidingUpPanel(
          panel: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                'รายการอาหาร (${newOrderItems.length})',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              Expanded(
                child: Container(
                  child: ListView(
                    children: currentNewOrder(newOrderItems),
                  ),
                ),
              ),
            ],
          ),
          minHeight: 40.0,
          body: SafeArea(
              child: Column(
            children: <Widget>[
              TableHeaderBar(
                tableInfo: tableInfo,
                userInfo: userInfo,
                button: newOrderItems.length != 0
                    ? FlatButton(
                        color: primaryTextColor,
                        onPressed: () {
                          foodItems.sendNewOrderToServer(
                              userInfo.id, tableInfo.id, newOrderItems);
                          int count = 0;
                          Navigator.of(context).popUntil((_) => count++ >= 2);
                          tableInfo.updateTableStatus(
                              tableInfo.tableNo, 'available', "");
                          tableInfo.reset();
                        },
                        child: Text('บันทึก'),
                      )
                    : FlatButton(
                        color: primaryTextColor,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('กลับ'),
                      ),
              ),
              ContainerBar(
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: TextField(
                        controller: codeController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: primaryColor),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          labelText: 'รหัสเมนู',
                          fillColor: primaryColor,
                        ),
                        onSubmitted: (value) {
                          codeSubmited();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    //TODO: Add item to prepare order list
                    CustomButton(
                      label: 'ค้นหา',
                      color: primaryColor,
                      onTap: () {
                        var code = codeController.text;
                        if (code == '') {
                          setState(() {
                            filterItem = [];
                          });
                        } else {
                          var itemByCode = allItems
                              .where((i) => i['code'].contains(code))
                              .toList();
                          var itemByName = allItems
                              .where((i) => i['name'].contains(code))
                              .toList();
                          List<Widget> listItem = new List();
                          for (var item in itemByCode) {
                            listItem.add(ItemContainer(
                              label: item['name'],
                              code: item['code'].toString(),
                              english_name: item['english_name'],
                              price: item['price'],
                              addNewOrderItem: addNewOrderItem,
                            ));
                          }
                          for (var item in itemByName) {
                            listItem.add(ItemContainer(
                              label: item['name'],
                              code: item['code'].toString(),
                              english_name: item['english_name'],
                              price: item['price'],
                              addNewOrderItem: addNewOrderItem,
                            ));
                          }
                          setState(() {
                            filterItem = listItem;
                          });
                          if (listItem.length == 0) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomAlertDialog(
                                    label: 'ไม่พบรายการอาหารนี้');
                              },
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              Container(
                height: 50.0,
                color: Colors.white,
                child: setCategorySection(foodItems.itemsData),
              ),
              Expanded(
                child: filterItem.length == 0
                    ? setItemBox(foodItems.itemsData)
                    : GridView.count(
                        shrinkWrap: true,
                        // todo comment this out and check the result
                        physics: ClampingScrollPhysics(),
                        childAspectRatio: (1 / 1.3),
                        primary: false,
                        padding: const EdgeInsets.all(10.0),
                        crossAxisSpacing: 10.0,
                        crossAxisCount: 4,
                        children: filterItem),
              ),
              SizedBox(
                height: 40.0,
              )
            ],
          )),
        ),
      );
    }
  }
}

class CustomButton extends StatelessWidget {
  final Function onTap;
  final String label;
  final color;
  const CustomButton({Key key, this.onTap, this.label, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: color,
      onPressed: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class ItemContainer extends StatelessWidget {
  final String label;
  final String code;
  final String english_name;
  final Function addNewOrderItem;
  final int price;
  ItemContainer(
      {this.label,
      this.code,
      this.addNewOrderItem,
      this.price,
      this.english_name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Container(
                  width: 200.0,
                  height: 450.0,
                  color: Colors.grey.shade900,
                  child: CreateFoodItemContent(
                    label: label,
                    english_name: english_name,
                    code: code,
                    price: price,
                    addNewOrderItem: addNewOrderItem,
                  ),
                ),
              );
            });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: primaryColor,
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: Text(
                label,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              top: 0,
              left: 5,
              child: Text(
                code,
                style: TextStyle(color: Colors.white, fontSize: 12.0),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 5,
              child: Text(
                '${formatCurrency.format(price).toString()}.-',
                style: TextStyle(color: Colors.white, fontSize: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateFoodItemContent extends StatefulWidget {
  final String label;
  final String english_name;
  final String code;
  final Function addNewOrderItem;
  final int price;
  const CreateFoodItemContent({
    Key key,
    this.label,
    this.code,
    this.addNewOrderItem,
    this.price,
    this.english_name,
  }) : super(key: key);

  @override
  _CreateFoodItemContentState createState() => _CreateFoodItemContentState();
}

class _CreateFoodItemContentState extends State<CreateFoodItemContent> {
  int itemQuantity = 1;
  final remarkController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Text(
                'รายการ: ',
                style: TextStyle(
                    fontSize: 20.0,
                    color: lightPrimaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 20.0,
                  color: lightPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'จำนวน:',
              style: TextStyle(
                  fontSize: 20.0,
                  color: lightPrimaryColor,
                  fontWeight: FontWeight.bold),
            ),
            RoundIconButton(
              icon: FontAwesomeIcons.minus,
              onPressed: () {
                setState(() {
                  if (itemQuantity > 1) {
                    itemQuantity--;
                  }
                });
              },
            ),
            Text(
              itemQuantity.toString(),
              style: TextStyle(
                  color: lightPrimaryColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            RoundIconButton(
              icon: FontAwesomeIcons.plus,
              onPressed: () {
                setState(() {
                  itemQuantity++;
                });
              },
            ),
          ],
        ),
        new ColorTextField(
          color: Colors.white,
          label: 'หมายเหตุ',
          controller: remarkController,
        ),
        //TODO: Add item to prepare list
        CustomButton(
          color: primaryColor,
          label: 'เพิ่ม',
          onTap: () {
            // TODO: Update item in list
            widget.addNewOrderItem({
              'name': widget.label,
              'english_name': widget.english_name,
              'code': widget.code,
              'quantity': itemQuantity,
              'remark': remarkController.text,
              'price': widget.price
            });
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class AdjustFoodItemContent extends StatefulWidget {
  final String label;
  final String code;
  final quantity;
  final remark;
  final Function adjustOrderItem;
  final Function removeOrderItem;
  const AdjustFoodItemContent({
    Key key,
    this.label,
    this.code,
    this.quantity,
    this.remark,
    this.adjustOrderItem,
    this.removeOrderItem,
  }) : super(key: key);

  @override
  _AdjustFoodItemContentState createState() =>
      _AdjustFoodItemContentState(itemQuantity: quantity, remark: remark);
}

class _AdjustFoodItemContentState extends State<AdjustFoodItemContent> {
  int itemQuantity;
  String remark;
  _AdjustFoodItemContentState({this.itemQuantity, this.remark});
  final remarkController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    remarkController.text = remark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Text(
                'รายการ: ',
                style: TextStyle(
                    fontSize: 20.0,
                    color: lightPrimaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 20.0,
                  color: lightPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'จำนวน:',
              style: TextStyle(
                  fontSize: 20.0,
                  color: lightPrimaryColor,
                  fontWeight: FontWeight.bold),
            ),
            RoundIconButton(
              icon: FontAwesomeIcons.minus,
              onPressed: () {
                setState(() {
                  if (itemQuantity > 1) {
                    itemQuantity--;
                  }
                });
              },
            ),
            Text(
              itemQuantity.toString(),
              style: TextStyle(
                  color: lightPrimaryColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            RoundIconButton(
              icon: FontAwesomeIcons.plus,
              onPressed: () {
                setState(() {
                  itemQuantity++;
                });
              },
            ),
          ],
        ),
        new ColorTextField(
          color: Colors.white,
          label: 'หมายเหตุ',
          controller: remarkController,
        ),
        //TODO: Add item to prepare list
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            CustomButton(
              label: 'ลบ',
              color: Colors.red,
              onTap: () {
                // TODO: Update item in list
                widget.removeOrderItem(widget.code);
                Navigator.pop(context);
              },
            ),
            CustomButton(
              label: 'แก้ไข',
              color: Colors.orange,
              onTap: () {
                // TODO: Update item in list
                widget.adjustOrderItem({
                  'name': widget.label,
                  'code': widget.code,
                  'quantity': itemQuantity,
                  'remark': remarkController.text
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class ColorTextField extends StatelessWidget {
  final Color color;
  final String label;
  final TextEditingController controller;
  const ColorTextField({Key key, this.color, this.label, this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: TextField(
          controller: controller,
          style: TextStyle(color: color),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelStyle: TextStyle(color: color),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
            labelText: label,
            fillColor: color,
          ),
        ),
      ),
    );
  }
}

class FoodCatButton extends StatelessWidget {
  final Color color;
  final String label;
  final pageController;
  final page;
  FoodCatButton({this.label, this.color, this.pageController, this.page});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.0),
        decoration: BoxDecoration(
          color: currentPage == page
              ? Colors.green.shade900
              : Colors.green.shade600,
          borderRadius: BorderRadius.circular(10.0),
        ),
        height: 40.0,
        width: 100,
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
