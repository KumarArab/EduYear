import 'package:app/helpers/user_maintainance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData with ChangeNotifier {
  String currentUserId;
  List<String> subscriberList;
  List<String> bannerList;
  String username;
  String imageUrl;
  String bio;
  bool isVerified;
  int imagePostCount = 0,
      tweetPostCount = 0,
      pollPostCount = 0,
      docPostCount = 0,
      totalPostCount = 0,
      followersCount = 0,
      followingCount = 0;

  UserMaintainer userMaintainer = UserMaintainer();

  setuserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString("user_id");
    username = prefs.getString("name");
    imageUrl = prefs.getString("profile_pic");
    bio = prefs.getString("bio");
    followersCount = prefs.getInt("followers");
    followingCount = prefs.getInt("followings");
    isVerified = prefs.getBool("verified");
    imagePostCount =
        await userMaintainer.countPost(currentUserId, "Image-Posts");
    tweetPostCount =
        await userMaintainer.countPost(currentUserId, "Tweet-Posts");
    pollPostCount = await userMaintainer.countPost(currentUserId, "Poll-Posts");
    docPostCount = await userMaintainer.countPost(currentUserId, "Doc-Posts");
    totalPostCount =
        imagePostCount + docPostCount + pollPostCount + tweetPostCount;
    notifyListeners();
  }

  setSubscriberList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    subscriberList = prefs.getStringList("subscribed");
    notifyListeners();
  }
}
