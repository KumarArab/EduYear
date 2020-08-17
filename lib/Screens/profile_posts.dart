import 'package:app/helpers/user_maintainance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app/Screens/Home Views/image_view.dart';

class ProfilePost extends StatefulWidget {
  final String type;
  ProfilePost({this.type});
  @override
  _ProfilePostState createState() => _ProfilePostState();
}

class _ProfilePostState extends State<ProfilePost> {
  UserMaintainer userMaintainer = UserMaintainer();
  List<DocumentSnapshot> documentList;
  @override
  void didChangeDependencies() async {
    List<DocumentSnapshot> temp =
        await userMaintainer.getProfilePost(widget.type);
    setState(() {
      documentList = temp;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: documentList == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemBuilder: (ctx, i) {
                Map<String, dynamic> imagesMap = new Map<String, dynamic>();
                imagesMap = documentList[i]["images"];
                List<String> mapurls = [];
                imagesMap != null
                    ? imagesMap.forEach((key, value) {
                        mapurls.add(value);
                      })
                    : {};
                return ImageCard(
                  caption: documentList[i]["caption"],
                  imageUrl: mapurls,
                  user_id: documentList[i]["user_id"],
                  username: documentList[i]["name"],
                );
              },
              itemCount: documentList.length,
            ),
    ));
  }
}
