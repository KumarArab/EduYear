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

class PollSection extends StatelessWidget {
  final Stream<QuerySnapshot> query;
  PollSection({this.query});

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
                    List<dynamic> voters = products["voters"];
                    bool isAlreadyVoted = false;
                    if (voters.contains(
                        Provider.of<UserData>(context).currentUserId)) {
                      isAlreadyVoted = true;
                    }

                    // Map<String, dynamic> optionsMap =
                    //     new Map<String, dynamic>();
                    // imagesMap = products["images"];
                    // List<String> mapurls = [];
                    // imagesMap != null
                    //     ? imagesMap.forEach((key, value) {
                    //         mapurls.add(value);
                    //       })
                    //     : {};

                    // if (mapurls.length == 1) {
                    List<dynamic> likes = products["likes"];

                    bool isAlreadyLiked = false;
                    if (likes.contains(
                        Provider.of<UserData>(context).currentUserId)) {
                      isAlreadyLiked = true;
                    }
                    return (PollCard(
                      question: products["question"],
                      userId: products["user_id"],
                      optionsMap: products["options"],
                      postNo: products["timestamp"],
                      isAlreadyVoted: isAlreadyVoted,
                      image: products["image"],
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

class PollCard extends StatefulWidget {
  final String question, userId, postNo, image;
  final int likes_count;
  final bool isAlreadyLiked;
  final Map<String, dynamic> comments;
  bool isAlreadyVoted;

  Map<dynamic, dynamic> optionsMap;
  PollCard({
    this.question,
    this.userId,
    this.postNo,
    this.optionsMap,
    this.isAlreadyVoted,
    this.image,
    this.comments,
    this.isAlreadyLiked,
    this.likes_count,
  });
  @override
  _PollCardState createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  UserMaintainer userMaintainer = UserMaintainer();
  TextEditingController commentController = TextEditingController();
  CommonWidgets commonWidgets = CommonWidgets();
  String currentUserId;

  List<String> options;
  List<int> votes;
  int totalVotes;
  bool showComments = false;
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
  void initState() {
    createOptionsList();
    countOptions();
    widget.comments != null ? createCommentList() : {};
    getProfileDetails();
    super.initState();
  }

  void createOptionsList() {
    options = [];
    votes = [];
    widget.optionsMap.forEach((key, value) {
      print("$key: $value");
      options.add(key);
      votes.add(value);
    });
  }

  void countOptions() {
    totalVotes = 0;
    widget.optionsMap.forEach((key, value) {
      totalVotes += value;
    });
  }

  double calculateVote(int index) {
    if (totalVotes == 0) {
      return 0;
    }
    return votes[index] / totalVotes;
  }

  Future<void> registerVote(String option, int votecount) async {
    // Map<String, dynamic> newOptionMap = widget.optionsMap;
    widget.optionsMap[option] = votecount + 1;
    print(widget.postNo);
    DocumentReference documentReference =
        Firestore.instance.collection("Poll-Posts").document(widget.postNo);
    await documentReference.updateData({"options": widget.optionsMap});
    currentUserId = await userMaintainer.getUserId();
    await documentReference.updateData({
      "voters": FieldValue.arrayUnion([currentUserId])
    });
    userMaintainer.showToast("You vote has been recorded");
  }

  String username = "loading";
  String avatar = "";
  Future<void> getProfileDetails() async {
    DocumentSnapshot profileInfo =
        await commonWidgets.getProfileInfo(widget.userId);
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
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          PostOwnerDetails(
            user_id: widget.userId,
            avatar: avatar,
            username: username,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: widget.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: widget.image,
                      placeholder: (context, url) => CircularProgressIndicator(
                        strokeWidth: 1,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  )
                : SizedBox(
                    height: 0,
                  ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 10,
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              widget.question,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            height: votes.length * 32.0,
            child: ListView.builder(
              itemBuilder: (ctx, i) {
                return Container(
                  height: 20,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: calculateVote(i),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.teal,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    bottomRight: Radius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "${(calculateVote(i) * 100).round()}%",
                              style: TextStyle(),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "  ${options[i]}",
                        style: TextStyle(),
                      ),
                    ],
                  ),
                );
              },
              itemCount: votes.length,
            ),
          ),
          widget.isAlreadyVoted
              ? Container(
                  child: Center(
                    child: Text(
                      "Voted",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width - 30,
                  margin: EdgeInsets.only(top: 10),
                  height: 50,
                  child: ListView.builder(
                    itemCount: votes.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          color: Color(0xffdddddd),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FlatButton(
                          onPressed: () {
                            registerVote(options[index], votes[index])
                                .then((_) => createOptionsList());
                          },
                          child: Text(
                            options[index],
                          ),
                        ),
                      );
                    },
                    scrollDirection: Axis.horizontal,
                  ),
                ),
          Divider(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                LikeButton(
                  postType: "Poll-Posts",
                  isAlreadyLiked: widget.isAlreadyLiked,
                  likes_count: widget.likes_count,
                  postNo: widget.postNo,
                  userId: widget.userId,
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
                        "Poll-Posts", widget.userId, widget.postNo);
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
                    .addComment("Poll-Posts", value, widget.comments, username,
                        widget.userId, widget.postNo)
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
