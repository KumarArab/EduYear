import 'package:app/Screens/Profile/visit_profile.dart';
import 'package:app/helpers/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubscribedList extends StatelessWidget {
  final List<dynamic> subscribedList;
  SubscribedList({this.subscribedList});

  Future<DocumentSnapshot> getUserDetails(String userId) async {
    DocumentSnapshot ds =
        await Firestore.instance.collection("Users").document(userId).get();
    return ds;
  }

  @override
  Widget build(BuildContext context) {
    final String userid = Provider.of<UserData>(context).currentUserId;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Followings"),
        ),
        body: SafeArea(
          child: ListView.builder(
            itemBuilder: (ctx, i) {
              return FutureBuilder(
                future: getUserDetails(subscribedList[i]),
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? ListTile(
                          leading: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                    snapshot.data["profile_pic"],
                                    fit: BoxFit.cover,
                                  ) ??
                                  Icon(Icons.android),
                            ),
                          ),
                          title: Text(snapshot.data["name"]),
                          trailing: snapshot.data["user_id"] != userid
                              ? Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.teal,
                                  ),
                                  child: FlatButton(
                                    onPressed: () {},
                                    child: Text(
                                      'Following',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  width: 1,
                                ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => VisitProfile(
                                visitorId: subscribedList[i],
                              ),
                            ),
                          ),
                        )
                      : Container();
                },
              );
              // return ListTile(
              //   leading: CircleAvatar(
              //     child: Image.asset(),
              //   ),
              //   title: Text(subscribedList[i]),
              // );
            },
            itemCount: subscribedList.length,
          ),
        ));
  }
}
