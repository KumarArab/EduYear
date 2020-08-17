import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class DocsSection extends StatefulWidget {
  @override
  _DocsSectionState createState() => _DocsSectionState();
}

class _DocsSectionState extends State<DocsSection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: StreamBuilder(
        stream: Firestore.instance.collection("Doc-Posts").snapshots(),
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
  final String user_id, filename, docPath, username;
  DocCard({this.user_id, this.filename, this.docPath, this.username});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(3, 3),
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              username,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            padding: EdgeInsets.only(bottom: 5),
          ),
          Container(
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
                Text(filename),
                IconButton(
                  icon: Icon(Icons.file_download),
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
