import 'package:app/Screens/Home%20Views/docs_view.dart';
import 'package:app/Screens/Home%20Views/image_view.dart';
import 'package:app/Screens/Home%20Views/poll_view.dart';
import 'package:app/Screens/Home%20Views/tweet_view.dart';
import 'package:app/Screens/banners.dart';
import 'package:app/Screens/post_screens/post_Image.dart';
import 'package:app/Screens/post_screens/post_document.dart';
import 'package:app/Screens/post_screens/post_polls.dart';
import 'package:app/Screens/post_screens/post_tweet.dart';
import 'package:app/Screens/Search%20Views/search_screen.dart';
import 'package:app/Screens/Profile/user_profile.dart';
import 'package:app/helpers/common_widgets.dart';
import 'package:app/helpers/handle_dynamicLinks.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:app/models/image_post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../widgets/button.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserMaintainer userMaintainer = UserMaintainer();
  DynamicLinksService dynamicLinksService = DynamicLinksService();

  PageController _controller = PageController(
    initialPage: 0,
  );

  @override
  void didChangeDependencies() async {
    await dynamicLinksService.handleDynamicLinks(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "APPNAME",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notification_important, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, Banners.routeName);
            },
          ),
        ],
      ),
      bottomNavigationBar: Manual(
        screen: "home",
      ),
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: [
              ImageSection(
                all: false,
              ),
              TweetSection(
                all: false,
              ),
              PollSection(
                all: false,
              ),
              DocsSection(
                all: false,
              ),
            ],
          ),
          // Positioned(
          //   bottom: 0,
          //   child:
          // )

          // Positioned(
          //   bottom: 20,
          //   right: 20,
          //   child: FloatingActionButton(
          //     backgroundColor: Colors.black,
          //     onPressed: () {
          //       showAlertDailogBox(context);
          //     },
          //     child: Icon(Icons.menu, color: Colors.white),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// Positioned(
//   right: 20,
//   top: 40,
//   child: CircleAvatar(
//     backgroundColor: Colors.black,
//     radius: 25,
//     child: Padding(
//       padding: EdgeInsets.all(10),
//       child: GestureDetector(
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (ctx) => UserProfile(),
//           ),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(100),
//           child: SvgPicture.asset(
//             "assets/img/user(0).svg",
//             color: Colors.grey,
//             fit: BoxFit.cover,
//           ),
//         ),
//       ),
//     ),
//   ),
// )
