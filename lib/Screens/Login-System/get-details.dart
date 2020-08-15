import 'package:app/Screens/home_screen.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

class GetDetails extends StatefulWidget {
  static const routeName = "get-details";

  @override
  _GetDetailsState createState() => _GetDetailsState();
}

class _GetDetailsState extends State<GetDetails> {
  String username;
  String newImagePath;
  String downloadUrl;
  final FirebaseStorage storage = FirebaseStorage.instance;
  CollectionReference collectionReference =
      Firestore.instance.collection("Users");
  UserMaintainer userMaintainer = UserMaintainer();

  chooseNewProfilePicture() async {
    String temp = await FilePicker.getFilePath(type: FileType.image);
    setState(() {
      newImagePath = temp;
    });
  }

  Future<void> createNewProfileNode(FirebaseUser user) async {
    Map<String, dynamic> userProfile = Map<String, String>();
    userProfile["name"] = username;
    userProfile["profile_pic"] = downloadUrl;
    userProfile["uid"] = user.uid;
    userProfile["email"] = user.email;
    userProfile["phoneNumber"] = user.phoneNumber;

    await collectionReference.document("${user.email}").setData(userProfile);
    await userMaintainer.saveUserDataToLocal(userProfile);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (Route<dynamic> route) => false);
  }

  Future<void> uploadNewUserImage(String uid) async {
    if (newImagePath != null) {
      StorageTaskSnapshot snapshot = await storage
          .ref()
          .child("$uid/profile_pic")
          .putFile(File(newImagePath))
          .onComplete;
      if (snapshot.error == null) {
        downloadUrl = await snapshot.ref.getDownloadURL();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseUser args = ModalRoute.of(context).settings.arguments;
    username = args.displayName;
    return Scaffold(
        backgroundColor: Color(0xffefeeff),
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Text(
                  "May I know your name?",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        width: MediaQuery.of(context).size.width * 0.55,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(500),
                          child: AspectRatio(
                            aspectRatio: 1 / 1,
                            child: newImagePath != null
                                ? Image.file(File(newImagePath))
                                : (args.photoUrl != null
                                    ? Image.network(
                                        args.photoUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          child: SvgPicture.asset(
                                            "assets/img/user(0).svg",
                                            color: Colors.white,
                                          ),
                                        ),
                                      )),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: FlatButton(
                          onPressed: () {
                            chooseNewProfilePicture();
                          },
                          child: Text(
                            "Change Photo",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          onChanged: (value) {
                            username = value;
                          },
                          style: TextStyle(
                              color: Colors.black, fontFamily: "Poppins"),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 25),
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            hintText:
                                username == "" ? "Enter your name" : username,
                            hintStyle: TextStyle(
                                color: Colors.black.withOpacity(0.5),
                                fontFamily: "Poppins"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: FlatButton(
                        onPressed: () {
                          uploadNewUserImage(args.uid)
                              .then((_) => createNewProfileNode(args));
                        },
                        child: Text(
                          "Finish",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
