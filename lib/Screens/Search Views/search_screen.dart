import 'package:app/Provider/user_activity.dart';
import 'package:app/Screens/Home%20Views/docs_view.dart';
import 'package:app/Screens/Home%20Views/image_view.dart';
import 'package:app/Screens/Home%20Views/poll_view.dart';
import 'package:app/Screens/Home%20Views/tweet_view.dart';
import 'package:app/Screens/Search%20Views/search_accounts.dart';
import 'package:app/Screens/Search%20Views/search_docs.dart';
import 'package:app/Screens/Search%20Views/search_image.dart';
import 'package:app/Screens/Search%20Views/search_polls.dart';
import 'package:app/Screens/Search%20Views/search_tweets.dart';
import 'package:app/helpers/common_widgets.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  // @override
  // void dispose() {
  //   Provider.of<UserActivity>(context).clearSearchLists();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final userActivity = Provider.of<UserActivity>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          child: TextField(
            textInputAction: TextInputAction.search,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: "Search Related Tags",
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
            onChanged: (value) {
              searchString = value;
            },
            onSubmitted: (value) {
              userActivity.createSearchList(value);
              // userActivity.searchImagePosts(value.split(" "));
              // userActivity.searchTweetPosts(value.split(" "));
              print("I got clicked-----------");
            },
          ),
        ),
      ),
      bottomNavigationBar: Manual(
        screen: "search",
      ),
      body: SafeArea(
          child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(vertical: 10),
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FlatButton(
                  onPressed: () {
                    _controller.animateToPage(0,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.fastOutSlowIn);
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
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    _controller.animateToPage(1,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.fastOutSlowIn);
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
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    _controller.animateToPage(2,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.fastOutSlowIn);
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
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    _controller.animateToPage(3,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.fastOutSlowIn);
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
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    _controller.animateToPage(4,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.fastOutSlowIn);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color:
                          currentPageId == 4 ? Colors.teal : Colors.transparent,
                    ),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Accounts",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          userActivity.searchString != null
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Searched Results"),
                      GestureDetector(
                          onTap: () {
                            userActivity.clearSearchLists();
                          },
                          child: Text(
                            "Clear",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ))
                    ],
                  ),
                )
              : Container(),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: PageView(
                controller: _controller,
                onPageChanged: (value) {
                  setState(() {
                    currentPageId = value;
                  });
                },
                children: [
                  SearchImages(),
                  SearchTweets(),
                  SearchPolls(),
                  SearchDocs(),
                  SearchAccounts()
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
