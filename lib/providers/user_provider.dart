import 'package:flutter/cupertino.dart';
import 'package:instagram/resources/auth_methods.dart';
import 'package:instagram/resources/firestore_methods.dart';

import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  User get getUser => _user!;
  Stream<User>? _eitherOfScreens;
  Stream<User>? get getEitherOfScreens => _eitherOfScreens;
  final AuthMethods _authMethods = AuthMethods();
  final FirestoreMethods _firestore = FirestoreMethods();
  String get getUserUid => _authMethods.currentUserUid();

  bool waitingUserDetail = true;

  Future<void> refreshUser() async {
    waitingUserDetail = true;
    User user = await _authMethods.getUserDetails();
    _user = user;
    waitingUserDetail = false;
    notifyListeners();
  }

  Future<void> getUserEitherOfScreens(String uid) async {
    var user = await _firestore.getUser(uid);
    _eitherOfScreens = user;
    notifyListeners();
  }

  Future<void> followUser(String uid, String followId) async {
    await _firestore.followUser(uid, followId);
    notifyListeners();
  }

  Future<void> logOut() async {
    await _authMethods.logOutUser();
    notifyListeners();
  }
}
