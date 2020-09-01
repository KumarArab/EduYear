import 'package:app/Screens/shared-post.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DynamicLinksService {
  Future handleDynamicLinks(BuildContext context) async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    _handleDynamicLink(data, context);

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLinkData) async {
      _handleDynamicLink(dynamicLinkData, context);
    }, onError: (OnLinkErrorException error) async {
      print("Dynamic Link Failed: ${error.message}");
      print(error.toString());
    });
  }

  void _handleDynamicLink(PendingDynamicLinkData data, BuildContext context) {
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      print("_handleDynamicLink | deepLink: $deepLink");
      if (deepLink.pathSegments.contains("Image-Posts")) {
        var title = deepLink.queryParameters['postId'];
        if (title != null) {
          print(title);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => SharedPost(
                postId: title,
                postType: "Image-Posts",
              ),
            ),
          );
        }
      } else if (deepLink.pathSegments.contains("Poll-Posts")) {
        var title = deepLink.queryParameters['postId'];
        if (title != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => SharedPost(
                postId: title,
                postType: "Poll-Posts",
              ),
            ),
          );
        }
      } else if (deepLink.pathSegments.contains("Tweet-Posts")) {
        var title = deepLink.queryParameters['postId'];
        if (title != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => SharedPost(
                postId: title,
                postType: "Tweet-Posts",
              ),
            ),
          );
        }
      } else if (deepLink.pathSegments.contains("Doc-Posts")) {
        var title = deepLink.queryParameters['postId'];
        if (title != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => SharedPost(
                postId: title,
                postType: "Doc-Posts",
              ),
            ),
          );
        }
      }
    }
  }

  Future<String> createDynamicLink(Map<String, String> postInfo) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: "https://incognitostartups.page.link",
      link: Uri.parse(
          "https://www.clientauth.com/${postInfo["post_type"]}?postId=${postInfo["post_id"]}"),
      androidParameters: AndroidParameters(packageName: "com.example.app"),
    );

    final Uri dynamicUrl = await parameters.buildUrl();
    return dynamicUrl.toString();
  }
}
