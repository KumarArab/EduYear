import 'package:app/helpers/user_maintainance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisitorData with ChangeNotifier {
  UserMaintainer userMaintainer = UserMaintainer();
  String visitorname = "Loading";
  String bio;
  List<dynamic> subscribedList;
  bool isverified = false;
  String visitorimage;
  int imagePostCount = 0,
      tweetPostCount = 0,
      pollPostCount = 0,
      docPostCount = 0,
      totalpostCount = 0,
      followersCount = 0,
      followingsCount = 0;
  setVisitorsData(String visitorId) async {
    DocumentSnapshot ds =
        await Firestore.instance.collection("Users").document(visitorId).get();
    visitorname = ds["name"];
    visitorimage = ds["profile_pic"];
    subscribedList = ds["subscribed"];
    isverified = ds["verified"];
    followersCount = ds["followers"];
    followingsCount = ds["followings"];
    bio = ds["bio"];
    imagePostCount = await userMaintainer.countPost(visitorId, "Image-Posts");
    tweetPostCount = await userMaintainer.countPost(visitorId, "Tweet-Posts");
    pollPostCount = await userMaintainer.countPost(visitorId, "Poll-Posts");
    docPostCount = await userMaintainer.countPost(visitorId, "Doc-Posts");
    totalpostCount =
        imagePostCount + tweetPostCount + pollPostCount + docPostCount;
    notifyListeners();
  }
}
