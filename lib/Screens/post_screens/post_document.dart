import 'package:app/helpers/styles.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class PostDocument extends StatefulWidget {
  static const routeName = "/post-document";

  @override
  _PostDocumentState createState() => _PostDocumentState();
}

class _PostDocumentState extends State<PostDocument> {
  UserMaintainer userMaintainer = UserMaintainer();
  String docName;

  String defaultFilename;

  String tags;

  bool isUploading = false;

  String downloadUrl;

  String args;

  String getDefaultName(String path) {
    defaultFilename = path.split("/").last;
    return defaultFilename;
  }

  String getExtension(String path) {
    String extension = path.split(".").last;
    return extension;
  }

  Future<void> uploadToStorage(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final FirebaseStorage storage = FirebaseStorage.instance;

    String finalDocName = docName != null ? docName : defaultFilename;

    String id = prefs.getString("user_id");
    String timestamp = DateTime.now().toIso8601String();
    DocumentReference documentReference =
        Firestore.instance.collection("Doc-Posts").document(timestamp);

    StorageTaskSnapshot snapshot = await storage
        .ref()
        .child("$id/documents/$timestamp/$finalDocName")
        .putFile(File(path))
        .onComplete;
    if (snapshot.error == null) {
      downloadUrl = await snapshot.ref.getDownloadURL();
      print(downloadUrl);
      await documentReference.setData({
        "doc_path": downloadUrl,
      });
    } else {
      print('Error from image repo ${snapshot.error.toString()}');
      throw ('This file is not an document');
    }

    List<String> tagList = tags.split(" ");
    for (int i = 0; i < tagList.length; i++) {
      tagList[i] = tagList[i].toLowerCase();
    }
    await documentReference.updateData(
      {
        "document_name": finalDocName,
        "tags": tagList,
        "user_id": id,
        "likes_count": 0,
        "likes": [],
        "timestamp": timestamp,
        "comments": {}
      },
    );

    Navigator.of(context).pop();
  }

  bool check(String path) {
    if (getExtension(args) == "pdf") {
      if (tags != null) {
        if (tags.split(" ").length > 11) {
          userMaintainer.showDailogBox(context, Text("Too many Tags"),
              Text("You can't add more than 10 tags"));
          return false;
        }
      } else {
        userMaintainer.showDailogBox(context, Text("Tags not added"),
            Text("Looks you forgot to add tags"));
        return false;
      }
      if (File(path).lengthSync() > 20971520) {
        userMaintainer.showDailogBox(context, Text("File too big!"),
            Text("You can upload a file of max size 20 mb"));
      }
      return true;
    }
    userMaintainer.showDailogBox(context, Text("Extension error!"),
        Text("make sure you select a pdf file"));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;

    return WillPopScope(
      onWillPop: () async {
        if (isUploading) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(30),
                  child: SvgPicture.asset(
                    "assets/img/pdf.svg",
                    height: MediaQuery.of(context).size.width * 0.3,
                    width: MediaQuery.of(context).size.width * 0.3,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    onChanged: (value) {
                      docName = value;
                    },
                    style:
                        TextStyle(color: Colors.black, fontFamily: "Poppins"),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 25),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: getDefaultName(args),
                      hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontFamily: "Poppins"),
                    ),
                  ),
                ),
                Container(
                  decoration: kTagContainerDecoration,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(10),
                  child: TextField(
                      decoration:
                          setTextFieldDecoration("Add spaced tags here"),
                      onChanged: (value) {
                        tags = value;
                      }),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: isUploading
                      ? Center(child: CircularProgressIndicator())
                      : FlatButton(
                          onPressed: () {
                            if (check(args)) {
                              setState(() {
                                isUploading = true;
                              });
                              uploadToStorage(args);
                              userMaintainer.showToast("Pdf Uploaded");
                            }
                          },
                          child: Text(
                            "POST",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
