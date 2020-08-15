import 'package:app/Provider/login_store.dart';
import 'package:app/Screens/Login-System/get-details.dart';
import 'package:app/Screens/home_screen.dart';
import 'package:app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        Navigator.pushNamed(context, GetDetails.routeName, arguments: user);
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
        Navigator.pushNamed(context, GetDetails.routeName, arguments: user);
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
                  .where("email", isEqualTo: user.email)
                  .getDocuments())
              .documents;
    } else {
      documentList =
          (await Firestore.instance //search for the userid in User node
                  .collection("Users")
                  .where("phoneNumber", isEqualTo: user.phoneNumber)
                  .getDocuments())
              .documents;
    }

    if (documentList.length == 1) {
      //if exists return true else false
      print(
          "User exits-----------------------------------------------------------------------------");
      return true;
    } else {
      print(
          "User don't exists ${documentList.length}--------------------------------------------------------------------");
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
    prefs.setString("email", userData["email"]);
    prefs.setString("phoneNumber", userData["phoneNumber"]);
    prefs.setString("profile_pic", userData["profile_pic"]);
    prefs.setString("uid", userData["uid"]);
  }
}
