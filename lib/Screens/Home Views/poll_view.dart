import 'package:app/Screens/Profile/visit_profile.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PollSection extends StatefulWidget {
  final bool all;
  PollSection({this.all});
  @override
  _PollSectionState createState() => _PollSectionState();
}

class _PollSectionState extends State<PollSection> {
  List<String> subscribedList;
  String currentUserId;
  UserMaintainer userMaintainer = UserMaintainer();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: widget.all
            ? Firestore.instance.collection("Poll-Posts").snapshots()
            : Firestore.instance
                .collection("Poll-Posts")
                .where("user_id", whereIn: subscribedList)
                .snapshots(),
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
                    if (voters.contains(currentUserId)) {
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
                    return (PollCard(
                      question: products["question"],
                      userId: products["user_id"],
                      username: products["name"],
                      avatar: products["avatar"],
                      optionsMap: products["options"],
                      postNo: products["postNo"],
                      isAlreadyVoted: isAlreadyVoted,
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
  final String question, userId, postNo, username, avatar;
  bool isAlreadyVoted;

  Map<dynamic, dynamic> optionsMap;
  PollCard({
    this.question,
    this.userId,
    this.postNo,
    this.username,
    this.avatar,
    this.optionsMap,
    this.isAlreadyVoted,
  });
  @override
  _PollCardState createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  UserMaintainer userMaintainer = UserMaintainer();
  String currentUserId;

  List<String> options;
  List<int> votes;
  int totalVotes;

  @override
  void initState() {
    createOptionsList();
    countOptions();
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
    return votes[index] / totalVotes;
  }

  Future<void> registerVote(int index) async {
    Map<String, dynamic> newOptionMap = widget.optionsMap;
    newOptionMap[options[index]] = votes[index] + 1;
    DocumentReference documentReference = Firestore.instance
        .collection("Poll-Posts")
        .document("${widget.userId}-${widget.postNo}");
    await documentReference.updateData({"options": newOptionMap});
    currentUserId = await userMaintainer.getUserId();
    await documentReference.updateData({
      "voters": FieldValue.arrayUnion([currentUserId])
    });
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
          Container(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, VisitProfile.routeName,
                  arguments: widget.userId),
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
                            registerVote(index)
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
                )
        ],
      ),
    );
  }
}
