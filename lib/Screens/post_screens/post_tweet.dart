import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostTweet extends StatelessWidget {
  static const routeName = "/post-tweet";
  String tweet;
  String tags;

  Future<void> postTweet(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("email") != null
        ? prefs.getString("email")
        : prefs.getString("phoneNumber");
    int noOfPosts = prefs.getInt("no_of_posts");
    String name = prefs.getString("name");
    String avatar = prefs.getString("profile_pic");

    DocumentReference documentReference =
        Firestore.instance.collection("Tweet-Posts").document("$id-$noOfPosts");

    List<String> tagList = tags.split(" ");
    Map<String, String> tagMap = Map<String, String>();
    for (int i = 0; i < tagList.length; i++) {
      tagMap["tag[$i]"] = tagList[i];
    }
    await documentReference.setData(
      {
        // "images": imagesMap,
        "tweet": tweet,
        "tags": tagList,
        "user_id": id,
        "name": name,
        "avatar": avatar,
      },
    );
    noOfPosts += 1;
    await Firestore.instance
        .collection("Users")
        .document(id)
        .updateData({"no_of_posts": noOfPosts.toString()});
    await prefs.setInt("no_of_posts", noOfPosts);
    Navigator.of(context).pop();
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
                  margin: EdgeInsets.all(20),
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
                      contentPadding: EdgeInsets.only(left: 25),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: "Enter your tweet",
                      hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontFamily: "Poppins"),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: TextField(
                      decoration: InputDecoration(
                        hintText: "Add Tags",
                      ),
                      onChanged: (value) {
                        tags = value;
                      }),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: FlatButton(
                    onPressed: () {
                      postTweet(context);
                    },
                    child: Text(
                      "Finish",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
