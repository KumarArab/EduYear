import 'package:app/Provider/user_activity.dart';
import 'package:app/Screens/Profile/visit_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchAccounts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider.of<UserActivity>(context).searchString == null
        ? SearchSection(
            query: Firestore.instance
                .collection("Users")
                .orderBy("followers")
                .snapshots(),
          )
        : SearchSection(
            query: Firestore.instance
                .collection("Users")
                .where("tags",
                    arrayContainsAny:
                        Provider.of<UserActivity>(context).searchString)
                .orderBy("followers")
                .snapshots(),
          );
  }
}

class SearchSection extends StatelessWidget {
  final Stream<QuerySnapshot> query;
  SearchSection({this.query});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: query,
      builder: (context, snapshot) {
        return !snapshot.hasData
            ? Center(
                child: Text("Please wait...."),
              )
            : ListView.builder(
                itemBuilder: (ctx, i) {
                  DocumentSnapshot products = snapshot
                      .data.documents[snapshot.data.documents.length - 1 - i];
                  return ListTile(
                    leading: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          products["profile_pic"],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      products["name"],
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => VisitProfile(
                          visitorId: products["user_id"],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: snapshot.data.documents.length,
              );
      },
    );
  }
}
