import 'package:app/Login-System/get-details.dart';
import 'package:app/Provider/login_store.dart';
import 'package:app/Screens/Home%20Views/docs_view.dart';
import 'package:app/Screens/Home%20Views/image_view.dart';
import 'package:app/Screens/Home%20Views/poll_view.dart';
import 'package:app/Screens/Home%20Views/tweet_view.dart';
import 'package:app/Screens/Profile/edit_profile.dart';
import 'package:app/Screens/Profile/subscribed_list.dart';
import 'package:app/helpers/common_widgets.dart';
import 'package:app/helpers/user_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatelessWidget {
  static const String routeName = "/user-profile";

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context, listen: false);
    return Scaffold(
      bottomNavigationBar: Manual(screen: "profile"),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    userData.imageUrl,
                  ),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.width * 0.45,
                      width: MediaQuery.of(context).size.width * 0.45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            blurRadius: 3,
                            color: Colors.black.withOpacity(0.4),
                            offset: Offset(2, 3),
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: userData.imageUrl != null
                            ? Image.network(
                                userData.imageUrl,
                                fit: BoxFit.cover,
                              )
                            : SvgPicture.asset(
                                "assets/img/user(0).svg",
                                color: Colors.grey,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userData.username,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        userData.isVerified
                            ? SvgPicture.asset(
                                "assets/img/verified.svg",
                                height: 20,
                                width: 20,
                              )
                            : Container(),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                userData.totalPostCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24,
                                ),
                              ),
                              Text(
                                "Posts",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                          VerticalDivider(
                            color: Colors.white,
                            thickness: 1,
                            width: 30,
                          ),
                          Column(
                            children: [
                              Text(
                                userData.followersCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24,
                                ),
                              ),
                              Text(
                                "Followers",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                          VerticalDivider(
                            color: Colors.white,
                            thickness: 1,
                            width: 30,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => SubscribedList(
                                    subscribedList: userData.subscriberList,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Text(
                                  userData.followingCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                  ),
                                ),
                                Text(
                                  "Followings",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: FlatButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, EditProfile.routeName);
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        label: Text(
                          "EDIT",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(top: 20, left: 20, right: 10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bio:",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        userData.bio,
                        textAlign: TextAlign.left,
                        maxLines: 4,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Posts:",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.image,
                              color: Colors.teal,
                            ),
                            title: Text("Images"),
                            trailing: Text(userData.imagePostCount.toString()),
                            onTap: () => userData.imagePostCount != 0
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ImageSection(
                                        query: Firestore
                                            .instance //search for the userid in User node
                                            .collection("Image-Posts")
                                            .where("user_id",
                                                isEqualTo:
                                                    userData.currentUserId)
                                            .snapshots(),
                                      ),
                                    ),
                                  )
                                : {},
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.message,
                              color: Colors.teal,
                            ),
                            title: Text("Tweets"),
                            trailing: Text(userData.tweetPostCount.toString()),
                            onTap: () => userData.tweetPostCount != 0
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TweetSection(
                                        query: Firestore
                                            .instance //search for the userid in User node
                                            .collection("Tweet-Posts")
                                            .where("user_id",
                                                isEqualTo:
                                                    userData.currentUserId)
                                            .snapshots(),
                                      ),
                                    ),
                                  )
                                : {},
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.poll,
                              color: Colors.teal,
                            ),
                            title: Text("Polls"),
                            trailing: Text(userData.pollPostCount.toString()),
                            onTap: () => userData.pollPostCount != 0
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PollSection(
                                        query: Firestore
                                            .instance //search for the userid in User node
                                            .collection("Poll-Posts")
                                            .where("user_id",
                                                isEqualTo:
                                                    userData.currentUserId)
                                            .snapshots(),
                                      ),
                                    ),
                                  )
                                : {},
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.picture_as_pdf,
                              color: Colors.teal,
                            ),
                            title: Text("Pdfs"),
                            trailing: Text(userData.docPostCount.toString()),
                            onTap: () => userData.docPostCount != 0
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DocsSection(
                                        query: Firestore
                                            .instance //search for the userid in User node
                                            .collection("Doc-Posts")
                                            .where("user_id",
                                                isEqualTo:
                                                    userData.currentUserId)
                                            .snapshots(),
                                      ),
                                    ),
                                  )
                                : {},
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
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );

    // Scaffold(
    //   appBar: AppBar(
    //     elevation: 0,
    //     backgroundColor: Colors.white,
    //     title: Text(
    //       userData.username,
    //       style: TextStyle(
    //         color: Colors.black,
    //       ),
    //     ),
    //     actions: [
    //       FlatButton.icon(
    //         onPressed: () {},
    //         icon: Icon(
    //           Icons.edit,
    //         ),
    //         label: Text("Edit"),
    //       )
    //     ],
    //   ),
    //   bottomNavigationBar: Manual(screen: "profile"),
    //   body: Container(
    //     width: double.infinity,
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         Container(
    //           height: MediaQuery.of(context).size.height * 0.2,
    //           width: MediaQuery.of(context).size.height * 0.2,
    //           margin: EdgeInsets.all(20),
    //           decoration: BoxDecoration(
    //             shape: BoxShape.circle,
    //             color: Colors.white,
    //           ),
    //           child: ClipRRect(
    //             borderRadius: BorderRadius.circular(100),
    //             child: userData.imageUrl != null
    //                 ? CachedNetworkImage(
    //                     imageUrl: userData.imageUrl,
    //                     placeholder: (context, url) => Center(
    //                       child: CircularProgressIndicator(
    //                         strokeWidth: 1,
    //                       ),
    //                     ),
    //                     fit: BoxFit.cover,
    //                     errorWidget: (context, url, error) => Icon(Icons.error),
    //                   )
    //                 : SvgPicture.asset(
    //                     "assets/img/user(0).svg",
    //                     color: Colors.grey,
    //                   ),
    //           ),
    //         ),
    //         Expanded(
    //           child: Container(
    //             padding: EdgeInsets.only(top: 30),
    //             child: Column(
    //               children: [
    //                 // Row(
    //                 //   mainAxisAlignment: MainAxisAlignment.center,
    //                 //   children: [
    //                 //     SvgPicture.asset(
    //                 //       "assets/img/stack-overflow.svg",
    //                 //       color: Colors.black,
    //                 //       height: 30,
    //                 //       width: 30,
    //                 //     ),
    //                 //     SizedBox(
    //                 //       width: 20,
    //                 //     ),
    //                 //     SvgPicture.asset(
    //                 //       "assets/img/instagram.svg",
    //                 //       color: Colors.black,
    //                 //       height: 30,
    //                 //       width: 30,
    //                 //     ),
    //                 //     SizedBox(
    //                 //       width: 20,
    //                 //     ),
    //                 //     SvgPicture.asset(
    //                 //       "assets/img/github.svg",
    //                 //       color: Colors.black,
    //                 //       height: 30,
    //                 //       width: 30,
    //                 //     ),
    //                 //   ],
    //                 // ),
    //                 Expanded(
    //                   child: Container(
    //                     padding: EdgeInsets.all(20),
    //                     child: ListView(
    //                       children: [
    //                         ListTile(
    //                           title: Text("Images"),
    //                           trailing:
    //                               Text(userData.imagePostCount.toString()),
    //                           onTap: () => userData.imagePostCount != 0
    //                               ? Navigator.push(
    //                                   context,
    //                                   MaterialPageRoute(
    //                                     builder: (_) => ImageSection(
    //                                       query: Firestore
    //                                           .instance //search for the userid in User node
    //                                           .collection("Image-Posts")
    //                                           .where("user_id",
    //                                               isEqualTo:
    //                                                   userData.currentUserId)
    //                                           .snapshots(),
    //                                     ),
    //                                   ),
    //                                 )
    //                               : {},
    //                         ),
    //                         ListTile(
    //                           title: Text("Tweets"),
    //                           trailing:
    //                               Text(userData.tweetPostCount.toString()),
    //                           onTap: () => userData.tweetPostCount != 0
    //                               ? Navigator.push(
    //                                   context,
    //                                   MaterialPageRoute(
    //                                     builder: (_) => TweetSection(
    //                                       query: Firestore
    //                                           .instance //search for the userid in User node
    //                                           .collection("Tweet-Posts")
    //                                           .where("user_id",
    //                                               isEqualTo:
    //                                                   userData.currentUserId)
    //                                           .snapshots(),
    //                                     ),
    //                                   ),
    //                                 )
    //                               : {},
    //                         ),
    //                         ListTile(
    //                           title: Text("Polls"),
    //                           trailing: Text(userData.pollPostCount.toString()),
    //                           onTap: () => userData.pollPostCount != 0
    //                               ? Navigator.push(
    //                                   context,
    //                                   MaterialPageRoute(
    //                                     builder: (_) => PollSection(
    //                                       query: Firestore
    //                                           .instance //search for the userid in User node
    //                                           .collection("Poll-Posts")
    //                                           .where("user_id",
    //                                               isEqualTo:
    //                                                   userData.currentUserId)
    //                                           .snapshots(),
    //                                     ),
    //                                   ),
    //                                 )
    //                               : {},
    //                         ),
    //                         ListTile(
    //                           title: Text("Docs"),
    //                           trailing: Text(userData.docPostCount.toString()),
    //                           onTap: () => userData.docPostCount != 0
    //                               ? Navigator.push(
    //                                   context,
    //                                   MaterialPageRoute(
    //                                     builder: (_) => DocsSection(
    //                                       query: Firestore
    //                                           .instance //search for the userid in User node
    //                                           .collection("Doc-Posts")
    //                                           .where("user_id",
    //                                               isEqualTo:
    //                                                   userData.currentUserId)
    //                                           .snapshots(),
    //                                     ),
    //                                   ),
    //                                 )
    //                               : {},
    //                         ),
    //                         ListTile(
    //                           title: Text("Subscribed"),
    //                           trailing: Text(
    //                               userData.subscriberList.length.toString()),
    //                           onTap: () => Navigator.push(
    //                             context,
    //                             MaterialPageRoute(
    //                               builder: (ctx) => SubscribedList(
    //                                 subscribedList: userData.subscriberList,
    //                               ),
    //                             ),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    // Container(
    //   width: MediaQuery.of(context).size.width,
    //   child: FlatButton(
    //     onPressed: () {
    //       Provider.of<LoginStore>(context, listen: false)
    //           .signOut(context);
    //     },
    //     child: Text("SignOut",
    //         style: TextStyle(
    //           fontWeight: FontWeight.w700,
    //           fontSize: 20,
    //         )),
    //   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         )
    //       ],
    //     ),
    //   ),
    // );
  }
}
