import 'dart:io';

import 'package:app/Provider/login_store.dart';
import 'package:app/Screens/post_Image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';

class ImageSection extends StatefulWidget {
  @override
  _ImageSectionState createState() => _ImageSectionState();
}

class _ImageSectionState extends State<ImageSection> {
  bool isUploadig = false;
  FileType _pickType;
  GlobalKey<ScaffoldState> _imagepickScaffold = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final logindata = Provider.of<LoginStore>(context);

    return Scaffold(
      backgroundColor: Colors.teal,
      key: _imagepickScaffold,
      body: Stack(
        children: [
          StreamBuilder(
            stream: Firestore.instance.collection("Posts").snapshots(),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? Text('PLease Wait')
                  : ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot products =
                            snapshot.data.documents[index];
                        Map<String, dynamic> imagesMap =
                            new Map<String, dynamic>();
                        imagesMap = products["images"];
                        List<String> mapurls = [];
                        imagesMap.forEach((key, value) {
                          mapurls.add(value);
                        });

                        // if (mapurls.length == 1) {
                        return (ImageCard(
                          imageUrl: mapurls,
                          caption: products["caption"],
                        ));
                        //}

                        // return Container(
                        //     child: ImageCard(imageUrl: products["url"]));
                      },
                    );
            },
          ),
        ],
      ),
    );
  }
}

class ImageCard extends StatelessWidget {
  final List<String> imageUrl;
  final String caption;
  ImageCard({this.imageUrl, this.caption});
  @override
  Widget build(BuildContext context) {
    if (imageUrl.length == 1) {
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
              height: MediaQuery.of(context).size.width,
              child: Image.network(
                imageUrl[0],
                fit: BoxFit.contain,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.all(10),
              child: Text(caption),
            ),
          ],
        ),
      );
    } else {
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
              height: MediaQuery.of(context).size.width,
              child: Swiper(
                itemBuilder: (BuildContext context, int idx) {
                  return Container(
                    child: Image.network(
                      imageUrl[idx],
                      fit: BoxFit.contain,
                    ),
                  );
                },
                itemCount: imageUrl.length,
                scrollDirection: Axis.horizontal,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.all(10),
              child: Text(caption),
            ),
          ],
        ),
      );
    }
  }
}