import 'package:app/helpers/styles.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class PostPolls extends StatefulWidget {
  static const routeName = "post-poll";
  @override
  _PostPollsState createState() => _PostPollsState();
}

class _PostPollsState extends State<PostPolls> {
  UserMaintainer userMaintainer = UserMaintainer();
  String tags;
  String question;
  String option1;
  String option2;
  String option3;
  String option4;
  bool isImageSelected = false;
  // String userChoice;
  String imagepath;
  String downloadUrl;
  bool isLoading = false;

  Future<void> postPoll(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final FirebaseStorage storage = FirebaseStorage.instance;

    String id = prefs.getString("user_id");
    String timestamp = DateTime.now().toIso8601String();

    DocumentReference documentReference =
        Firestore.instance.collection("Poll-Posts").document(timestamp);

    if (imagepath != null) {
      Directory tempdir = await getTemporaryDirectory();
      String imageName = imagepath.split("/").last;
      String targetPath = "${tempdir.path}/$imageName";
      await userMaintainer.testCompressAndGetFile(File(imagepath), targetPath);
      StorageTaskSnapshot snapshot = await storage
          .ref()
          .child("$id/Poll/$timestamp/$imageName")
          .putFile(File(targetPath))
          .onComplete;
      if (snapshot.error == null) {
        downloadUrl = await snapshot.ref.getDownloadURL();
      } else {
        print('Error from image repo ${snapshot.error.toString()}');
        throw ('This file is not an image');
      }
    }

    List<String> tagList = tags.split(" ");
    for (int i = 0; i < tagList.length; i++) {
      tagList[i] = tagList[i].toLowerCase();
    }
    Map<String, int> optionsMap = Map<String, int>();
    optionsMap[option1] = 0;
    optionsMap[option2] = 0;
    if (option3 != null && option3 != "") {
      optionsMap[option3] = 0;
    }
    if (option4 != null && option4 != "") {
      optionsMap[option4] = 0;
    }

    await documentReference.setData(
      {
        // "images": imagesMap,
        "question": question,
        "tags": tagList,
        "user_id": id,
        "options": optionsMap,
        "timestamp": timestamp,

        "voters": [],
        "likes_count": 0,
        "likes": [],
        "comments": {},
        "image": downloadUrl
      },
    );

    Navigator.of(context).pop();
  }

  Future<void> selectImage() async {
    imagepath = await FilePicker.getFilePath(type: FileType.image);
    setState(() {
      isImageSelected = true;
    });
  }

  bool check() {
    if (tags.split(" ").length > 11) {
      userMaintainer.showDailogBox(context, Text("Too many tags"),
          Text("You can only add upto 10 tags"));
      return false;
    }
    if (question != null &&
        option1 != null &&
        option1 != "" &&
        option2 != null &&
        option2 != "" &&
        tags != null) {
      if (option4 != null || option4 == "") {
        if (option3 == null || option3 == "") {
          userMaintainer.showDailogBox(context, Text("Input Error"),
              Text("looks you skipped any option"));
          return false;
        } else {
          return true;
        }
      }
      return true;
    }
    print(
        "$question  |  $option1  |  $option2  |  $tags  | $option4  $option3");
    userMaintainer.showDailogBox(
        context, Text("Snap!"), Text("Looks you missed any field"));
    return false;
  }

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        maxLines: 5,
                        onChanged: (value) {
                          question = value;
                        },
                        style: TextStyle(
                            color: Colors.black, fontFamily: "Poppins"),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(
                            left: 25,
                            top: 10,
                          ),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: "Enter your Poll Question",
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            decoration: kTagContainerDecoration,
                            child: TextField(
                              onChanged: (value) {
                                option1 = value;
                              },
                              decoration: setTextFieldDecoration("Option 1"),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            decoration: kTagContainerDecoration,
                            child: TextField(
                              onChanged: (value) {
                                option2 = value;
                              },
                              decoration: setTextFieldDecoration("Option 2"),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            decoration: kTagContainerDecoration,
                            child: TextField(
                              onChanged: (value) {
                                option3 = value;
                              },
                              decoration: setTextFieldDecoration("Option 3"),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            decoration: kTagContainerDecoration,
                            child: TextField(
                              onChanged: (value) {
                                option4 = value;
                              },
                              decoration: setTextFieldDecoration("Option 4"),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          //
                        ],
                      ),
                    ),
                    RaisedButton(
                      onPressed: () {
                        selectImage();
                      },
                      child: Text("Add Image"),
                    ),
                    imagepath != null
                        ? Container(
                            color: Colors.grey.withOpacity(0.5),
                            height: MediaQuery.of(context).size.width,
                            width: MediaQuery.of(context).size.width,
                            child: isImageSelected
                                ? Image.file(
                                    File(imagepath),
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Text("Image Preview"),
                                  ),
                          )
                        : Container(),
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
                  ],
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FlatButton(
                    onPressed: () {
                      if (check()) {
                        setState(() {
                          isLoading = true;
                        });
                        postPoll(context);
                        userMaintainer.showToast("Poll Uploaded");
                      }
                    },
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Text(
                            "POST",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
