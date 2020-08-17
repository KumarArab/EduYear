import 'package:app/Screens/Home%20Views/docs_view.dart';
import 'package:app/Screens/Home%20Views/image_view.dart';
import 'package:app/Screens/Home%20Views/poll_view.dart';
import 'package:app/Screens/Home%20Views/tweet_view.dart';
import 'package:app/Screens/Search%20Views/search_image.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = "search-screen";
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  PageController _controller = PageController(
    initialPage: 0,
  );
  String searchString;
  UserMaintainer userMaintainer = UserMaintainer();
  List<DocumentSnapshot> searchedImageSnapShot;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    searchString = value;
                  },
                ),
              ),
              RaisedButton(
                onPressed: () async {
                  List<DocumentSnapshot> temp = await userMaintainer
                      .searchTweets(searchString.split(" "));
                  print("recieved results");
                  setState(() {
                    searchedImageSnapShot = temp;
                  });
                },
                child: Text("Search"),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FlatButton(
                onPressed: () {
                  _controller.jumpToPage(0);
                },
                child: Text("Images"),
              ),
              FlatButton(
                onPressed: () {
                  _controller.jumpToPage(1);
                },
                child: Text("Tweets"),
              ),
              FlatButton(
                onPressed: () {
                  _controller.jumpToPage(2);
                },
                child: Text("Polls"),
              ),
              FlatButton(
                onPressed: () {
                  _controller.jumpToPage(3);
                },
                child: Text("Documents"),
              ),
            ],
          ),
          Expanded(
            child: PageView(
              controller: _controller,
              children: [
                SearchImages(
                  searchedImageList: searchedImageSnapShot,
                ),
                TweetSection(),
                PollSection(),
                DocsSection(),
              ],
            ),
          )
        ],
      )),
    );
  }
}
