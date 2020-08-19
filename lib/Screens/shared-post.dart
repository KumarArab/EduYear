import 'package:app/Screens/Home%20Views/image_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SharedPost extends StatefulWidget {
  static const routeName = "shared-post";
  final String postId, postType;
  SharedPost({this.postId, this.postType});

  @override
  _SharedPostState createState() => _SharedPostState();
}

class _SharedPostState extends State<SharedPost> {
  DocumentSnapshot postData;

  @override
  void didChangeDependencies() async {
    DocumentSnapshot temp = await Firestore.instance
        .collection(widget.postType)
        .document(widget.postId)
        .get();
    setState(() {
      postData = temp;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> imagesMap = new Map<String, dynamic>();
    imagesMap = postData["images"];
    List<String> mapurls = [];
    imagesMap != null
        ? imagesMap.forEach((key, value) {
            mapurls.add(value);
          })
        : {};
    return Scaffold(
      appBar: AppBar(
        title: Text("POST"),
        backgroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        child: ImageCard(
          avatar: postData["avatar"],
          caption: postData["caption"],
          imageUrl: mapurls,
          postNo: postData["postNo"],
          user_id: postData["user_id"],
          username: postData["name"],
        ),
      ),
    );
  }
}
