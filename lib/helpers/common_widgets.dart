import 'package:app/Screens/Profile/user_profile.dart';
import 'package:app/Screens/Profile/visit_profile.dart';
import 'package:app/Screens/Search%20Views/search_screen.dart';
import 'package:app/Screens/home_screen.dart';
import 'package:app/Screens/post_screens/post_Image.dart';
import 'package:app/Screens/post_screens/post_document.dart';
import 'package:app/Screens/post_screens/post_polls.dart';
import 'package:app/Screens/post_screens/post_tweet.dart';
import 'package:app/helpers/handle_dynamicLinks.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:app/models/image_post_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share/share.dart';

class CommonWidgets {
  DynamicLinksService dynamicLinksService = DynamicLinksService();
  UserMaintainer userMaintainer = UserMaintainer();
  Map<String, String> _paths;

  Future<void> openPdfExplorer(BuildContext context) async {
    String docPath = await FilePicker.getFilePath(type: FileType.custom);
    String _extension = docPath.toString().split(".").last;
    print(docPath);
    if (_extension == "pdf") {
      Navigator.of(context)
          .pushNamed(PostDocument.routeName, arguments: docPath);
    }
  }

  Future<void> openFileExplorer(BuildContext context) async {
    try {
      _paths = await FilePicker.getMultiFilePath(type: FileType.image);
      Map<String, String> paths = _paths;
      paths.forEach((key, value) {
        print("$key : $value");
      });
      Navigator.of(context).pushNamed(
        PostImage.routeName,
        arguments: ImagePost(paths: paths),
      );
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  showAlertDailogBox(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Center(
            child: Text("Menu"),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.add),
                title: Text("Add new post"),
                onTap: () => openFileExplorer(context),
              ),
              ListTile(
                leading: Icon(Icons.text_rotation_none),
                title: Text("Add new tweet"),
                onTap: () => Navigator.pushNamed(context, PostTweet.routeName),
              ),
              ListTile(
                leading: Icon(Icons.poll),
                title: Text("Add new Poll"),
                onTap: () => Navigator.pushNamed(context, PostPolls.routeName),
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text("Add new Pdf"),
                onTap: () => openPdfExplorer(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<DocumentSnapshot> getProfileInfo(String user_id) async {
    List<DocumentSnapshot> documentList =
        (await Firestore.instance //search for the userid in User node
                .collection("Users")
                .where("user_id", isEqualTo: user_id)
                .getDocuments())
            .documents;
    return documentList[0];
  }

  Future<void> likeThePost(String postType, bool isAlreadyLiked, String userId,
      String postNo, int likes_count) async {
    UserMaintainer userMaintainer = UserMaintainer();
    String currentUserId = await userMaintainer.getUserId();
    if (isAlreadyLiked) {
      await Firestore.instance
          .collection(postType)
          .document(postNo)
          .updateData({
        "likes_count": likes_count - 1,
        "likes": FieldValue.arrayRemove([currentUserId])
      });
    } else {
      await Firestore.instance
          .collection(postType)
          .document(postNo)
          .updateData({
        "likes_count": likes_count + 1,
        "likes": FieldValue.arrayUnion([currentUserId])
      });
    }
  }

  Future<void> addComment(
      String postType,
      String comment,
      Map<String, dynamic> comments,
      String username,
      String userId,
      String postNo) async {
    print("Reached here");
    if (comments == null) {
      comments = Map<String, dynamic>();
    }
    String name = await userMaintainer.getUserName();
    comments[name] = comment;
    await Firestore.instance
        .collection(postType)
        .document(postNo)
        .updateData({"Comments": comments});
    userMaintainer.showToast("Comment Added");
  }

  Future<void> sharePost(String postType, String userId, String postNo) async {
    Map<String, String> postInfo = Map<String, String>();
    postInfo["post_type"] = postType;
    postInfo["post_id"] = postNo;
    String link = await dynamicLinksService.createDynamicLink(postInfo);
    Share.share(link,
        subject: "Hey Look, I found this interesting post on My App");
  }
}

class Manual extends StatelessWidget {
  final String screen;
  Manual({this.screen});
  Color homeColor = Colors.black,
      searchColor = Colors.black,
      profileColor = Colors.black;
  CommonWidgets commonWidgets = CommonWidgets();
  @override
  Widget build(BuildContext context) {
    switch (screen) {
      case "home":
        homeColor = Colors.teal;
        break;
      case "search":
        searchColor = Colors.teal;
        break;
      case "profile":
        profileColor = Colors.teal;
        break;
      default:
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70,
      color: Colors.white.withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, HomeScreen.routeName);
            },
            color: homeColor,
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.pushReplacementNamed(context, SearchScreen.routeName);
            },
            color: searchColor,
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () => commonWidgets.showAlertDailogBox(context),
            color: Colors.black,
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, UserProfile.routeName);
            },
            child: SvgPicture.asset(
              "assets/img/user(0).svg",
              height: 18,
              width: 18,
              color: profileColor,
            ),
          )
        ],
      ),
    );
  }
}

class LikeButton extends StatelessWidget {
  final CommonWidgets commonWidgets = CommonWidgets();
  final bool isAlreadyLiked;
  final String userId, postNo, postType;
  final int likes_count;

  LikeButton(
      {this.postType,
      this.isAlreadyLiked,
      this.likes_count,
      this.postNo,
      this.userId});

  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
      label: Text(likes_count.toString()),
      icon: Icon(
        isAlreadyLiked ? Icons.favorite : Icons.favorite_border,
        color: isAlreadyLiked ? Colors.red : Colors.black,
      ),
      onPressed: () {
        commonWidgets.likeThePost(
            postType, isAlreadyLiked, userId, postNo, likes_count);
      },
    );
  }
}

class CommentList extends StatelessWidget {
  final List<String> comment, commenter;

  CommentList({this.comment, this.commenter});

  @override
  Widget build(BuildContext context) {
    return commenter != null
        ? ListView.builder(
            shrinkWrap: true,
            itemBuilder: (ctx, i) {
              return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 2.5,
                  ),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: "${commenter[i]}:  ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: "${comment[i]}",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ]),
                  ));
            },
            itemCount: commenter.length,
          )
        : Text("No Commnets");
  }
}

// POST OWNER SECTION

class PostOwnerDetails extends StatelessWidget {
  PostOwnerDetails({
    @required this.user_id,
    @required this.avatar,
    @required this.username,
  });

  final String avatar;
  final String user_id;
  final String username;

  UserMaintainer userMaintainer = UserMaintainer();
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () async {
          String userid = await userMaintainer.getUserId();
          userid != user_id
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => VisitProfile(
                      visitorId: user_id,
                    ),
                  ),
                )
              : Navigator.pushReplacementNamed(context, UserProfile.routeName);
        },
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: avatar,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              username,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
    );
  }
}
