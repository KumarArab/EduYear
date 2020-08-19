import 'dart:io';

import 'package:app/Provider/login_store.dart';
import 'package:app/Screens/Profile/visit_profile.dart';
import 'package:app/Screens/post_screens/post_Image.dart';
import 'package:app/helpers/handle_dynamicLinks.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';

class ImageSection extends StatefulWidget {
  final bool all;
  ImageSection({this.all});

  @override
  _ImageSectionState createState() => _ImageSectionState();
}

class _ImageSectionState extends State<ImageSection> {
  // bool isUploadig = false;
  // FileType _pickType;
  GlobalKey<ScaffoldState> _imagepickScaffold = GlobalKey();
  UserMaintainer userMaintainer = UserMaintainer();
  String currentUserId;

  // List<DocumentSnapshot> dsList;
  List<String> subscribedList;

  @override
  void didChangeDependencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserId = await userMaintainer.getUserId();
    if (mounted) {
      setState(() {
        subscribedList = prefs.getStringList("subscribed");
      });
    }
    print(subscribedList);

    // await fetchImagePosts();

    super.didChangeDependencies();
  }

  // Future<void> fetchImagePosts() async {
  //   List<DocumentSnapshot> documentList;
  //   documentList =
  //       (await Firestore.instance //search for the userid in User node
  //               .collection("Image-Posts")
  //               .where("user_id", isEqualTo: subscribedList)
  //               .getDocuments())
  //           .documents;
  //   if (mounted) {
  //     setState(() {
  //       dsList = documentList;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return (subscribedList == null)
        ? Center(child: Text("Loading..."))
        : StreamBuilder(
            stream: widget.all
                ? Firestore.instance.collection("Image-Posts").snapshots()
                : Firestore.instance
                    .collection("Image-Posts")
                    .where("user_id", whereIn: subscribedList)
                    .snapshots(),
            builder: (context, snapshot) {
              return (!snapshot.hasData || subscribedList == null)
                  ? Text('PLease Wait')
                  : ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        print(snapshot.data.documents.length);
                        DocumentSnapshot products = snapshot.data.documents[
                            snapshot.data.documents.length - 1 - index];
                        Map<String, dynamic> imagesMap =
                            new Map<String, dynamic>();
                        imagesMap = products["images"];
                        List<String> mapurls = [];
                        imagesMap != null
                            ? imagesMap.forEach((key, value) {
                                mapurls.add(value);
                              })
                            : {};
                        List<dynamic> likes = products["likes"];

                        bool isAlreadyLiked = false;
                        if (likes.contains(currentUserId)) {
                          isAlreadyLiked = true;
                        }

                        // if (subscribedList.contains(products["user_id"])) {
                        //   print("subscribed: ${products["user_id"]}");
                        return (ImageCard(
                          imageUrl: mapurls,
                          caption: products["caption"],
                          user_id: products["user_id"],
                          username: products["name"],
                          avatar: products["avatar"],
                          postNo: products["postNo"],
                          likes_count: products["likes_count"],
                          isAlreadyLiked: isAlreadyLiked,
                          comments: products["Comments"],
                        ));
                        // } else {
                        //   print("not subscribed: ${products["user_id"]}");
                        // }

                        // return Container(
                        //     child: ImageCard(imageUrl: products["url"]));
                      },
                    );
            },
          );
  }
}

class ImageCard extends StatefulWidget {
  final List<String> imageUrl;
  final String caption;
  final String user_id;
  final String username;
  final String avatar;
  final String postNo;
  final int likes_count;
  final bool isAlreadyLiked;
  Map<String, dynamic> comments = Map<String, String>();
  ImageCard({
    this.imageUrl,
    this.caption,
    this.user_id,
    this.username,
    this.avatar,
    this.postNo,
    this.likes_count,
    this.isAlreadyLiked,
    this.comments,
  });

  @override
  _ImageCardState createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  DynamicLinksService dynamicLinksService = DynamicLinksService();
  bool isAlreadyLiked;
  bool showComments = false;
  TextEditingController commentController = TextEditingController();
  UserMaintainer userMaintainer = UserMaintainer();

  Future<void> likethePost() async {
    String currentUserId = await userMaintainer.getUserId();
    if (widget.isAlreadyLiked) {
      await Firestore.instance
          .collection("Image-Posts")
          .document("${widget.user_id}-${widget.postNo}")
          .updateData({
        "likes_count": widget.likes_count - 1,
        "likes": FieldValue.arrayRemove([currentUserId])
      });
    } else {
      await Firestore.instance
          .collection("Image-Posts")
          .document("${widget.user_id}-${widget.postNo}")
          .updateData({
        "likes_count": widget.likes_count + 1,
        "likes": FieldValue.arrayUnion([currentUserId])
      });
    }
  }

  Future<void> addComment(String comment) async {
    widget.comments[widget.username] = comment;
    await Firestore.instance
        .collection("Image-Posts")
        .document("${widget.user_id}-${widget.postNo}")
        .updateData({"Comments": widget.comments});
  }

  @override
  void initState() {
    if (widget.comments != null) {
      createCommentList();
    }
    super.initState();
  }

  List<String> commenter;
  List<String> comment;
  createCommentList() {
    commenter = [];
    comment = [];
    widget.comments.forEach((key, value) {
      commenter.add(key);
      comment.add(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.length == 1) {
      return Container(
        margin: EdgeInsets.only(bottom: 20),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, VisitProfile.routeName,
                    arguments: widget.user_id),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(widget.avatar)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.username,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Image.network(
                widget.imageUrl[0],
                fit: BoxFit.cover,
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
            Container(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, VisitProfile.routeName,
                    arguments: widget.user_id),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(widget.avatar)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.username,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: Swiper(
                itemBuilder: (BuildContext context, int idx) {
                  return Image.network(
                    widget.imageUrl[idx],
                    fit: BoxFit.cover,
                  );
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
                  FlatButton.icon(
                    label: Text(widget.likes_count.toString()),
                    icon: Icon(
                      widget.isAlreadyLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.isAlreadyLiked ? Colors.red : Colors.black,
                    ),
                    onPressed: () {
                      likethePost();
                    },
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
                    onPressed: () async {
                      Map<String, String> postInfo = Map<String, String>();
                      postInfo["post_type"] = "Image-Posts";
                      postInfo["post_id"] =
                          "${widget.user_id}-${widget.postNo}";
                      String link =
                          await dynamicLinksService.createDynamicLink(postInfo);
                      Share.share(link,
                          subject:
                              "Hey Look, I found this interesting post on My App");
                    },
                  ),
                ],
              ),
            ),
            showComments
                ? (widget.comments != null
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (ctx, i) {
                          return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: "${commenter[i]}:  ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "${comment[i]}",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                  ),
                                ]),
                              ));
                        },
                        itemCount: commenter.length,
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
                onSubmitted: (value) {
                  addComment(value).then((_) {
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
