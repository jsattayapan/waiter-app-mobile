import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jep_restaurant_waiter_app/screens/login_page.dart';
import 'package:jep_restaurant_waiter_app/screens/tables_page.dart';
import 'package:jep_restaurant_waiter_app/utilities/socket.dart';
import 'package:provider/provider.dart';
import 'package:jep_restaurant_waiter_app/brains/login.dart';
import 'package:jep_restaurant_waiter_app/brains/table.dart';

import 'brains/food_items.dart';
import 'constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return RestartWidget(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(builder: (_) => Login()),
          ChangeNotifierProvider(builder: (_) => TableInfo()),
          ChangeNotifierProvider(builder: (_) => FoodItems()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Jep\'s Restaurant ',
          theme: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            scaffoldBackgroundColor: Color(0xFFf9fbe7),
            splashColor: Colors.white,
          ),
          home: MyHomePage(title: 'Flutter Demo Home Page'),
          routes: {
            // When navigating to the "/" route, build the FirstScreen widget.
            '/login': (context) => LoginPage(),
            // When navigating to the "/second" route, build the SecondScreen widget.
            '/tables': (context) => TablesPage(),
            '/socket': (context) => Socket()
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: LoginPage(),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
//    if (state == AppLifecycleState.paused) {
//      var tableInfo = Provider.of<TableInfo>(context);
//      var userInfo = Provider.of<Login>(context);
//      tableInfo.reset();
//      userInfo.logout();
//      Navigator.pushReplacementNamed(context, '/login');
//    }
  }
}

class RestartWidget extends StatefulWidget {
  final Widget child;

  RestartWidget({this.child});

  static restartApp(BuildContext context) {
    final _RestartWidgetState state =
        context.ancestorStateOfType(const TypeMatcher<_RestartWidgetState>());
    state.restartApp();
  }

  @override
  _RestartWidgetState createState() => new _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = new UniqueKey();

  void restartApp() {
    this.setState(() {
      key = new UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      key: key,
      child: widget.child,
    );
  }
}
