import 'package:app/Provider/login_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/button.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, String> _paths;
  bool isUploadig = false;
  String _extension;
  FileType _pickType;
  GlobalKey<ScaffoldState> _imagepickScaffold = GlobalKey();
  final FirebaseStorage storage = FirebaseStorage.instance;
  Future<void> openFileExplorer() async {
    try {
      setState(() {
        isUploadig = true;
      });
      _paths = await FilePicker.getMultiFilePath(type: FileType.image);
      uploadToFirebase();
      setState(() {
        isUploadig = false;
      });
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  uploadToFirebase() {
    _paths.forEach((filename, filePath) async {
      print(filename);
      _extension = filename.toString().split(".").last;
      // StorageReference storageReference =
      //     FirebaseStorage.instance.ref().child(filename);
      // storageReference.getDownloadURL().addOnSuccessListener(new OnSuccessListener<Uri>(){})
      StorageTaskSnapshot snapshot = await storage
          .ref()
          .child("images/$filename")
          .putFile(File(filePath))
          .onComplete;
      if (snapshot.error == null) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        await Firestore.instance
            .collection("images")
            .add({"url": downloadUrl, "name": filename});
        setState(() {
          isUploadig = false;
        });
      } else {
        print('Error from image repo ${snapshot.error.toString()}');
        throw ('This file is not an image');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final logindata = Provider.of<LoginStore>(context);
    return Scaffold(
      key: _imagepickScaffold,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
            Text(logindata.username != null ? logindata.username : "No Data"),
        actions: [
          IconButton(
            onPressed: openFileExplorer,
            icon: isUploadig
                ? CircularProgressIndicator()
                : Icon(Icons.ac_unit, color: Colors.white),
          ),
          FlatButton.icon(
            label: Text(
              "Log Out",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            icon: Icon(Icons.cancel, color: Colors.white),
            onPressed: () {
              Provider.of<LoginStore>(context, listen: false).signOut(context);
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection("images").snapshots(),
        builder: (context, snapshot) {
          print(snapshot.data.documents.length);
          return !snapshot.hasData
              ? Text('PLease Wait')
              : ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot products = snapshot.data.documents[index];
                    return Container(child: Image.network(products["url"]));
                  },
                );
        },
      ),
    );
  }
}

// StorageTaskSnapshot snapshot = await storage
//         .ref()
//         .child("images/$filename")
//         .putFile(File(filename))
//         .onComplete;
//         if (snapshot.error == null) {
//           final String downloadUrl =
//               await snapshot.ref.getDownloadURL();
//           await Firestore.instance
//               .collection("images")
//               .add({"url": downloadUrl, "name": filename});
//           setState(() {
//             isUploadig = false;
//           });
//           final snackBar =
//               SnackBar(
//                 key: _imagepickScaffold,
//                 content: Text('Yay! Success'));
//           Scaffold.of(context).showSnackBar(snackBar);
//         } else {
//           print(
//               'Error from image repo ${snapshot.error.toString()}');
//           throw ('This file is not an image');
//         }
//       });
