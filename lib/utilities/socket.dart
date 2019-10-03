import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jep_restaurant_waiter_app/brains/login.dart';
import 'package:jep_restaurant_waiter_app/brains/table.dart';
import 'package:jep_restaurant_waiter_app/screens/tables_page.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

import 'package:adhara_socket_io/adhara_socket_io.dart';

class Socket extends StatefulWidget {
  @override
  SocketState createState() => SocketState();
}

class SocketState extends State<Socket> {
  SocketIO socket;
  SocketIOManager manager = SocketIOManager();

  initSocket() async {
    socket = await manager.createInstance(SocketOptions(serverIpAddress,
        query: {
          "auth": "--SOME AUTH STRING---",
          "info": "new connection from adhara-socketio",
          "timestamp": DateTime.now().toString()
        },
        enableLogging: false,
        transports: [Transports.WEB_SOCKET, Transports.POLLING]));

    socket.connect();

    var userInfo = Provider.of<Login>(context);
    socket.emit('setUserId', [userInfo.id]);

    socket.on('tableUpdate', (data) {
      print('out update table');
      var tableInfo = Provider.of<TableInfo>(context);
      tableInfo.getAllTable();
    });

    socket.on('forceWaiterMobileLogout', (data) {
      userInfo.logout();
      Navigator.pushReplacementNamed(context, '/login');
    });

    print(socket);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSocket();
    print('Socket: Build Method');
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TablesPage();
  }
}
