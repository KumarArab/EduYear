import 'package:app/Screens/Profile/visit_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DocsSection extends StatefulWidget {
  final bool all;
  DocsSection({this.all});
  @override
  _DocsSectionState createState() => _DocsSectionState();
}

class _DocsSectionState extends State<DocsSection> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: widget.all
            ? Firestore.instance.collection("Doc-Posts").snapshots()
            : Firestore.instance
                .collection("Doc-Posts")
                .where("user_id", whereIn: subscribedList)
                .snapshots(),
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? Text('PLease Wait')
              : ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot products = snapshot.data
                        .documents[snapshot.data.documents.length - 1 - index];
                    // Map<String, dynamic> imagesMap =
                    //     new Map<String, dynamic>();
                    // imagesMap = products["images"];
                    // List<String> mapurls = [];
                    // imagesMap != null
                    //     ? imagesMap.forEach((key, value) {
                    //         mapurls.add(value);
                    //       })
                    //     : {};

                    // if (mapurls.length == 1) {
                    return (DocCard(
                      user_id: products["user_id"],
                      filename: products["document_name"],
                      docPath: products["doc_path"],
                      username: products["name"],
                      avatar: products["avatar"],
                    ));
                    //}

                    // return Container(
                    //     child: ImageCard(imageUrl: products["url"]));
                  },
                );
        },
      ),
    );
  }
}

class DocCard extends StatelessWidget {
  final String user_id, filename, docPath, username, avatar;
  DocCard(
      {this.user_id, this.filename, this.docPath, this.username, this.avatar});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, VisitProfile.routeName,
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
            padding: EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset("assets/img/pdf.svg"),
                ),
                Text(
                  filename,
                  style: TextStyle(),
                ),
                IconButton(
                  icon: Icon(Icons.file_download, color: Colors.black),
                  onPressed: () async {
                    if (await canLaunch(docPath))
                      launch(docPath);
                    else {}
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
