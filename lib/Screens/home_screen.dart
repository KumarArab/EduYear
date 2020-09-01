import 'package:app/Screens/Home%20Views/docs_view.dart';
import 'package:app/Screens/Home%20Views/image_view.dart';
import 'package:app/Screens/Home%20Views/poll_view.dart';
import 'package:app/Screens/Home%20Views/tweet_view.dart';
import 'package:app/Screens/banners.dart';
import 'package:app/helpers/common_widgets.dart';
import 'package:app/helpers/handle_dynamicLinks.dart';
import 'package:app/helpers/user_data.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserMaintainer userMaintainer = UserMaintainer();
  DynamicLinksService dynamicLinksService = DynamicLinksService();

  PageController _controller = PageController(
    initialPage: 0,
  );

  bool pop = false;

  @override
  void didChangeDependencies() async {
    Provider.of<UserData>(context, listen: false).setuserData();
    Provider.of<UserData>(context, listen: false).setSubscriberList();
    await dynamicLinksService.handleDynamicLinks(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    return WillPopScope(
      onWillPop: () async {
        if (!pop) {
          userMaintainer.showToast("Back press once more to exit");
          pop = true;
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            "EDUYEAR",
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.bookmark, color: Colors.teal),
              onPressed: () {
                Navigator.pushNamed(context, Banners.routeName);
              },
            ),
          ],
        ),
        bottomNavigationBar: Manual(
          screen: "home",
        ),
        body: PageView(
          controller: _controller,
          onPageChanged: (val) {
            pop = false;
          },
          children: [
            ImageSection(
              query: Firestore.instance
                  .collection("Image-Posts")
                  .where("user_id", whereIn: userData.subscriberList)
                  .snapshots(),
            ),
            TweetSection(
              query: Firestore.instance
                  .collection("Tweet-Posts")
                  .where("user_id", whereIn: userData.subscriberList)
                  .snapshots(),
            ),
            PollSection(
              query: Firestore.instance
                  .collection("Poll-Posts")
                  .where("user_id", whereIn: userData.subscriberList)
                  .snapshots(),
            ),
            DocsSection(
              query: Firestore.instance
                  .collection("Doc-Posts")
                  .where("user_id", whereIn: userData.subscriberList)
                  .snapshots(),
            ),
          ],
        ),
      ),
    );
  }
}

// Positioned(
//   right: 20,
//   top: 40,
//   child: CircleAvatar(
//     backgroundColor: Colors.black,
//     radius: 25,
//     child: Padding(
//       padding: EdgeInsets.all(10),
//       child: GestureDetector(
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (ctx) => UserProfile(),
//           ),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(100),
//           child: SvgPicture.asset(
//             "assets/img/user(0).svg",
//             color: Colors.grey,
//             fit: BoxFit.cover,
//           ),
//         ),
//       ),
//     ),
//   ),
// )
