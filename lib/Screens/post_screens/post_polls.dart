import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostPolls extends StatefulWidget {
  static const routeName = "post-poll";
  @override
  _PostPollsState createState() => _PostPollsState();
}

class _PostPollsState extends State<PostPolls> {
  String tags;
  String question;
  String option1;
  String option2;
  String option3;
  String option4;
  bool isAnswered = false;
  String userChoice;
  int uploaderChoice;

  Future<void> postPoll(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("email") != null
        ? prefs.getString("email")
        : prefs.getString("phoneNumber");
    int noOfPosts = prefs.getInt("no_of_posts");
    String name = prefs.getString("name");
    String profilepic = prefs.getString("profile_pic");

    DocumentReference documentReference =
        Firestore.instance.collection("Poll-Posts").document("$id-$noOfPosts");

    List<String> tagList = tags.split(" ");
    Map<String, String> tagMap = Map<String, String>();
    for (int i = 0; i < tagList.length; i++) {
      tagMap["tag[$i]"] = tagList[i];
    }
    Map<String, int> optionsMap = Map<String, int>();
    optionsMap[option1] = uploaderChoice == 1 ? 1 : 0;
    optionsMap[option2] = uploaderChoice == 2 ? 1 : 0;
    if (option3 != null) {
      optionsMap[option3] = uploaderChoice == 3 ? 1 : 0;
    }
    if (option4 != null) {
      optionsMap[option4] = uploaderChoice == 4 ? 1 : 0;
    }

    await documentReference.setData(
      {
        // "images": imagesMap,
        "question": question,
        "tags": tagList,
        "user_id": id,
        "avatar": profilepic,
        "options": optionsMap,
        "postNo": noOfPosts.toString(),
        "name": name,
        "voters": [id]
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
                      question = value;
                    },
                    style:
                        TextStyle(color: Colors.black, fontFamily: "Poppins"),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 25),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: "Enter your Poll Question",
                      hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontFamily: "Poppins"),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("Option 1:    "),
                          Expanded(
                            child: TextField(onChanged: (value) {
                              option1 = value;
                            }),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text("Option 2:    "),
                          Expanded(
                            child: TextField(onChanged: (value) {
                              option2 = value;
                            }),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text("Option 3:    "),
                          Expanded(
                            child: TextField(onChanged: (value) {
                              option3 = value;
                            }),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text("Option 4:    "),
                          Expanded(
                            child: TextField(onChanged: (value) {
                              option4 = value;
                            }),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("Your Choice"),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: RaisedButton(
                                onPressed: () {
                                  if (option1 != null) {
                                    uploaderChoice = 1;
                                    setState(() {
                                      isAnswered = true;
                                    });
                                  }
                                },
                                child: Text("1"),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: RaisedButton(
                                onPressed: () {
                                  if (option2 != null) {
                                    uploaderChoice = 2;
                                    setState(() {
                                      isAnswered = true;
                                    });
                                  }
                                },
                                child: Text("2"),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: RaisedButton(
                                onPressed: () {
                                  if (option3 != null) {
                                    uploaderChoice = 3;
                                    setState(() {
                                      isAnswered = true;
                                    });
                                  }
                                },
                                child: Text("3"),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: RaisedButton(
                                onPressed: () {
                                  if (option4 != null) {
                                    uploaderChoice = 4;
                                    setState(() {
                                      isAnswered = true;
                                    });
                                  }
                                },
                                child: Text("4"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                isAnswered
                    ? Text("Your answer recorded: option $uploaderChoice")
                    : Container(),
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
                      postPoll(context);
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
