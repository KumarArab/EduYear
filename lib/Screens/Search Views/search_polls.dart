import 'package:app/Provider/user_activity.dart';
import 'package:app/Screens/Home%20Views/poll_view.dart';
import 'package:app/helpers/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPolls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider.of<UserActivity>(context).searchString == null
        ? PollSection(
            query: Firestore.instance.collection("Poll-Posts").snapshots(),
          )
        : PollSection(
            query: Firestore.instance
                .collection("Poll-Posts")
                .where("tags",
                    arrayContainsAny:
                        Provider.of<UserActivity>(context).searchString)
                .snapshots(),
          );

    // StreamBuilder(
    //     stream: Firestore.instance
    //         .collection("Poll-Posts")
    //         .where("tags",
    //             arrayContainsAny:
    //                 Provider.of<UserActivity>(context).searchString)
    //         .snapshots(),
    //     builder: (context, snapshot) {
    //       return !snapshot.hasData
    //           ? Center(child: Text("Loading"))
    //           : ListView.builder(
    //               itemBuilder: (ctx, i) {
    //                 DocumentSnapshot products = snapshot.data
    //                     .documents[snapshot.data.documents.length - 1 - i];
    //                 Map<String, dynamic> imagesMap =
    //                     new Map<String, dynamic>();
    //                 imagesMap = products["images"];
    //                 List<String> mapurls = [];
    //                 imagesMap != null
    //                     ? imagesMap.forEach((key, value) {
    //                         mapurls.add(value);
    //                       })
    //                     : {};

    //                 List<dynamic> voters = products["voters"];
    //                 bool isAlreadyVoted = false;
    //                 if (voters.contains(
    //                     Provider.of<UserData>(context).currentUserId)) {
    //                   isAlreadyVoted = true;
    //                 }
    //                 List<dynamic> likes = products["likes"];

    //                 bool isAlreadyLiked = false;
    //                 print(Provider.of<UserData>(context).currentUserId);
    //                 if (likes.contains(
    //                     Provider.of<UserData>(context).currentUserId)) {
    //                   isAlreadyLiked = true;
    //                 }
    //                 return PollCard(
    //                   question: products["question"],
    //                   userId: products["user_id"],
    //                   username: products["name"],
    //                   avatar: products["avatar"],
    //                   optionsMap: products["options"],
    //                   postNo: products["postNo"],
    //                   isAlreadyVoted: isAlreadyVoted,
    //                   image: products["image"],
    //                   likes_count: products["likes_count"],
    //                   isAlreadyLiked: isAlreadyLiked,
    //                   comments: products["Comments"],
    //                 );
    //               },
    //               itemCount: snapshot.data.documents.length,
    //             );
    //     },
    //   );
  }
}
