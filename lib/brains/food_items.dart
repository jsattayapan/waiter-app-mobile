import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:jep_restaurant_waiter_app/constants.dart';
import 'package:http/http.dart' as http;
import '../constants.dart' as constants;

class FoodItems with ChangeNotifier {
  var itemsData;

  getFoodItems() async {
    var url = '${serverIpAddress}api/restaurant/items/menu-items';
    var response = await http.get(
      url,
      headers: {'AUTHENTICATION': constants.token},
    );
    if (response.statusCode == 200) {
      if (json.decode(response.body) != this.itemsData) {
        this.itemsData = json.decode(response.body);
        notifyListeners();
      }
    }
  }

  sendNewOrderToServer(userInfo, tableInfo, newItems) async {
    var url = '${serverIpAddress}api/restaurant/tables/item-orders/add';
    var jsonItems = json.encode(newItems);
    await http.post(url,
        headers: {'AUTHENTICATION': constants.token},
        body: {'userId': userInfo, 'tableId': tableInfo, 'items': jsonItems});
  }
}
