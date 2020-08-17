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
  String docName;

  String defaultFilename;

  String tags;

  bool isUploading = false;

  String downloadUrl;

  String getDefaultName(String path) {
    defaultFilename = path.split("/").last;
    return defaultFilename;
  }

  Future<void> uploadToStorage(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final FirebaseStorage storage = FirebaseStorage.instance;

    String finalDocName = docName != null ? docName : defaultFilename;

    String id = prefs.getString("email") != null
        ? prefs.getString("email")
        : prefs.getString("phoneNumber");
    int noOfPosts = prefs.getInt("no_of_posts");
    String name = prefs.getString("name");
    DocumentReference documentReference =
        Firestore.instance.collection("Doc-Posts").document("$id-$noOfPosts");

    StorageTaskSnapshot snapshot = await storage
        .ref()
        .child("$id/documents/post_no_$noOfPosts/$finalDocName")
        .putFile(File(path))
        .onComplete;
    if (snapshot.error == null) {
      downloadUrl = await snapshot.ref.getDownloadURL();
      print(downloadUrl);
      await documentReference.setData({
        "doc_path": downloadUrl,
      }).then((_) => Navigator.of(context).pop());
    } else {
      print('Error from image repo ${snapshot.error.toString()}');
      throw ('This file is not an image');
    }

    List<String> tagList = tags.split(" ");
    Map<String, String> tagMap = Map<String, String>();
    for (int i = 0; i < tagList.length; i++) {
      tagMap["tag[$i]"] = tagList[i];
    }
    await documentReference.updateData(
      {
        "document_name": finalDocName,
        "tags": tagList,
        "user_id": id,
        "name": name,
      },
    );
    noOfPosts += 1;
    await Firestore.instance
        .collection("Users")
        .document(id)
        .updateData({"no_of_posts": noOfPosts.toString()});
    await prefs.setInt("no_of_posts", noOfPosts);
  }

  @override
  Widget build(BuildContext context) {
    final String args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                    margin: EdgeInsets.all(20),
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
                    padding: EdgeInsets.all(20),
                    child: TextField(
                        decoration: InputDecoration(
                          hintText: "Add Tags",
                        ),
                        onChanged: (value) {
                          tags = value;
                        }),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                      ),
                    ),
                    child: isUploading
                        ? Center(child: CircularProgressIndicator())
                        : FlatButton(
                            onPressed: () {
                              setState(() {
                                isUploading = true;
                              });
                              // uploadToFirebase(args.paths).then(
                              //   (_) => Navigator.pop(context),
                              // );
                              uploadToStorage(args);
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
            ],
          ),
        ),
      ),
    );
  }
}
