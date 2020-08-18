import 'package:app/Provider/login_store.dart';
import 'package:app/Screens/Home%20Views/docs_view.dart';
import 'package:app/Screens/Home%20Views/image_view.dart';
import 'package:app/Screens/Home%20Views/poll_view.dart';
import 'package:app/Screens/Home%20Views/tweet_view.dart';
import 'package:app/Screens/post_screens/post_Image.dart';
import 'package:app/Screens/post_screens/post_document.dart';
import 'package:app/Screens/post_screens/post_polls.dart';
import 'package:app/Screens/post_screens/post_tweet.dart';
import 'package:app/Screens/Search%20Views/search_screen.dart';
import 'package:app/Screens/Profile/user_profile.dart';
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
  PageController _controller = PageController(
    initialPage: 0,
  );
  Map<String, String> _paths;

  Future<void> openFileExplorer() async {
    try {
      // setState(() {
      //   isUploadig = true;
      // });
      _paths = await FilePicker.getMultiFilePath(type: FileType.image);
      Map<String, String> paths = _paths;
      paths.forEach((key, value) {
        print("$key : $value");
      });
      Navigator.of(context).pushNamed(
        PostImage.routeName,
        arguments: ImagePost(paths: paths),
      );
      // setState(() {
      //   isUploadig = false;
      // });
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  Future<void> openPdfExplorer() async {
    String docPath = await FilePicker.getFilePath(type: FileType.custom);
    String _extension = docPath.toString().split(".").last;
    print(docPath);
    if (_extension == "pdf") {
      Navigator.of(context)
          .pushNamed(PostDocument.routeName, arguments: docPath);
    }
  }

  showAlertDailogBox(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Center(
            child: Text("Menu"),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.add),
                title: Text("Add new post"),
                onTap: () => openFileExplorer(),
              ),
              ListTile(
                leading: Icon(Icons.text_rotation_none),
                title: Text("Add new tweet"),
                onTap: () => Navigator.pushNamed(context, PostTweet.routeName),
              ),
              ListTile(
                leading: Icon(Icons.poll),
                title: Text("Add new Poll"),
                onTap: () => Navigator.pushNamed(context, PostPolls.routeName),
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text("Add new Pdf"),
                onTap: () => openPdfExplorer(),
              ),
              // ListTile(
              //   leading: Icon(Icons.search),
              //   title: Text("Search"),
              //   onTap: () =>
              //       Navigator.pushNamed(context, SearchScreen.routeName),
              // ),
              ListTile(
                leading: Icon(Icons.supervised_user_circle),
                title: Text("Profile"),
                onTap: () {
                  Navigator.of(context).popAndPushNamed('/user-profile');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "APPNAME",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, SearchScreen.routeName);
            },
          ),
        ],
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
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                showAlertDailogBox(context);
              },
              child: Icon(Icons.menu, color: Colors.black),
            ),
          ),
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
