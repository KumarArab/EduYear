import 'package:app/Screens/Home%20Views/image_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchImages extends StatefulWidget {
  final List<DocumentSnapshot> searchedImageList;
  SearchImages({this.searchedImageList});
  @override
  _SearchImagesState createState() => _SearchImagesState();
}

class _SearchImagesState extends State<SearchImages> {
  @override
  Widget build(BuildContext context) {
    return widget.searchedImageList == null
        ? ImageSection(
            all: true,
          )
        : ListView.builder(
            itemBuilder: (ctx, i) {
              Map<String, dynamic> imagesMap = new Map<String, dynamic>();
              imagesMap = widget.searchedImageList[i]["images"];
              List<String> mapurls = [];
              imagesMap != null
                  ? imagesMap.forEach((key, value) {
                      mapurls.add(value);
                    })
                  : {};
              return ImageCard(
                avatar: widget.searchedImageList[i]["avatar"],
                caption: widget.searchedImageList[i]["caption"],
                imageUrl: mapurls,
                user_id: widget.searchedImageList[i]["user_id"],
                username: widget.searchedImageList[i]["name"],
              );
            },
            itemCount: widget.searchedImageList.length,
          );
  }
}
