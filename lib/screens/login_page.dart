import 'package:flutter/material.dart';
import 'package:jep_restaurant_waiter_app/brains/table.dart';
import 'package:jep_restaurant_waiter_app/utilities/socket.dart';
import 'package:jep_restaurant_waiter_app/widgets/custom_alert.dart';
import 'package:jep_restaurant_waiter_app/widgets/text_input_field.dart';
import 'package:jep_restaurant_waiter_app/constants.dart';
import 'package:jep_restaurant_waiter_app/brains/login.dart';
import 'package:jep_restaurant_waiter_app/screens/tables_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants.dart';

class LoginPage extends StatelessWidget {
  var _idController = TextEditingController();
  var _passcodeController = TextEditingController();
  var _idFocus = FocusNode();
  var _passcodeFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    var userInfo = Provider.of<Login>(context);

    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 0, 0, 0.6),
      body: Center(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Image(
                    image: AssetImage('assets/images/jep_logo.png'),
                    height: 150.0,
                  ),
                  Text(
                    'เข้าสู่ระบบ',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Sarabun',
                        fontSize: 25.0),
                  ),
                  TextInputField(
                      currentFocus: _idFocus,
                      nextFocus: _passcodeFocus,
                      label: 'ID',
                      keyboard: inputType.number,
                      controller: _idController),
                  TextInputField(
                    label: 'Passcode',
                    currentFocus: _passcodeFocus,
                    controller: _passcodeController,
                    keyboard: inputType.number,
                  ),
                  new LoginButton(
                      idController: _idController,
                      passcodeController: _passcodeController,
                      userInfo: userInfo)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginButton extends StatefulWidget {
  const LoginButton({
    Key key,
    @required TextEditingController idController,
    @required TextEditingController passcodeController,
    @required this.userInfo,
  })  : _idController = idController,
        _passcodeController = passcodeController,
        super(key: key);

  final TextEditingController _idController;
  final TextEditingController _passcodeController;
  final Login userInfo;

  @override
  _LoginButtonState createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  bool isTapable = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.0,
      height: 50.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: isTapable ? primaryColor : Colors.grey.shade600),
      child: GestureDetector(
        onTap: () async {
          if (isTapable) {
            setState(() {
              isTapable = false;
            });
            if (widget._idController.text == '' ||
                widget._passcodeController.text == '') {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomAlertDialog(label: 'กรุณาใส่บัญชีและรหัสผ่าน');
                },
              );
              setState(() {
                isTapable = true;
              });
            } else {
              var result = await widget.userInfo.logInfo(
                  widget._idController.text, widget._passcodeController.text);
              if (result == null) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SpinKitWave(
                        color: primaryColor,
                        size: 30.0,
                      );
                    });
                setState(() {
                  isTapable = true;
                });
              } else if (result == 'pass') {
                var tableInfo = Provider.of<TableInfo>(context);
                tableInfo.getAllTable();
                Navigator.pushReplacementNamed(context, '/socket');
                setState(() {
                  isTapable = true;
                });
              } else if (result == 'incorrect') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomAlertDialog(
                        label: 'บัญชี หรือ รหัสผ่านไม่ถูกต้อง');
                  },
                );
                setState(() {
                  isTapable = true;
                });
              } else if (result == 'signedIn') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomAlertDialog(
                        label: 'บัญญชีนี้กำลังถูกใช้งานอยู่');
                  },
                );
                setState(() {
                  isTapable = true;
                });
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomAlertDialog(
                        label: 'ไม่สามารถเชื่อมต่อกับเซิฟเวอร์ได้');
                  },
                );
                setState(() {
                  isTapable = true;
                });
              }
            }
          } else {
            //TODO: Tabale is False
          }
        },
        child: Center(
          child: Text(
            isTapable ? 'Login' : 'Loading...',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
