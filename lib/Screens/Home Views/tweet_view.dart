import 'package:app/Screens/Profile/user_profile.dart';
import 'package:app/Screens/Profile/visit_profile.dart';
import 'package:app/helpers/common_widgets.dart';
import 'package:app/helpers/user_data.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TweetSection extends StatelessWidget {
  final Stream<QuerySnapshot> query;
  TweetSection({this.query});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: query,
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? Text('PLease Wait')
              : ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot products = snapshot.data
                        .documents[snapshot.data.documents.length - 1 - index];

                    List<dynamic> likes = products["likes"];

                    bool isAlreadyLiked = false;
                    if (likes.contains(
                        Provider.of<UserData>(context).currentUserId)) {
                      isAlreadyLiked = true;
                    }
                    return (TweetCard(
                      user_id: products["user_id"],
                      tweet: products["tweet"],
                      postNo: products["timestamp"],
                      likes_count: products["likes_count"],
                      isAlreadyLiked: isAlreadyLiked,
                      comments: products["Comments"],
                    ));
                    //}

                    // return Container(
                    //     child: ImageCard(imageUrl: products["url"]));
                  },
                );
        },
      ),
    );
  }
}

class TweetCard extends StatefulWidget {
  final String user_id, tweet, postNo;
  final int likes_count;
  final bool isAlreadyLiked;
  final Map<String, dynamic> comments;
  TweetCard(
      {this.user_id,
      this.tweet,
      this.postNo,
      this.isAlreadyLiked,
      this.likes_count,
      this.comments});

  @override
  _TweetCardState createState() => _TweetCardState();
}

class _TweetCardState extends State<TweetCard> {
  TextEditingController commentController = TextEditingController();
  UserMaintainer userMaintainer = UserMaintainer();
  CommonWidgets commonWidgets = CommonWidgets();
  bool showComments = false;
  List<String> commenter;
  List<String> comment;

  @override
  void initState() {
    widget.comments != null ? createCommentList() : {};
    getProfileDetails();
    super.initState();
  }

  createCommentList() {
    commenter = [];
    comment = [];
    widget.comments.forEach((key, value) {
      commenter.add(key);
      comment.add(value);
    });
  }

  String username = "loading";
  String avatar = "";
  Future<void> getProfileDetails() async {
    DocumentSnapshot profileInfo =
        await commonWidgets.getProfileInfo(widget.user_id);
    if (mounted) {
      setState(() {
        avatar = profileInfo["profile_pic"];
        username = profileInfo["name"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        children: [
          PostOwnerDetails(
            user_id: widget.user_id,
            avatar: avatar,
            username: username,
          ),
          Divider(),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(widget.tweet,
                style: TextStyle(
                  letterSpacing: 1,
                  height: 2,
                )),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                LikeButton(
                  postType: "Tweet-Posts",
                  isAlreadyLiked: widget.isAlreadyLiked,
                  likes_count: widget.likes_count,
                  postNo: widget.postNo,
                  userId: widget.user_id,
                ),
                IconButton(
                  iconSize: 25,
                  color: Colors.black,
                  icon: Icon(Icons.comment),
                  onPressed: () {
                    setState(() {
                      showComments = !showComments;
                    });
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                IconButton(
                  iconSize: 25,
                  color: Colors.black,
                  icon: Icon(Icons.share),
                  onPressed: () {
                    commonWidgets.sharePost(
                        "Tweet-Posts", widget.user_id, widget.postNo);
                  },
                ),
              ],
            ),
          ),
          showComments
              ? (widget.comments != null
                  ? CommentList(
                      comment: comment,
                      commenter: commenter,
                    )
                  : Container(
                      alignment: Alignment.center,
                      child: Text("No Commnets yet"),
                    ))
              : Container(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: commentController,
              decoration: InputDecoration(hintText: "Enter your comment"),
              onSubmitted: (value) async {
                commonWidgets
                    .addComment("Tweet-Posts", value, widget.comments, username,
                        widget.user_id, widget.postNo)
                    .then((_) {
                  setState(() {
                    showComments = false;
                  });
                  commentController.clear();
                  createCommentList();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
