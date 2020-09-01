import 'package:flutter/cupertino.dart';

class UserActivity with ChangeNotifier {
  List<String> searchString;

  createSearchList(String searchText) {
    searchString = searchText.split(" ");
    for (int i = 0; i < searchString.length; i++) {
      searchString[i] = searchString[i].toLowerCase();
    }
    notifyListeners();
  }

  clearSearchLists() {
    searchString = null;
    notifyListeners();
  }
}
