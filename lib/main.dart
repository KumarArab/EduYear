import 'package:app/Provider/login_store.dart';
import 'package:app/Screens/Login-System/get-details.dart';
import 'package:app/Screens/home_screen.dart';
import 'package:app/Screens/post_Image.dart';
import 'package:app/Screens/splash_screen.dart';
import 'package:app/Screens/user_profile.dart';
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
          fontFamily: "Poppins",
        ),
        home: SplashScreen(),
        // Test(),
        routes: {
          SplashScreen.routeName: (BuildContext context) => SplashScreen(),
          HomeScreen.routeName: (BuildContext context) => HomeScreen(),
          UserProfile.routeName: (BuildContext context) => UserProfile(),
          PostImage.routeName: (BuildContext context) => PostImage(),
          GetDetails.routeName: (BuildContext context) => GetDetails(),
        },
      ),
    );
  }
}
