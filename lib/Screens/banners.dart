import 'package:app/helpers/user_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Banners extends StatelessWidget {
  static const routeName = "/banners";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance.collection("Banners").snapshots(),
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? Center(child: Text("Loading"))
              : ListView.builder(
                  itemBuilder: (ctx, i) {
                    return GestureDetector(
                      onTap: () async {
                        if (await canLaunch(snapshot.data.documents[i]["url"]))
                          launch(snapshot.data.documents[i]["url"]);
                        else {}
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data.documents[i]["image"],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                              strokeWidth: 1,
                            )),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: snapshot.data.documents.length,
                );
        },
      ),
    );
  }
}
