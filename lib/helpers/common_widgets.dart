import 'package:app/Screens/Profile/user_profile.dart';
import 'package:app/Screens/Search%20Views/search_screen.dart';
import 'package:app/Screens/home_screen.dart';
import 'package:app/Screens/post_screens/post_Image.dart';
import 'package:app/Screens/post_screens/post_document.dart';
import 'package:app/Screens/post_screens/post_polls.dart';
import 'package:app/Screens/post_screens/post_tweet.dart';
import 'package:app/models/image_post_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonWidgets {
  Map<String, String> _paths;

  Future<void> openPdfExplorer(BuildContext context) async {
    String docPath = await FilePicker.getFilePath(type: FileType.custom);
    String _extension = docPath.toString().split(".").last;
    print(docPath);
    if (_extension == "pdf") {
      Navigator.of(context)
          .pushNamed(PostDocument.routeName, arguments: docPath);
    }
  }

  Future<void> openFileExplorer(BuildContext context) async {
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
                onTap: () => openFileExplorer(context),
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
                onTap: () => openPdfExplorer(context),
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
}

class Manual extends StatelessWidget {
  final String screen;
  Manual({this.screen});
  Color homeColor = Colors.black,
      searchColor = Colors.black,
      profileColor = Colors.black;
  CommonWidgets commonWidgets = CommonWidgets();
  @override
  Widget build(BuildContext context) {
    switch (screen) {
      case "home":
        homeColor = Colors.teal;
        break;
      case "search":
        searchColor = Colors.teal;
        break;
      case "profile":
        profileColor = Colors.teal;
        break;
      default:
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70,
      color: Colors.white.withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, HomeScreen.routeName);
            },
            color: homeColor,
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.pushReplacementNamed(context, SearchScreen.routeName);
            },
            color: searchColor,
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () => commonWidgets.showAlertDailogBox(context),
            color: Colors.black,
          ),
          IconButton(
            icon: Icon(Icons.android),
            onPressed: () {
              Navigator.pushReplacementNamed(context, UserProfile.routeName);
            },
            color: profileColor,
          )
        ],
      ),
    );
  }
}
