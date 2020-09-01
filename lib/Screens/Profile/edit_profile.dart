import 'package:app/helpers/user_data.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  static const routeName = "/edit-profile";

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String newusername, newprofilepic, newbio, downloadUrl;
  bool isLoading = false;
  final FirebaseStorage storage = FirebaseStorage.instance;
  CollectionReference collectionReference =
      Firestore.instance.collection("Users");
  UserMaintainer userMaintainer = UserMaintainer();

  chooseNewProfilePicture() async {
    String temp = await FilePicker.getFilePath(type: FileType.image);
    setState(() {
      newprofilepic = temp;
    });
  }

  Future<void> updateProfilePic(String userId, String oldImage) async {
    if (newprofilepic != null) {
      Directory tempdir = await getTemporaryDirectory();
      String imageName = newprofilepic.split("/").last;
      String targetPath = "${tempdir.path}/$imageName";
      await userMaintainer.testCompressAndGetFile(
          File(newprofilepic), targetPath);
      StorageTaskSnapshot snapshot = await storage
          .ref()
          .child("$userId/profile_pic")
          .putFile(File(targetPath))
          .onComplete;
      if (snapshot.error == null) {
        downloadUrl = await snapshot.ref.getDownloadURL();
      }
    } else {
      downloadUrl = oldImage;
    }
  }

  Future<void> updateUserNode(
      String oldName, String userId, String oldBio) async {
    if (newusername == null || newusername == "") {
      newusername = oldName;
    }
    if (newbio == null || newbio == "") {
      newbio = oldBio;
    }
    List<String> tags = newusername.split(" ");
    for (int i = 0; i < tags.length; i++) {
      tags[i] = tags[i].toLowerCase();
    }
    await collectionReference.document(userId).updateData({
      "name": newusername,
      "profile_pic": downloadUrl,
      "bio": newbio,
      "tags": tags
    });

    DocumentSnapshot documentSnapshot =
        await Firestore.instance.collection("Users").document(userId).get();
    Map<String, dynamic> fetchedUserData = documentSnapshot.data;
    await userMaintainer.saveUserDataToLocal(fetchedUserData);
    userMaintainer.showToast("$newusername profile created successfully");
    Provider.of<UserData>(context, listen: false).setuserData();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        if (isLoading) {
          userMaintainer.showToast("Updating data, please wait!");
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
                  Text(
                    "Edit Profile",
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
                          height: MediaQuery.of(context).size.width * 0.55,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                          width: MediaQuery.of(context).size.width * 0.55,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(500),
                            child: newprofilepic != null
                                ? Image.file(
                                    File(newprofilepic),
                                    fit: BoxFit.cover,
                                  )
                                : (userData.imageUrl != null
                                    ? Image.network(
                                        userData.imageUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : SvgPicture.asset(
                                        "assets/img/user(0).svg",
                                        color: Colors.white,
                                        fit: BoxFit.cover,
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
                          padding: EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "id:",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                userData.currentUserId,
                                style: TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              userData.isVerified
                                  ? SvgPicture.asset(
                                      "assets/img/verified.svg",
                                      width: 20,
                                      height: 20,
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: TextField(
                            onChanged: (value) {
                              newusername = value;
                            },
                            style: TextStyle(
                                color: Colors.black, fontFamily: "Poppins"),
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 25),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              hintText: userData.username != null
                                  ? userData.username
                                  : "Enter your name here",
                              hintStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.5),
                                  fontFamily: "Poppins"),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: TextField(
                            onChanged: (value) {
                              newbio = value;
                            },
                            style: TextStyle(
                                color: Colors.black, fontFamily: "Poppins"),
                            cursorColor: Colors.black,
                            maxLength: 80,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 25),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              hintText: userData.bio != null
                                  ? userData.bio
                                  : "Enter your bio here",
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
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: FlatButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                            });
                            updateProfilePic(
                                    userData.currentUserId, userData.imageUrl)
                                .then((_) => updateUserNode(userData.username,
                                    userData.currentUserId, userData.bio));
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
