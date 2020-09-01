import 'package:app/Login-System/get-details.dart';
import 'package:app/Screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';

class UserMaintainer {
//Make User Ready
  Future<void> checkUserExistance(
      FirebaseUser user, BuildContext context, String type) async {
    if (type == "google") {
      if (await checkIfUserExist(user, type)) {
        DocumentSnapshot documentSnapshot = await Firestore.instance
            .collection("Users")
            .document(user.email)
            .get();
        Map<String, dynamic> fetchedUserData = documentSnapshot.data;
        await saveUserDataToLocal(fetchedUserData);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => HomeScreen()),
            (Route<dynamic> route) => false);

        //fetch data of user and store it to shared shared_preferences
      } else {
        //send to GetDetails Screens

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => HomeScreen()),
            (Route<dynamic> route) => false);

        Navigator.of(context).pushNamedAndRemoveUntil(
            GetDetails.routeName, (route) => false,
            arguments: user);
        //  Navigator.pushNamed(context, GetDetails.routeName, arguments: user);
        //get the details
        // create new user node and store data
        //store the same in shared prefs
      }
    } else {
      if (await checkIfUserExist(user, type)) {
        DocumentSnapshot documentSnapshot = await Firestore.instance
            .collection("Users")
            .document(user.phoneNumber)
            .get();
        Map<String, dynamic> fetchedUserData = documentSnapshot.data;
        await saveUserDataToLocal(fetchedUserData);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => HomeScreen()),
            (Route<dynamic> route) => false);

        //fetch data of user and store it to shared shared_preferences
      } else {
        //send to GetDetails Screens
        // Navigator.pushNamed(context, GetDetails.routeName, arguments: user);
        Navigator.of(context).pushNamedAndRemoveUntil(
            GetDetails.routeName, (route) => false,
            arguments: user);
        //get the details
        // create new user node and store data
        //store the same in shared prefs
      }
    }
  }

  Future<bool> checkIfUserExist(FirebaseUser user, String type) async {
    List<DocumentSnapshot> documentList;
    if (type == "google") {
      documentList =
          (await Firestore.instance //search for the userid in User node
                  .collection("Users")
                  .where("user_id", isEqualTo: user.email)
                  .getDocuments())
              .documents;
    } else {
      documentList =
          (await Firestore.instance //search for the userid in User node
                  .collection("Users")
                  .where("user_id", isEqualTo: user.phoneNumber)
                  .getDocuments())
              .documents;
    }
    print(user.email);
    if (documentList.length == 1) {
      print(
          "User exits-----------------------------------------------------------------------------");
      return true;
    } else {
      print(
          "User don't exists   --------------------------------------------------------------------");
      return false;
    }
  }

  // Future<void> createNewuserNode() async {
  //   LoginStore loginStore = LoginStore();
  //   FirebaseUser user = await loginStore.getCurrentUser();
  // }

  Future<void> saveUserDataToLocal(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("name", userData["name"]);
    prefs.setString("user_id", userData["user_id"]);
    prefs.setString("profile_pic", userData["profile_pic"]);
    prefs.setString("bio", userData["bio"]);
    prefs.setInt("followers", userData["followers"]);
    prefs.setInt("followings", userData["followings"]);
    prefs.setBool("verified", userData["verified"]);
    List<dynamic> tempsubscribedList = userData["subscribed"];
    List<String> subscribedList = [];
    for (int i = 0; i < tempsubscribedList.length; i++) {
      subscribedList.add(tempsubscribedList[i].toString());
    }
    prefs.setStringList("subscribed", subscribedList);
  }

  Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("user_id");
    return id;
  }

  Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString("name");
    return name;
  }

  Future<int> countPost(String userId, String postTpe) async {
    List<DocumentSnapshot> documentList;
    documentList =
        (await Firestore.instance //search for the userid in User node
                .collection(postTpe)
                .where("user_id", isEqualTo: userId)
                .getDocuments())
            .documents;
    return documentList.length;
  }

  Future<List<DocumentSnapshot>> getProfilePost(String type) async {
    String userId = await getUserId();
    List<DocumentSnapshot> documentList;
    documentList =
        (await Firestore.instance //search for the userid in User node
                .collection(type)
                .where("user_id", isEqualTo: userId)
                .getDocuments())
            .documents;
    return documentList;
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black.withOpacity(0.6),
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void showDailogBox(
      BuildContext context, Widget titleWidget, Widget subtitleWidget) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: titleWidget,
        content: subtitleWidget,
      ),
    );
  }

//  SUBSCRIBE A USER
  Future<void> subscribe(String visitorId) async {
    String userId = await getUserId();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DocumentReference visitorReference =
        Firestore.instance.collection("Users").document(visitorId);
    DocumentReference userReference =
        Firestore.instance.collection("Users").document(userId);

    DocumentSnapshot visitorSnapshot = await visitorReference.get();
    DocumentSnapshot userSnapshot = await userReference.get();

//FIRST INCREASE THE FOLLOWER COUNT OF VISITED ACCOUNT
    int visitorFollowerCount = visitorSnapshot["followers"];
    visitorReference.updateData({"followers": visitorFollowerCount + 1});

//INCREASE THE FOLLOWING COUNT OF USER ACCOUNT AND ADD IT TO LIST
    int userFollowingCount = userSnapshot["followings"];
    await userReference.updateData({
      "subscribed": FieldValue.arrayUnion([visitorId]),
      "followings": userFollowingCount + 1,
    });
//UPDATE THE USER DATA LOCALLY
    List<String> subscribedList = prefs.getStringList("subscribed");
    subscribedList.add(visitorId);
    prefs.setStringList("subscribed", subscribedList);
    prefs.setInt("followings", userFollowingCount + 1);
  }

//  UNSUBSCRIBE A USER
  Future<void> unsubscribe(String visitorId) async {
    String userId = await getUserId();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DocumentReference visitorReference =
        Firestore.instance.collection("Users").document(visitorId);
    DocumentReference userReference =
        Firestore.instance.collection("Users").document(userId);

    DocumentSnapshot visitorSnapshot = await visitorReference.get();
    DocumentSnapshot userSnapshot = await userReference.get();

//FIRST INCREASE THE FOLLOWER COUNT OF VISITED ACCOUNT
    int visitorFollowerCount = visitorSnapshot["followers"];
    visitorReference.updateData({"followers": visitorFollowerCount - 1});

//INCREASE THE FOLLOWING COUNT OF USER ACCOUNT AND ADD IT TO LIST
    int userFollowingCount = userSnapshot["followings"];
    await userReference.updateData({
      "subscribed": FieldValue.arrayRemove([visitorId]),
      "followings": userFollowingCount - 1,
    });
//UPDATE THE USER DATA LOCALLY
    List<String> subscribedList = prefs.getStringList("subscribed");
    subscribedList.remove(visitorId);
    prefs.setStringList("subscribed", subscribedList);
    prefs.setInt("followings", userFollowingCount - 1);
  }

  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    int quality = 50;
    double filesize = file.lengthSync() / (1024 * 1024);
    if (filesize < 1) {
      quality = 75;
    }
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      rotate: 0,
    );

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }
}
