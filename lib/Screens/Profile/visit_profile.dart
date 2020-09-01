import 'package:app/Screens/Home%20Views/docs_view.dart';
import 'package:app/Screens/Home%20Views/image_view.dart';
import 'package:app/Screens/Home%20Views/poll_view.dart';
import 'package:app/Screens/Home%20Views/tweet_view.dart';
import 'package:app/Screens/Profile/subscribed_list.dart';
import 'package:app/helpers/user_data.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:app/helpers/visitors_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class VisitProfile extends StatefulWidget {
  static const String routeName = "/visit-profile";
  final String visitorId;
  VisitProfile({this.visitorId});

  @override
  _VisitProfileState createState() => _VisitProfileState();
}

class _VisitProfileState extends State<VisitProfile> {
  // String args;

  UserMaintainer userMaintainer = UserMaintainer();

  String subscribeText = "loading";
  bool isLoading = true;
  bool issubunsub = false;

  Future<void> checkForSubscrition(String args) async {
    // String userId = await userMaintainer.getUserId();
    String userId = Provider.of<UserData>(context, listen: false).currentUserId;
    DocumentSnapshot documentSnapshot =
        await Firestore.instance.collection("Users").document(userId).get();
    List<dynamic> subscribedList = documentSnapshot["subscribed"];
    if (subscribedList.contains(args)) {
      if (mounted) {
        setState(() {
          subscribeText = "Following";
        });
      }
    } else {
      if (mounted) {
        setState(() {
          subscribeText = "Follow";
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    checkForSubscrition(widget.visitorId);
    print(widget.visitorId);
    Provider.of<VisitorData>(context, listen: false)
        .setVisitorsData(widget.visitorId)
        .then((_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final visitorData = Provider.of<VisitorData>(context, listen: false);
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          visitorData.visitorimage,
                        ),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.width * 0.45,
                            width: MediaQuery.of(context).size.width * 0.45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  blurRadius: 3,
                                  color: Colors.black.withOpacity(0.4),
                                  offset: Offset(2, 3),
                                  spreadRadius: 5,
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: visitorData.visitorimage != null
                                  ? Image.network(
                                      visitorData.visitorimage,
                                      fit: BoxFit.cover,
                                    )
                                  : SvgPicture.asset(
                                      "assets/img/user(0).svg",
                                      color: Colors.grey,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                visitorData.visitorname,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              visitorData.isverified
                                  ? SvgPicture.asset(
                                      "assets/img/verified.svg",
                                      height: 20,
                                      width: 20,
                                    )
                                  : Container(),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      visitorData.totalpostCount.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 24,
                                      ),
                                    ),
                                    Text(
                                      "Posts",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                                VerticalDivider(
                                  color: Colors.white,
                                  thickness: 1,
                                  width: 30,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      visitorData.followersCount.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 24,
                                      ),
                                    ),
                                    Text(
                                      "Followers",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                                VerticalDivider(
                                  color: Colors.white,
                                  thickness: 1,
                                  width: 30,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      visitorData.followingsCount.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 24,
                                      ),
                                    ),
                                    Text(
                                      "Followings",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 50,
                            decoration: BoxDecoration(
                              color: subscribeText == "Follow"
                                  ? Colors.black
                                  : Colors.teal,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: FlatButton(
                              onPressed: () {
                                setState(() {
                                  issubunsub = true;
                                });
                                if (subscribeText == "Follow") {
                                  userMaintainer
                                      .subscribe(widget.visitorId)
                                      .then((_) {
                                    checkForSubscrition(widget.visitorId);
                                    Provider.of<UserData>(context,
                                            listen: false)
                                        .setSubscriberList()
                                        .then((_) {
                                      setState(() {
                                        issubunsub = false;
                                      });
                                    });
                                  });
                                } else {
                                  userMaintainer
                                      .unsubscribe(widget.visitorId)
                                      .then((_) {
                                    checkForSubscrition(widget.visitorId);
                                    Provider.of<UserData>(context,
                                            listen: false)
                                        .setSubscriberList()
                                        .then((_) {
                                      setState(() {
                                        issubunsub = false;
                                      });
                                    });
                                  });
                                }
                              },
                              child: issubunsub
                                  ? Center(child: CircularProgressIndicator())
                                  : Text(
                                      subscribeText,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(top: 20, left: 20, right: 10),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bio:",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              visitorData.bio,
                              textAlign: TextAlign.left,
                              maxLines: 4,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Posts:",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.image,
                                    color: Colors.teal,
                                  ),
                                  title: Text("Images"),
                                  trailing: Text(
                                      visitorData.imagePostCount.toString()),
                                  onTap: () => visitorData.imagePostCount != 0
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ImageSection(
                                              query: Firestore
                                                  .instance //search for the userid in User node
                                                  .collection("Image-Posts")
                                                  .where("user_id",
                                                      isEqualTo:
                                                          widget.visitorId)
                                                  .snapshots(),
                                            ),
                                          ),
                                        )
                                      : {},
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.message,
                                    color: Colors.teal,
                                  ),
                                  title: Text("Tweets"),
                                  trailing: Text(
                                      visitorData.tweetPostCount.toString()),
                                  onTap: () => visitorData.tweetPostCount != 0
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => TweetSection(
                                              query: Firestore
                                                  .instance //search for the userid in User node
                                                  .collection("Tweet-Posts")
                                                  .where("user_id",
                                                      isEqualTo:
                                                          widget.visitorId)
                                                  .snapshots(),
                                            ),
                                          ),
                                        )
                                      : {},
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.poll,
                                    color: Colors.teal,
                                  ),
                                  title: Text("Polls"),
                                  trailing: Text(
                                      visitorData.pollPostCount.toString()),
                                  onTap: () => visitorData.pollPostCount != 0
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PollSection(
                                              query: Firestore
                                                  .instance //search for the userid in User node
                                                  .collection("Poll-Posts")
                                                  .where("user_id",
                                                      isEqualTo:
                                                          widget.visitorId)
                                                  .snapshots(),
                                            ),
                                          ),
                                        )
                                      : {},
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.teal,
                                  ),
                                  title: Text("Pdfs"),
                                  trailing:
                                      Text(visitorData.docPostCount.toString()),
                                  onTap: () => visitorData.docPostCount != 0
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DocsSection(
                                              query: Firestore
                                                  .instance //search for the userid in User node
                                                  .collection("Doc-Posts")
                                                  .where("user_id",
                                                      isEqualTo:
                                                          widget.visitorId)
                                                  .snapshots(),
                                            ),
                                          ),
                                        )
                                      : {},
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
