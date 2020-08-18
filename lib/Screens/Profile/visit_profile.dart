import 'package:app/Screens/Profile/profile_posts.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class VisitProfile extends StatefulWidget {
  static const String routeName = "/visit-profile";

  @override
  _VisitProfileState createState() => _VisitProfileState();
}

class _VisitProfileState extends State<VisitProfile> {
  String args;
  String visitorname = "Loading";
  String visitorprofilePicUrl;
  DocumentSnapshot ds;
  UserMaintainer userMaintainer = UserMaintainer();
  int imagePostCount = 0,
      tweetPostCount = 0,
      pollPostCount = 0,
      docPostCount = 0;
  String subscribeText = "loading";

  Future<void> getvisitorDetails(String visitorId) async {
    ds = await Firestore.instance.collection("Users").document(visitorId).get();
    if (mounted) {
      setState(() {
        visitorname = ds["name"];
        visitorprofilePicUrl = ds["profile_pic"];
      });
    }
  }

  Future<void> countPosts(String userId) async {
    int tempimgCount = await userMaintainer.countPost(userId, "Image-Posts");
    int temptweetCount = await userMaintainer.countPost(userId, "Tweet-Posts");
    int tempPollCount = await userMaintainer.countPost(userId, "Poll-Posts");
    int tempDocCount = await userMaintainer.countPost(userId, "Doc-Posts");
    if (mounted) {
      setState(() {
        imagePostCount = tempimgCount;
        tweetPostCount = temptweetCount;
        pollPostCount = tempPollCount;
        docPostCount = tempDocCount;
      });
    }
  }

  Future<void> checkForSubscrition(String args) async {
    String userId = await userMaintainer.getUserId();
    DocumentSnapshot documentSnapshot =
        await Firestore.instance.collection("Users").document(userId).get();
    List<dynamic> subscribedList = documentSnapshot["subscribed"];
    if (subscribedList.contains(args)) {
      if (mounted) {
        setState(() {
          subscribeText = "Subscribed";
        });
      }
    } else {
      if (mounted) {
        setState(() {
          subscribeText = "Subscribe";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    getvisitorDetails(args);
    countPosts(args);
    checkForSubscrition(args);
    return Scaffold(
      backgroundColor: Colors.pink,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.pink.withOpacity(0.3),
        title: Text(visitorname),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert,
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.height * 0.2,
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: visitorprofilePicUrl != null
                    ? Image.network(visitorprofilePicUrl)
                    : SvgPicture.asset(
                        "assets/img/user(0).svg",
                        color: Colors.grey,
                      ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(100),
              ),
              child: FlatButton(
                onPressed: () {
                  if (subscribeText == "Subscribe") {
                    userMaintainer.subscribe(args).then((_) {
                      checkForSubscrition(args);
                      userMaintainer.addSubscriberLocally(args);
                    });
                  } else {
                    userMaintainer.unsubscribe(args).then((_) {
                      checkForSubscrition(args);
                      userMaintainer.removeSubscriberLocally(args);
                    });
                  }
                },
                child: Text(
                  subscribeText,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 20),
                padding: EdgeInsets.only(top: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/img/stack-overflow.svg",
                          color: Colors.black,
                          height: 30,
                          width: 30,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        SvgPicture.asset(
                          "assets/img/instagram.svg",
                          color: Colors.black,
                          height: 30,
                          width: 30,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        SvgPicture.asset(
                          "assets/img/github.svg",
                          color: Colors.black,
                          height: 30,
                          width: 30,
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: ListView(
                          children: [
                            ListTile(
                              title: Text("Images"),
                              trailing: Text(imagePostCount.toString()),
                              onTap: () => imagePostCount != 0
                                  ? Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ProfilePost(type: "Image-Posts"),
                                      ),
                                    )
                                  : {},
                            ),
                            ListTile(
                              title: Text("Tweets"),
                              trailing: Text(tweetPostCount.toString()),
                            ),
                            ListTile(
                              title: Text("Polls"),
                              trailing: Text(pollPostCount.toString()),
                            ),
                            ListTile(
                              title: Text("Docs"),
                              trailing: Text(docPostCount.toString()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
