import 'package:app/models/image_post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class PostImage extends StatefulWidget {
  static const routeName = "post-Image";

  @override
  _PostImageState createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  List<String> filepaths = [];

  String _extension;

  String caption, tags;

  final FirebaseStorage storage = FirebaseStorage.instance;

  void createImageList(Map<String, String> pathMap) {
    pathMap.forEach((key, value) {
      filepaths.add(value);
    });
  }

  Future<void> uploadToFirebase(Map<String, String> pathMap) async {
    int i = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString("uid");
    int noOfPosts = prefs.getInt("noOfPosts");
    DocumentReference documentReference =
        Firestore.instance.collection("Posts").document("post_no_$noOfPosts");
    List<String> imageUrls = [];
    Map<String, String> imagesMap = Map<String, String>();

    pathMap.forEach((filename, filePath) async {
      //   _extension = filename.toString().split(".").last;

      StorageTaskSnapshot snapshot = await storage
          .ref()
          .child("$uid/images/post_no_$noOfPosts/$filename")
          .putFile(File(filePath))
          .onComplete;
      if (snapshot.error == null) {
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imagesMap["image$i"] = downloadUrl;
        print(imagesMap);
        await documentReference.updateData({
          "images": imagesMap,
        });
        print(
            "---------------------------image[$i] node created------------------------------------");
        // setState(() {
        //   isUploadig = false;
        // });
        i += 1;
      } else {
        print('Error from image repo ${snapshot.error.toString()}');
        throw ('This file is not an image');
      }
    });

    // print(imageUrls.length);
    // for (int i = 0; i < imageUrls.length; i++) {
    //   imagesMap["image[$i]"] = imageUrls[i];
    // }

    List<String> tagList = tags.split(" ");
    Map<String, String> tagMap = Map<String, String>();
    for (int i = 0; i < tagList.length; i++) {
      tagMap["tag[$i]"] = tagList[i];
    }
    await documentReference.setData(
      {
        // "images": imagesMap,
        "caption": caption,
        "tags": tagMap,
      },
    );
    await prefs.setInt("noOfPosts", noOfPosts + 1);
  }

  @override
  Widget build(BuildContext context) {
    final ImagePost args = ModalRoute.of(context).settings.arguments;
    if (filepaths.isEmpty) {
      createImageList(args.paths);
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (ctx, i) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          child: Image.file(
                            File(
                              filepaths[i],
                            ),
                          ),
                        );
                      },
                      itemCount: filepaths.length,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Add Caption"),
                  ),
                  Container(
                    child: TextField(
                      onChanged: (value) {
                        caption = value;
                      },
                    ),
                    padding: EdgeInsets.all(20),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Add Tags"),
                  ),
                  Container(
                    child: TextField(
                      onChanged: (value) {
                        tags = value;
                      },
                    ),
                    padding: EdgeInsets.all(20),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.blue,
                    child: FlatButton(
                      onPressed: () {
                        uploadToFirebase(args.paths).then(
                          (_) => Navigator.pop(context),
                        );
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
      ),
    );
  }
}
