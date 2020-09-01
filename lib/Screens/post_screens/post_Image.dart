import 'package:app/helpers/styles.dart';
import 'package:app/helpers/user_data.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:app/models/image_post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class PostImage extends StatefulWidget {
  static const routeName = "post-Image";

  @override
  _PostImageState createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  bool isUploading = false;
  List<String> filepaths = [];
  Map<String, String> imagesMap = Map<String, String>();

  // String _extension;

  String caption, tags;

  final FirebaseStorage storage = FirebaseStorage.instance;
  UserMaintainer userMaintainer = UserMaintainer();

  void createImageList(Map<String, String> pathMap) {
    pathMap.forEach((key, value) {
      filepaths.add(value);
    });
  }

  Future<void> uploadToFirebase(Map<String, String> pathMap) async {
    int i = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("user_id");
    String timestamp = DateTime.now().toIso8601String();

    DocumentReference documentReference =
        Firestore.instance.collection("Image-Posts").document(timestamp);
    List<String> tagList = tags.split(" ");
    for (int i = 0; i < tagList.length; i++) {
      tagList[i] = tagList[i].toLowerCase();
    }
    print(tagList);
    await documentReference.setData(
      {
        "caption": caption,
        "tags": tagList,
        "user_id": id,
        "timestamp": timestamp,
        "likes": [],
        "likes_count": 0,
        "Comments": {},
      },
    );

    for (int i = 0; i < filepaths.length; i++) {
      await uploadImageAndGetDownloadUrl(filepaths[i], id, i, timestamp);
    }

    await documentReference.updateData({
      "images": imagesMap,
    });
  }

  Future<void> uploadImageAndGetDownloadUrl(
      String filepath, String id, int i, String timestamp) async {
    Directory tempdir = await getTemporaryDirectory();
    String filename = filepath.split("/").last;
    String targetPath = "${tempdir.path}/$filename";
    await userMaintainer.testCompressAndGetFile(File(filepath), targetPath);
    StorageTaskSnapshot snapshot = await storage
        .ref()
        .child("$id/Images/$timestamp/$filename")
        .putFile(File(targetPath))
        .onComplete;
    if (snapshot.error == null) {
      String downloadUrl = await snapshot.ref.getDownloadURL();
      imagesMap["image$i"] = downloadUrl;
      print(imagesMap);
      userMaintainer.showToast("$filename uploaded");
    } else {
      print('Error from image repo ${snapshot.error.toString()}');
      throw ('This file is not an image');
    }
  }

  bool check() {
    if (tags != null) {
      if (tags.split(" ").length > 11) {
        userMaintainer.showDailogBox(context, Text("Too many Tags"),
            Text("You can't add more than 10 tags"));
        return false;
      }
      return true;
    }
    userMaintainer.showDailogBox(
        context,
        Text("You missed Tags"),
        Text(
            "Tags are very important. they helps in finding the most relevant posts in searches"));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final ImagePost args = ModalRoute.of(context).settings.arguments;
    if (filepaths.isEmpty) {
      createImageList(args.paths);
    }
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (ctx, i) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          child: Image.file(
                            File(
                              filepaths[i],
                            ),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                      itemCount: filepaths.length,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(bottom: 24, top: 10),
                      child: Text("Preview")),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Add Caption Here",
                        border:
                            UnderlineInputBorder(borderSide: BorderSide.none),
                      ),
                      onChanged: (value) {
                        caption = value;
                      },
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    decoration: kTagContainerDecoration,
                    child: TextField(
                      decoration:
                          setTextFieldDecoration("Add spaced tags here"),
                      onChanged: (value) {
                        tags = value;
                        print(tags);
                      },
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FlatButton(
                      onPressed: () {
                        if (check()) {
                          if (mounted) {
                            setState(() {
                              isUploading = true;
                            });
                          }
                          uploadToFirebase(args.paths)
                              .then((value) => Navigator.pop(context));
                        }
                      },
                      child: isUploading
                          ? Center(child: CircularProgressIndicator())
                          : Text(
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
      ),
    );
  }
}
