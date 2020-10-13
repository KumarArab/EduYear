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
  String username, defaultName;
  String newImagePath;
  String downloadUrl;
  String userId;
  bool isLoading = false;
  FirebaseUser args;

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
    userId = user.email != null ? user.email : user.phoneNumber;
    List<dynamic> tags = username.split(" ");
    for (int i = 0; i < tags.length; i++) {
      tags[i] = tags[i].toLowerCase();
    }
    Map<String, dynamic> userProfile = Map<String, String>();
    userProfile["name"] = username;
    userProfile["profile_pic"] = downloadUrl;
    userProfile["user_id"] = userId;
    userProfile["bio"] = "Add your bio here";
    await collectionReference.document(userId).setData(userProfile);
    await collectionReference.document(userId).updateData({
      "subscribed": [userId],
      "followers": 1,
      "followings": 1,
      "tags": tags,
      "verified": false
    });
    DocumentSnapshot documentSnapshot =
        await Firestore.instance.collection("Users").document(userId).get();
    Map<String, dynamic> fetchedUserData = documentSnapshot.data;
    await userMaintainer.saveUserDataToLocal(fetchedUserData);
    userMaintainer.showToast("$username profile created successfully");
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (Route<dynamic> route) => false);
  }

  Future<void> uploadNewUserImage(FirebaseUser user) async {
    final String id = user.email != null ? user.email : user.phoneNumber;
    if (newImagePath != null) {
      StorageTaskSnapshot snapshot = await storage
          .ref()
          .child("$id/profile_pic")
          .putFile(File(newImagePath))
          .onComplete;
      if (snapshot.error == null) {
        downloadUrl = await snapshot.ref.getDownloadURL();
      }
    } else if (user.photoUrl != null) {
      downloadUrl = user.photoUrl;
    }
  }

  bool check() {
    if (newImagePath != null || args.photoUrl != null) {
      if (username == null || username == "") {
        if (defaultName != null && defaultName != "") {
          setState(() {
            username = defaultName;
          });
          return true;
        } else {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    defaultName = args.displayName;
    return WillPopScope(
      onWillPop: () async {
        if (isLoading) {
          userMaintainer.showToast("Don't close, account creation in progress");
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  const Text(
                    "May I know your name?",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                          width: MediaQuery.of(context).size.width * 0.55,
                          height: MediaQuery.of(context).size.width * 0.55,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(500),
                            child: newImagePath != null
                                ? Image.file(
                                    File(newImagePath),
                                    fit: BoxFit.cover,
                                  )
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
                            style: const TextStyle(
                                color: Colors.black, fontFamily: "Poppins"),
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 25),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              hintText: defaultName != null
                                  ? defaultName
                                  : "Enter your name here",
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
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: FlatButton(
                          onPressed: () {
                            if (check()) {
                              setState(() {
                                isLoading = true;
                              });
                              uploadNewUserImage(args)
                                  .then((_) => createNewProfileNode(args));
                            } else {
                              userMaintainer.showDailogBox(
                                context,
                                Text("Snap!"),
                                Text("Both fields are necessary"),
                              );
                            }
                          },
                          child: isLoading
                              ? Center(child: CircularProgressIndicator())
                              : Text(
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
          ),
        ),
      ),
    );
  }
}
