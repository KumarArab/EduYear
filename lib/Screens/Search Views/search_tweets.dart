import 'package:app/Provider/user_activity.dart';
import 'package:app/Screens/Home%20Views/tweet_view.dart';
import 'package:app/helpers/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchTweets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider.of<UserActivity>(context).searchString == null
        ? TweetSection(
            query: Firestore.instance.collection("Tweet-Posts").snapshots(),
          )
        : TweetSection(
            query: Firestore.instance
                .collection("Tweet-Posts")
                .where("tags",
                    arrayContainsAny:
                        Provider.of<UserActivity>(context).searchString)
                .snapshots(),
          );
  }
}
