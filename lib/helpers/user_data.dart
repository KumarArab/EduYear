import 'package:flutter/cupertino.dart';

class UserData with ChangeNotifier {
  static String _uid;
  static String _username;
  static String _imageUrl;

  setUid(String uid) {
    _uid = uid;
    notifyListeners();
  }

  setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  setImagenUrl(String imageUrl) {
    _imageUrl = imageUrl;
    notifyListeners();
  }

  getUid() {
    String uid = _uid;
    return uid;
  }

  getUsername() {
    String username = _username;
    return username;
  }

  getImageUrl() {
    String imageUrl = _imageUrl;
    return imageUrl;
  }
}
