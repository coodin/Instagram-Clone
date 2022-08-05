import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../resources/firestore_methods.dart';

class SearchProvider with ChangeNotifier {
  final FirestoreMethods _firestoreMethods = FirestoreMethods();

  Stream<List<User>>? _searchUsers;
  Stream<List<User>>? get getSearchUsers => _searchUsers;

  void getUserUsingSearch(String userName) {
    ///print("usernamea: $userName");
    _searchUsers = _firestoreMethods.getUserUsingSearch(userName);
    notifyListeners();
  }
}
