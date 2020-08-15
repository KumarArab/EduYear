import 'package:app/Provider/login_store.dart';
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

  @override
  void didChangeDependencies() async {
    await fetchUserDetails();
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
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: isLoading
            ? CircularProgressIndicator()
            : Text(_userProfile["name"]),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert,
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.height * 0.2,
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
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
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    FlatButton(
                      onPressed: () {
                        Provider.of<LoginStore>(context, listen: false)
                            .signOut(context);
                      },
                      child: Text("SignOut"),
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
