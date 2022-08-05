//import 'dart:developer';
//import 'dart:ffi';
// import 'dart:ffi';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as model;
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    //print("Current Uid: " + currentUser.uid);
    DocumentSnapshot snap =
        await _firestore.collection("users").doc(currentUser.uid).get();
    //print(snap.data());

    return model.User.fromSnap(snap);
  }

  String currentUserUid() {
    return _auth.currentUser?.uid ?? "";
  }

  //sign up
  Future<String> signUpUser({
    required String email,
    required String password,
    required String userName,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          userName.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        // register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage("profilePics", file, false);

        model.User user = model.User(
          email: email,
          bio: bio,
          followers: [],
          following: [],
          photoUrl: photoUrl,
          uid: cred.user!.uid,
          userName: userName,
        );

        // add user to our database
        await _firestore
            .collection("users")
            .doc(cred.user!.uid)
            .set(user.toJson());
        res = "Success";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  //log in
  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "Success";
      } else {
        res = "Please fill all the fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> logOutUser() async {
    return await _auth.signOut();
  }
}
