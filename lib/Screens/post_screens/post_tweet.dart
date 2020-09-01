import 'package:app/helpers/styles.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostTweet extends StatelessWidget {
  static const routeName = "/post-tweet";
  String tweet;
  String tags;
  UserMaintainer userMaintainer = UserMaintainer();

  Future<void> postTweet(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("user_id");
    String timestamp = DateTime.now().toIso8601String();

    DocumentReference documentReference =
        Firestore.instance.collection("Tweet-Posts").document(timestamp);

    List<String> tagList = tags.split(" ");
    for (int i = 0; i < tagList.length; i++) {
      tagList[i] = tagList[i].toLowerCase();
    }
    await documentReference.setData(
      {
        "tweet": tweet,
        "tags": tagList,
        "user_id": id,
        "likes_count": 0,
        "likes": [],
        "timestamp": timestamp,
        "comments": {}
      },
    );

    Navigator.of(context).pop();
  }

  bool check(BuildContext context) {
    if (tweet != null && tags != null) {
      if (tags.split(" ").length > 11) {
        userMaintainer.showDailogBox(context, Text("Too many Tags"),
            Text("You can't add more than 10 tags"));
        return false;
      }
      return true;
    } else {
      userMaintainer.showDailogBox(context, Text("You missed any field"),
          Text("Both Fields are important. Make sure you fill both of them"));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    maxLines: 5,
                    onChanged: (value) {
                      tweet = value;
                    },
                    style:
                        TextStyle(color: Colors.black, fontFamily: "Poppins"),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 20),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: "Enter your tweet",
                      hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontFamily: "Poppins"),
                    ),
                  ),
                ),
                Container(
                  decoration: kTagContainerDecoration,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(10),
                  child: TextField(
                      decoration:
                          setTextFieldDecoration("Add spaced tags here"),
                      onChanged: (value) {
                        tags = value;
                      }),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: FlatButton(
                onPressed: () {
                  if (check(context)) {
                    postTweet(context);
                    userMaintainer.showToast("Tweet Uploaded");
                  }
                },
                child: Text(
                  "POST",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
