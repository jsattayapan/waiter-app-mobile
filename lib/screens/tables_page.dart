import 'package:flutter/material.dart';
import 'package:jep_restaurant_waiter_app/brains/login.dart';
import 'package:jep_restaurant_waiter_app/brains/table.dart';
import 'package:jep_restaurant_waiter_app/utilities/socket.dart';

import 'package:jep_restaurant_waiter_app/widgets/create_table_contents.dart';
import 'package:jep_restaurant_waiter_app/widgets/table_box.dart';
import 'package:jep_restaurant_waiter_app/widgets/table_section.dart';

import 'package:provider/provider.dart';

import '../constants.dart';

PageController pageController;
int currentPage = 0;

class TablesPage extends StatefulWidget {
  @override
  TablesPageState createState() => TablesPageState();
}

class TablesPageState extends State<TablesPage> {
  List<Widget> tableSections;

  final pageController = PageController();

  @override
  initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var userInfo = Provider.of<Login>(context);
    var tableInfo = Provider.of<TableInfo>(context);

    Row setSectionTables(data) {
      List<Widget> list = new List();
      int count = 0;
      for (var table in data) {
        if (table['section'] != 'ETC') {
          list.add(TableSection(
            label: table['section'],
            page: count,
            pageController: pageController,
          ));
          count++;
        }
      }
      setState(() {
        tableSections = list;
      });

      return Row(children: list);
    }

    Expanded setBoxTable(data) {
      List<Widget> list = new List();
      for (var tableSection in data) {
        List<Widget> gridList = new List();
        if (tableSection['section'] != 'ETC') {
          for (var table in tableSection['tables']) {
            gridList.add(
              TableBox(
                tableNo: table['number'],
                status: table['status'],
                numberOfGuest: table['number_of_guest'],
                zone: table['zone'],
                id: table['id'],
                createBy: table['create_by'],
                timestamp: table['timestamp'],
                section: table['section'],
              ),
            );
          }
          list.add(
            GridView.count(
                childAspectRatio: (1 / 1.3),
                primary: false,
                padding: const EdgeInsets.all(10.0),
                crossAxisSpacing: 10.0,
                crossAxisCount: 4,
                children: gridList),
          );
        }
      }
      return Expanded(
        child: Center(
          child: PageView(
              onPageChanged: (int value) {
                setState(() {
                  currentPage = value;
                });
              },
              controller: pageController,
              children: list),
        ),
      );
    }

    if (tableInfo.tablesData == null) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: Center(child: Text('Loading...')),
        ),
      );
    } else {
      return WillPopScope(
        onWillPop: () async => false,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover),
          ),
          child: Scaffold(
            backgroundColor: Color.fromRGBO(35, 255, 255, 0.6),
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Container(
                    color: primaryColor,
                    height: 70.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          'โต๊ะ',
                          style: tableNoLabel,
                        ),
                        Text(
                          'บริกร: ${userInfo.shortName}',
                          style: TextStyle(color: lightPrimaryColor),
                        ),
                        FlatButton(
                            onPressed: () {
                              userInfo.logout();
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: Text(
                              'ออกจากระบบ',
                              style: TextStyle(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline),
                            ))
                      ],
                    ),
                  ),
                  setSectionTables(tableInfo.tablesData),
                  setBoxTable(tableInfo.tablesData),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
