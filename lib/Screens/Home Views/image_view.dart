import 'dart:io';

import 'package:app/Provider/login_store.dart';
import 'package:app/Screens/Profile/visit_profile.dart';
import 'package:app/Screens/post_screens/post_Image.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageSection extends StatefulWidget {
  final bool all;
  ImageSection({this.all});

  @override
  _ImageSectionState createState() => _ImageSectionState();
}

class _ImageSectionState extends State<ImageSection> {
  // bool isUploadig = false;
  // FileType _pickType;
  GlobalKey<ScaffoldState> _imagepickScaffold = GlobalKey();
  UserMaintainer userMaintainer = UserMaintainer();
  // List<DocumentSnapshot> dsList;
  List<String> subscribedList;

  @override
  void didChangeDependencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        subscribedList = prefs.getStringList("subscribed");
      });
    }
    print(subscribedList);

    // await fetchImagePosts();

    super.didChangeDependencies();
  }

  // Future<void> fetchImagePosts() async {
  //   List<DocumentSnapshot> documentList;
  //   documentList =
  //       (await Firestore.instance //search for the userid in User node
  //               .collection("Image-Posts")
  //               .where("user_id", isEqualTo: subscribedList)
  //               .getDocuments())
  //           .documents;
  //   if (mounted) {
  //     setState(() {
  //       dsList = documentList;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return (subscribedList == null)
        ? Center(child: Text("Loading..."))
        : StreamBuilder(
            stream: widget.all
                ? Firestore.instance.collection("Image-Posts").snapshots()
                : Firestore.instance
                    .collection("Image-Posts")
                    .where("user_id", whereIn: subscribedList)
                    .snapshots(),
            builder: (context, snapshot) {
              return (!snapshot.hasData || subscribedList == null)
                  ? Text('PLease Wait')
                  : ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        print(snapshot.data.documents.length);
                        DocumentSnapshot products = snapshot.data.documents[
                            snapshot.data.documents.length - 1 - index];
                        Map<String, dynamic> imagesMap =
                            new Map<String, dynamic>();
                        imagesMap = products["images"];
                        List<String> mapurls = [];
                        imagesMap != null
                            ? imagesMap.forEach((key, value) {
                                mapurls.add(value);
                              })
                            : {};
                        if (products["user_id"] == "+917549152303") {
                          print(
                              "Why the hell-----------------------------------");
                        }
                        // if (subscribedList.contains(products["user_id"])) {
                        //   print("subscribed: ${products["user_id"]}");
                        return (ImageCard(
                          imageUrl: mapurls,
                          caption: products["caption"],
                          user_id: products["user_id"],
                          username: products["name"],
                          avatar: products["avatar"],
                        ));
                        // } else {
                        //   print("not subscribed: ${products["user_id"]}");
                        // }

                        // return Container(
                        //     child: ImageCard(imageUrl: products["url"]));
                      },
                    );
            },
          );
  }
}

class ImageCard extends StatelessWidget {
  final List<String> imageUrl;
  final String caption;
  final String user_id;
  final String username;
  final String avatar;
  ImageCard({
    this.imageUrl,
    this.caption,
    this.user_id,
    this.username,
    this.avatar,
  });
  @override
  Widget build(BuildContext context) {
    if (imageUrl.length == 1) {
      return Container(
        margin: EdgeInsets.only(bottom: 20),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, VisitProfile.routeName,
                    arguments: user_id),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(avatar)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              child: Image.network(
                imageUrl[0],
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Text(
                caption,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.only(bottom: 20),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, VisitProfile.routeName,
                    arguments: user_id),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(avatar)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: Swiper(
                itemBuilder: (BuildContext context, int idx) {
                  return Image.network(
                    imageUrl[idx],
                    fit: BoxFit.cover,
                  );
                },
                itemCount: imageUrl.length,
                scrollDirection: Axis.horizontal,
                pagination: SwiperPagination(),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Text(
                caption,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

//ListView.builder(
//         itemBuilder: (ctx, i) {
//           Map<String, dynamic> imagesMap = new Map<String, dynamic>();
//           imagesMap = dsList[i]["images"];
//           List<String> mapurls = [];
//           imagesMap != null
//               ? imagesMap.forEach((key, value) {
//                   mapurls.add(value);
//                 })
//               : {};
//           return ImageCard(
//             caption: dsList[i]["caption"],
//             imageUrl: mapurls,
//             user_id: dsList[i]["user_id"],
//             username: dsList[i]["name"],
//           );
//         },
//         itemCount: dsList.length,
//       )
