import 'dart:io';

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../constants.dart' as constants;

class TableInfo with ChangeNotifier {
  String id;
  String tableNo;
  int numberOfGuest = 1;
  String zone;
  String language;
  String createBy;
  var timestamp;
  var tableLogs;
  var tablesData;

  var currentOrders;

  void minusGuest() {
    if (numberOfGuest > 1) {
      numberOfGuest--;
      notifyListeners();
    }
  }

  void reset() {
    this.numberOfGuest = 1;
    this.zone = null;
    this.language = null;
    this.tableNo = null;
    this.id = null;
    this.timestamp = null;
    this.currentOrders = [];
    notifyListeners();
  }

  void setZone(String zone) {
    this.zone = zone;
    notifyListeners();
  }

  void setLanguage(String language) {
    this.language = language;
    notifyListeners();
  }

  void addGuest() {
    numberOfGuest++;
    notifyListeners();
  }

  closeTable(id) {
    var url =
        '${constants.serverIpAddress}api/restaurant/tables/customer-tables/close';
    http.post(url,
        headers: {'AUTHENTICATION': constants.token},
        body: {'customer_table_id': id});
  }

  void checkBill(customerTableId, userId) async {
    print('checkBill');
    var url =
        '${constants.serverIpAddress}api/restaurant/tables/customer-tables/check-bill';
    await http.post(url,
        headers: {'AUTHENTICATION': constants.token},
        body: {'customer_table_id': customerTableId, 'user_id': userId});
  }

  Future isTableOnHold(number) async {
    var url =
        '${constants.serverIpAddress}api/restaurant/tables/tables/$number';
    var response =
        await http.get(url, headers: {'AUTHENTICATION': constants.token});
    if (response.statusCode == 200) {
      var body = json.decode(response.body)[0][0];
      if (body['status'] == 'available') {
        return ['available'];
      } else {
        return [body['status'], body['short_name']];
      }
    }
  }

  Future setTableLog(id) async {
    var url =
        '${constants.serverIpAddress}api/restaurant/tables/customer-tables/get-table-status/$id';
    var response =
        await http.get(url, headers: {'AUTHENTICATION': constants.token});
    var body1 = json.decode(response.body);
    url =
        '${constants.serverIpAddress}api/restaurant/tables/item-orders/get-all-orders-status/$id';
    response =
        await http.get(url, headers: {'AUTHENTICATION': constants.token});
    var body2 = json.decode(response.body);
    var logs = new List.from(body1)..addAll(body2);
    logs.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    tableLogs = logs;
    print(logs);
    notifyListeners();
  }

  setCurrentOrder(id) async {
    var url =
        '${constants.serverIpAddress}api/restaurant/tables/item-orders/$id';
    var response =
        await http.get(url, headers: {'AUTHENTICATION': constants.token});
    var body = json.decode(response.body);
    currentOrders = body;
    notifyListeners();
  }

  getCurrentOrder(id) async {
    var url =
        '${constants.serverIpAddress}api/restaurant/tables/item-orders/$id';
    var response =
        await http.get(url, headers: {'AUTHENTICATION': constants.token});
    var body = json.decode(response.body);
    return body;
  }

  void updateTableStatus(number, status, userId) async {
    var url =
        '${constants.serverIpAddress}api/restaurant/tables/tables/update-table-status';
    await http.put(url,
        headers: {'AUTHENTICATION': constants.token},
        body: {'number': number, 'status': status, 'hold_by': userId});
  }

  void setTableInfo(
      id, tableNo, numberOfGuest, zone, language, createBy, timestamp) async {
    var url = '${constants.serverIpAddress}api/users/staffs/$createBy';
    var response =
        await http.get(url, headers: {'AUTHENTICATION': constants.token});
    if (response.statusCode == 200) {
      this.createBy = json.decode(response.body)['short_name'];
    }
    this.id = id;
    this.tableNo = tableNo;
    this.timestamp = DateTime.parse(timestamp).toLocal();
    this.numberOfGuest = numberOfGuest;
    this.language = language;
    this.zone = zone;
    notifyListeners();
  }

  void getAllTable() async {
    print('TOken Form const:');
    print(constants.token);
    var url = '${constants.serverIpAddress}api/restaurant/tables/tables';
    var response =
        await http.get(url, headers: {'AUTHENTICATION': constants.token});
    print(response.statusCode);
    if (response.statusCode == 200) {
      if (json.decode(response.body) != this.tablesData) {
        this.tablesData = json.decode(response.body);
        notifyListeners();
      }
    }
  }

  void createCustomerTable(userId, tableNo, shortName) async {
    var url =
        '${constants.serverIpAddress}api/restaurant/tables/customer-tables/add';
    var customerTable = await http.post(url, headers: {
      'AUTHENTICATION': constants.token
    }, body: {
      'table_number': tableNo,
      'number_of_guest': numberOfGuest.toString(),
      'language': language,
      'zone': zone,
      'create_by': userId
    });

    this.createBy = shortName;

    var jsonData = json.decode(customerTable.body);
    this.tableNo = jsonData['table_number'];
    this.timestamp = DateTime.parse(jsonData['timestamp']);
    this.numberOfGuest = jsonData['number_of_guest'];
    this.language = jsonData['language'];
    this.id = jsonData['id'];
    notifyListeners();
  }
}
