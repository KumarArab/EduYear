import 'package:app/Screens/Profile/visit_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TweetSection extends StatefulWidget {
  final bool all;
  TweetSection({this.all});
  @override
  _TweetSectionState createState() => _TweetSectionState();
}

class _TweetSectionState extends State<TweetSection> {
  List<String> subscribedList;

  @override
  void didChangeDependencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
      backgroundColor: Colors.black,
      body: StreamBuilder(
        stream: widget.all
            ? Firestore.instance.collection("Tweet-Posts").snapshots()
            : Firestore.instance
                .collection("Tweet-Posts")
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
                    // Map<String, dynamic> imagesMap =
                    //     new Map<String, dynamic>();
                    // imagesMap = products["images"];
                    // List<String> mapurls = [];
                    // imagesMap != null
                    //     ? imagesMap.forEach((key, value) {
                    //         mapurls.add(value);
                    //       })
                    //     : {};

                    // if (mapurls.length == 1) {
                    return (TweetCard(
                      user_id: products["user_id"],
                      tweet: products["tweet"],
                      username: products["name"],
                      avatar: products["avatar"],
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

class TweetCard extends StatelessWidget {
  final String user_id, tweet, username, avatar;
  TweetCard({this.user_id, this.tweet, this.username, this.avatar});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, VisitProfile.routeName,
                  arguments: user_id),
              child: Row(
                children: [
                  CircleAvatar(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(avatar),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
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
          Divider(),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(tweet,
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 1,
                  height: 2,
                )),
          ),
        ],
      ),
    );
  }
}
