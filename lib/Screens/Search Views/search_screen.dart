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
  int currentPageId = 0;
  UserMaintainer userMaintainer = UserMaintainer();
  List<DocumentSnapshot> searchedImageSnapShot;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Container(
          child: TextField(
            autofocus: true,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.search,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search Related Tags",
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
            onChanged: (value) {
              searchString = value;
            },
            onSubmitted: (value) async {
              List<DocumentSnapshot> temp =
                  await userMaintainer.searchTweets(value.split(" "));
              print("recieved results");
              setState(() {
                searchedImageSnapShot = temp;
              });
            },
          ),
        ),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FlatButton(
                  onPressed: () {
                    _controller.jumpToPage(0);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color:
                          currentPageId == 0 ? Colors.teal : Colors.transparent,
                    ),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Images",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    _controller.jumpToPage(1);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color:
                          currentPageId == 1 ? Colors.teal : Colors.transparent,
                    ),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Tweets",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    _controller.jumpToPage(2);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color:
                          currentPageId == 2 ? Colors.teal : Colors.transparent,
                    ),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Polls",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    _controller.jumpToPage(3);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color:
                          currentPageId == 3 ? Colors.teal : Colors.transparent,
                    ),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Docs",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              child: PageView(
                controller: _controller,
                onPageChanged: (value) {
                  setState(() {
                    currentPageId = value;
                  });
                },
                children: [
                  SearchImages(
                    searchedImageList: searchedImageSnapShot,
                  ),
                  TweetSection(
                    all: true,
                  ),
                  PollSection(
                    all: true,
                  ),
                  DocsSection(
                    all: true,
                  ),
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
