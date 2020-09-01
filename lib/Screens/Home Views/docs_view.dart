import 'package:app/Screens/Profile/user_profile.dart';
import 'package:app/Screens/Profile/visit_profile.dart';
import 'package:app/helpers/common_widgets.dart';
import 'package:app/helpers/user_data.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DocsSection extends StatelessWidget {
  final Stream<QuerySnapshot> query;
  DocsSection({this.query});

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

                    List<dynamic> likes = products["likes"];

                    bool isAlreadyLiked = false;
                    if (likes.contains(
                        Provider.of<UserData>(context).currentUserId)) {
                      isAlreadyLiked = true;
                    }
                    return (DocCard(
                      user_id: products["user_id"],
                      filename: products["document_name"],
                      docPath: products["doc_path"],
                      postNo: products["timestamp"],
                      likes_count: products["likes_count"],
                      isAlreadyLiked: isAlreadyLiked,
                      comments: products["Comments"],
                    ));
                  },
                );
        },
      ),
    );
  }
}

class DocCard extends StatefulWidget {
  final String user_id, filename, docPath, postNo;
  final int likes_count;
  final bool isAlreadyLiked;
  final Map<String, dynamic> comments;
  DocCard(
      {this.user_id,
      this.filename,
      this.docPath,
      this.postNo,
      this.comments,
      this.isAlreadyLiked,
      this.likes_count});

  @override
  _DocCardState createState() => _DocCardState();
}

class _DocCardState extends State<DocCard> {
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
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset("assets/img/pdf.svg"),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      widget.filename,
                      style: TextStyle(),
                      maxLines: 3,
                      softWrap: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.file_download, color: Colors.black),
                  onPressed: () async {
                    if (await canLaunch(widget.docPath))
                      launch(widget.docPath);
                    else {}
                  },
                )
              ],
            ),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                LikeButton(
                  postType: "Doc-Posts",
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
                        "Doc-Posts", widget.user_id, widget.postNo);
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
                    .addComment("Doc-Posts", value, widget.comments, username,
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
