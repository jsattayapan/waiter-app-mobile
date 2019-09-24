import 'package:flutter/material.dart';
import 'package:jep_restaurant_waiter_app/constants.dart';
import 'package:jep_restaurant_waiter_app/screens/login_page.dart' as s;

class TextInputField extends StatelessWidget {
  final FocusNode currentFocus;
  final FocusNode nextFocus;
  final String label;
  final inputType keyboard;
  final TextEditingController controller;

  TextInputField(
      {@required this.currentFocus,
      this.nextFocus,
      @required this.label,
      this.keyboard,
      @required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: label == 'Passcode' ? true : false,
      textInputAction:
          nextFocus == null ? TextInputAction.done : TextInputAction.next,
      focusNode: currentFocus,
      onFieldSubmitted: (term) {
        currentFocus.unfocus();
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        }
      },
      keyboardType: keyboard == inputType.number
          ? TextInputType.phone
          : TextInputType.text,
      style: TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        labelText: label,
        fillColor: Colors.white,
      ),
    );
  }
}
