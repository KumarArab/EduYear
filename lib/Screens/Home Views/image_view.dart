import 'dart:io';

import 'package:app/Provider/login_store.dart';
import 'package:app/Screens/Profile/visit_profile.dart';
import 'package:app/Screens/post_screens/post_Image.dart';
import 'package:app/helpers/common_widgets.dart';
import 'package:app/helpers/handle_dynamicLinks.dart';
import 'package:app/helpers/user_data.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';

class ImageSection extends StatelessWidget {
  final Stream<QuerySnapshot> query;
  ImageSection({this.query});

  List<String> createImageList(Map<String, dynamic> imageMap) {
    List<String> mapUrls = [];
    imageMap.forEach((key, value) {
      mapUrls.add(value);
    });
    return mapUrls;
  }

  bool checkLikeStatus(List<dynamic> likes, context) {
    if (likes.contains(Provider.of<UserData>(context).currentUserId)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: query,
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? Center(child: Text('PLease Wait'))
              : ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot products = snapshot.data
                        .documents[snapshot.data.documents.length - 1 - index];
                    // Map<String, dynamic> imagesMap = new Map<String, dynamic>();
                    // imagesMap = products["images"];
                    // imagesMap != null
                    //     ? imagesMap.forEach((key, value) {
                    //         mapurls.add(value);
                    //       })
                    //     : {};

                    // List<dynamic> likes = products["likes"];

                    // bool isAlreadyLiked = false;
                    // if (likes.contains(
                    //     Provider.of<UserData>(context).currentUserId)) {
                    //   isAlreadyLiked = true;
                    // }

                    return (ImageCard(
                      imageUrl: createImageList(products["images"]),
                      caption: products["caption"],
                      user_id: products["user_id"],
                      postNo: products["timestamp"],
                      likes_count: products["likes_count"],
                      isAlreadyLiked:
                          checkLikeStatus(products["likes"], context),
                      comments: products["Comments"],
                    ));
                  },
                );
        },
      ),
    );
  }
}

class ImageCard extends StatefulWidget {
  final List<String> imageUrl;
  final String caption;
  final String user_id;
  final String postNo;
  final int likes_count;
  final bool isAlreadyLiked;
  Map<String, dynamic> comments = Map<String, String>();
  ImageCard({
    this.imageUrl,
    this.caption,
    this.user_id,
    this.postNo,
    this.likes_count,
    this.isAlreadyLiked,
    this.comments,
  });

  @override
  _ImageCardState createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
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
    if (widget.imageUrl.length == 1) {
      return Container(
        margin: EdgeInsets.only(bottom: 20),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            PostOwnerDetails(
              user_id: widget.user_id,
              avatar: avatar,
              username: username,
            ),
            Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl[0],
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Text(
                widget.caption,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            Divider(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  LikeButton(
                    postType: "Image-Posts",
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
                          "Image-Posts", widget.user_id, widget.postNo);
                    },
                  ),
                ],
              ),
            ),
            showComments
                ? ((widget.comments != null && comment.length != 0)
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
                      .addComment("Image-Posts", value, widget.comments,
                          username, widget.user_id, widget.postNo)
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
    } else {
      return Container(
        margin: EdgeInsets.only(bottom: 20),
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(),
        child: Column(
          children: [
            PostOwnerDetails(
              user_id: widget.user_id,
              avatar: avatar,
              username: username,
            ),
            Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: Swiper(
                itemBuilder: (BuildContext context, int idx) {
                  return CachedNetworkImage(
                    imageUrl: widget.imageUrl[idx],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  );
                  // Image.network(
                  //   widget.imageUrl[idx],
                  //   loadingBuilder: (context, child, loadingProgress) => Center(
                  //     child: CircularProgressIndicator(
                  //       strokeWidth: 1,
                  //     ),

                  //   ),

                  //   fit: BoxFit.cover,
                  // );
                },
                itemCount: widget.imageUrl.length,
                scrollDirection: Axis.horizontal,
                pagination: SwiperPagination(),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Text(
                widget.caption,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            Divider(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  LikeButton(
                    postType: "Image-Posts",
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
                          "Image-Posts", widget.user_id, widget.postNo);
                    },
                  ),
                ],
              ),
            ),
            showComments
                ? ((widget.comments != null && comment.length != 0)
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
                      .addComment("Image-Posts", value, widget.comments,
                          username, widget.user_id, widget.postNo)
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
}
