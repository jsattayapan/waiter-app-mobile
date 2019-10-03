import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../constants.dart' as constants;
import './authentication.dart';

class Login with ChangeNotifier {
  var number;
  var name;
  var shortName;
  var position;
  var id;

  Future<Map> logInfo(String number, String passcode) async {
    var url = '${constants.serverIpAddress}api/users/staffs/login';
    try {
      var response = await http.post(url, body: {
        'number': number,
        'passcode': passcode,
        'platform': 'mobile-app-waiter'
      });

      var jsonData = json.decode(response.body);
      print('Token:');
      constants.token = jsonData['token'];
      print('Rsp Msg: ${jsonData['msg']}');
      print('Rsp Msg: ${jsonData['msg']}');
      if (response.statusCode == 200) {
        this.number = jsonData['number'];
        this.shortName = jsonData['short_name'];
        this.position = jsonData['position'];
        this.id = jsonData['id'];
        notifyListeners();
        return Future.value({'status': true});
      } else {
        return Future.value({'status': false, 'msg': jsonData['msg']});
      }
    } catch (er) {
      return Future.value(
          {'status': false, 'msg': 'ไม่สามารถเชื่อมต่อกับเซิฟเวอร์ได้'});
    }
  }

  Future logout() async {
    var url = '${constants.serverIpAddress}api/users/staffs/logout';
    await http.post(url,
        headers: {'AUTHENTICATION': constants.token}, body: {'id': this.id});

    this.number = null;
    this.name = null;
    this.shortName = null;
    this.position = null;
    this.id = null;
    notifyListeners();
  }
}
