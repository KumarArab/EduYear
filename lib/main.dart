import 'package:app/Provider/login_store.dart';
import 'package:app/Screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: LoginStore())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.red,
          primarySwatch: Colors.red,
        ),
        home: SplashScreen(),
        // Test(),
        // routes: {
        //   '/test': (BuildContext context) => Test(),
        //   '/crest': (BuildContext context) => Crest(),
        // },
      ),
    );
  }
}
