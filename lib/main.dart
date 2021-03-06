import 'package:app/Login-System/get-details.dart';
import 'package:app/Provider/login_store.dart';
import 'package:app/Provider/user_activity.dart';
import 'package:app/Screens/Profile/edit_profile.dart';
import 'package:app/Screens/Profile/visit_profile.dart';
import 'package:app/Screens/banners.dart';
import 'package:app/Screens/home_screen.dart';
import 'package:app/Screens/post_screens/post_Image.dart';
import 'package:app/Screens/post_screens/post_document.dart';
import 'package:app/Screens/post_screens/post_polls.dart';
import 'package:app/Screens/post_screens/post_tweet.dart';
import 'package:app/Screens/Search%20Views/search_screen.dart';
import 'package:app/Screens/shared-post.dart';
import 'package:app/Screens/splash_screen.dart';
import 'package:app/Screens/Profile/user_profile.dart';
import 'package:app/helpers/user_data.dart';
import 'package:app/helpers/visitors_data.dart';
import 'package:app/test.dart';
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
      providers: [
        ChangeNotifierProvider.value(value: LoginStore()),
        ChangeNotifierProvider.value(value: UserActivity()),
        ChangeNotifierProvider.value(value: UserData()),
        ChangeNotifierProvider.value(value: VisitorData())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.grey,
          primarySwatch: Colors.grey,
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
          PostTweet.routeName: (BuildContext context) => PostTweet(),
          PostPolls.routeName: (BuildContext context) => PostPolls(),
          PostDocument.routeName: (BuildContext context) => PostDocument(),
          SearchScreen.routeName: (BuildContext context) => SearchScreen(),
          VisitProfile.routeName: (BuildContext context) => VisitProfile(),
          SharedPost.routeName: (BuildContext context) => SharedPost(),
          Banners.routeName: (BuildContext context) => Banners(),
          EditProfile.routeName: (BuildContext context) => EditProfile(),
        },
      ),
    );
  }
}
