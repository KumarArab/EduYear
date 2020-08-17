import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TweetSection extends StatefulWidget {
  @override
  _TweetSectionState createState() => _TweetSectionState();
}

class _TweetSectionState extends State<TweetSection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: StreamBuilder(
        stream: Firestore.instance.collection("Tweet-Posts").snapshots(),
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
  final String user_id, tweet, username;
  TweetCard({this.user_id, this.tweet, this.username});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(3, 3),
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              username,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            padding: EdgeInsets.only(bottom: 5),
          ),
          Divider(),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(tweet),
          ),
        ],
      ),
    );
  }
}
