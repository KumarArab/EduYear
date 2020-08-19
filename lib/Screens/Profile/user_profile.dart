import 'package:app/Provider/login_store.dart';
import 'package:app/Screens/Profile/profile_posts.dart';
import 'package:app/helpers/common_widgets.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatefulWidget {
  static const String routeName = "/user-profile";

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Map<String, String> _userProfile = Map<String, String>();
  bool isLoading;
  UserMaintainer userMaintainer = UserMaintainer();
  int imagePostCount = 0,
      tweetPostCount = 0,
      pollPostCount = 0,
      docPostCount = 0,
      subscribedCount = 0;

  @override
  void didChangeDependencies() async {
    await fetchUserDetails();
    // int tempImageCount = await userMaintainer.countImagePost();

    int tempTweetCount = await userMaintainer.countTweetPost();
    int tempPollCount = await userMaintainer.countPollPost();
    int tempDocCount = await userMaintainer.countDocPost();
    if (mounted) {
      setState(() {
        // imagePostCount = tempImageCount;
        tweetPostCount = tempTweetCount;
        pollPostCount = tempPollCount;
        docPostCount = tempDocCount;
      });
    }

    super.didChangeDependencies();
  }

  Future<void> fetchUserDetails() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userProfile["uid"] = prefs.getString("uid");
    _userProfile["name"] = prefs.getString("name");
    _userProfile["imageUrl"] = prefs.getString("profile_pic");
    subscribedCount = prefs.getStringList("subscribed").length;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: isLoading
            ? CircularProgressIndicator()
            : Text(
                _userProfile["name"],
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert,
            ),
          )
        ],
      ),
      bottomNavigationBar: Manual(screen: "profile"),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.height * 0.2,
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: _userProfile["imageUrl"] != null
                    ? Image.network(_userProfile["imageUrl"])
                    : SvgPicture.asset(
                        "assets/img/user(0).svg",
                        color: Colors.grey,
                      ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 30),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/img/stack-overflow.svg",
                          color: Colors.black,
                          height: 30,
                          width: 30,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        SvgPicture.asset(
                          "assets/img/instagram.svg",
                          color: Colors.black,
                          height: 30,
                          width: 30,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        SvgPicture.asset(
                          "assets/img/github.svg",
                          color: Colors.black,
                          height: 30,
                          width: 30,
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: ListView(
                          children: [
                            ListTile(
                              title: Text("Images"),
                              trailing: Text(imagePostCount.toString()),
                              onTap: () => imagePostCount != 0
                                  ? Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ProfilePost(type: "Image-Posts"),
                                      ),
                                    )
                                  : {},
                            ),
                            ListTile(
                              title: Text("Tweets"),
                              trailing: Text(tweetPostCount.toString()),
                            ),
                            ListTile(
                              title: Text("Polls"),
                              trailing: Text(pollPostCount.toString()),
                            ),
                            ListTile(
                              title: Text("Docs"),
                              trailing: Text(docPostCount.toString()),
                            ),
                            ListTile(
                              title: Text("Subscribed"),
                              trailing: Text(subscribedCount.toString()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: FlatButton(
                        onPressed: () {
                          Provider.of<LoginStore>(context, listen: false)
                              .signOut(context);
                        },
                        child: Text("SignOut",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
