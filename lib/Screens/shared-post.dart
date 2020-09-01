import 'package:app/Screens/Home%20Views/docs_view.dart';
import 'package:app/Screens/Home%20Views/image_view.dart';
import 'package:app/Screens/Home%20Views/poll_view.dart';
import 'package:app/Screens/Home%20Views/tweet_view.dart';
import 'package:app/helpers/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SharedPost extends StatefulWidget {
  static const routeName = "shared-post";
  final String postId, postType;
  SharedPost({this.postId, this.postType});

  @override
  _SharedPostState createState() => _SharedPostState();
}

class _SharedPostState extends State<SharedPost> {
  DocumentSnapshot postData;
  bool isLoading = true;

  @override
  void didChangeDependencies() async {
    DocumentSnapshot temp = await Firestore.instance
        .collection(widget.postType)
        .document(widget.postId)
        .get();
    setState(() {
      postData = temp;
    });
    setState(() {
      isLoading = false;
    });
    super.didChangeDependencies();
  }

  showDesiredPost() {
    List<dynamic> likes = postData["likes"];

    bool isAlreadyLiked = false;
    if (likes.contains(Provider.of<UserData>(context).currentUserId)) {
      isAlreadyLiked = true;
    }
    if (widget.postType == "Image-Posts") {
      Map<String, dynamic> imagesMap = new Map<String, dynamic>();
      imagesMap = postData["images"];
      List<String> mapurls = [];
      imagesMap != null
          ? imagesMap.forEach((key, value) {
              mapurls.add(value);
            })
          : {};
      return ImageCard(
        imageUrl: mapurls,
        caption: postData["caption"],
        user_id: postData["user_id"],
        postNo: postData["timestamp"],
        likes_count: postData["likes_count"],
        isAlreadyLiked: isAlreadyLiked,
        comments: postData["Comments"],
      );
    } else if (widget.postType == "Tweet-Posts") {
      return (TweetCard(
        user_id: postData["user_id"],
        tweet: postData["tweet"],
        postNo: postData["timestamp"],
        likes_count: postData["likes_count"],
        isAlreadyLiked: isAlreadyLiked,
        comments: postData["Comments"],
      ));
    } else if (widget.postType == "Poll-Posts") {
      List<dynamic> voters = postData["voters"];
      bool isAlreadyVoted = false;
      if (voters.contains(Provider.of<UserData>(context).currentUserId)) {
        isAlreadyVoted = true;
      }
      return (PollCard(
        question: postData["question"],
        userId: postData["user_id"],
        optionsMap: postData["options"],
        postNo: postData["timestamp"],
        isAlreadyVoted: isAlreadyVoted,
        image: postData["image"],
        likes_count: postData["likes_count"],
        isAlreadyLiked: isAlreadyLiked,
        comments: postData["Comments"],
      ));
    } else if (widget.postType == "Doc-Posts") {
      return (DocCard(
        user_id: postData["user_id"],
        filename: postData["document_name"],
        docPath: postData["doc_path"],
        postNo: postData["timestamp"],
        likes_count: postData["likes_count"],
        isAlreadyLiked: isAlreadyLiked,
        comments: postData["Comments"],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("POST"),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: isLoading == false
              ? showDesiredPost()
              : Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                  ),
                ),
        ),
      ),
    );
  }
}
