import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/models/comment.dart';
import 'package:instagram/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

import '../models/post.dart';
import '../models/user.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPhoto(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "Some error occured";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage("posts", file, true);
      String postId = const Uuid().v1();
      Post post = Post(
        description: description,
        uid: uid,
        userName: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        likes: [],
      );

      _firestore.collection("posts").doc(postId).set(post.toJson());
      res = "Success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection("posts").doc(postId).update(
          {
            "likes": FieldValue.arrayRemove([uid]),
          },
        );
      } else {
        await _firestore.collection("posts").doc(postId).update(
          {
            "likes": FieldValue.arrayUnion([uid]),
          },
        );
      }
    } catch (e) {}
  }

  Future<String> addComment(
    String postId,
    String uid,
    String userName,
    String description,
    String profImage,
  ) async {
    String res = "Something went wrong";

    if (description.isNotEmpty) {
      String commentId = const Uuid().v1();
      final newComment = Comment(
        uid: uid,
        userName: userName,
        description: description,
        commentID: commentId,
        likes: 0,
        datePublis: DateTime.now(),
        profImage: profImage,
      );
      try {
        await _firestore
            .collection("posts")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .set(newComment.toJson());
        res = "Success";
      } catch (e) {
        res = e.toString();
      }
    }

    return res;
  }

  Stream<List<Comment>> getPostComments(String postId) {
    return _firestore
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .orderBy("datePublis", descending: true)
        .snapshots()
        .map(
          (event) => event.docs.map((e) => Comment.fromSnap(e)).toList(),
        );
  }

  Stream<List<Post>> getAllPosts() {
    return _firestore.collection("posts").snapshots().map(
          (event) => event.docs
              .map(
                (e) => Post.fromSnap(e),
              )
              .toList(),
        );
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCommentLength(
      String postId) async {
    return await _firestore
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .get();
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection("posts").doc(postId).delete();
  }

  Stream<List<User>> getUserUsingSearch(
    String userName,
  ) {
    print("usernamesss $userName");
    var user = _firestore
        .collection("users")
        .where("username", isGreaterThanOrEqualTo: userName)
        .snapshots();
    return user.map(
      (event) => event.docs
          .map(
            (data) => User.fromSnap(data),
          )
          .toList(),
    );
  }

  Stream<User> getUser(String uid) {
    var user = _firestore
        .collection("users")
        .doc(uid)
        .snapshots()
        .map((snap) => User.fromSnap(snap));
    return user;
  }

  Future<List<Post>> getSpecificPosts(String uid) async {
    var posts =
        await _firestore.collection("posts").where("uid", isEqualTo: uid).get();
    return posts.docs.map((event) => Post.fromSnap(event)).toList();
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      var snap = await _firestore.collection("users").doc(uid).get();
      var user = User.fromSnap(snap);
      if (user.following.contains(followId)) {
        await _firestore.collection("users").doc(uid).update({
          "following": FieldValue.arrayRemove([followId])
        });
        await _firestore.collection("users").doc(followId).update({
          "followers": FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection("users").doc(uid).update({
          "following": FieldValue.arrayUnion([followId])
        });
        await _firestore.collection("users").doc(followId).update({
          "followers": FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
