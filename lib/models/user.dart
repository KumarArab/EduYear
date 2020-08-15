class User {
  String uid;
  String username;
  String emailId;
  List<String> posts;
  int followers;
  int followings;
  int noOfPost;

  User(
      {this.uid,
      this.username,
      this.emailId,
      this.posts,
      this.followers,
      this.followings,
      this.noOfPost});
}
