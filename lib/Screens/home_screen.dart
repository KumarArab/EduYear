import 'package:app/Provider/login_store.dart';
import 'package:app/Screens/Home%20Views/docs_view.dart';
import 'package:app/Screens/Home%20Views/image_view.dart';
import 'package:app/Screens/Home%20Views/poll_view.dart';
import 'package:app/Screens/Home%20Views/tweet_view.dart';
import 'package:app/Screens/post_Image.dart';
import 'package:app/Screens/user_profile.dart';
import 'package:app/models/image_post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
                leading: Icon(Icons.search),
                title: Text("Search"),
              ),
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
    return Stack(
      children: [
        PageView(
          controller: _controller,
          children: [
            ImageSection(),
            TweetSection(),
            PollSection(),
            DocsSection(),
          ],
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: () {
              showAlertDailogBox(context);
            },
            child: Icon(Icons.menu, color: Colors.white),
          ),
        ),
      ],
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
