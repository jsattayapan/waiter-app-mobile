library my_prj.globals;

import 'package:flutter/material.dart';

enum inputType { number, text }

const serverIpAddress = 'http://192.168.1.55:2222/';

Color primaryColor = Color(0xFF004498);
Color primaryTextColor = Color(0xFFFEC500);
Color secondaryColor = Color(0xFFdbc7af);
Color lightPrimaryColor = Color(0xFFf6fbff);
Color darkPrimaryColor = Color(0xFF001e38);

TextStyle tableNoLabel = TextStyle(fontSize: 30.0, color: lightPrimaryColor);

var token = '';
