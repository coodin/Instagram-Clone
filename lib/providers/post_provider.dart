import 'package:flutter/cupertino.dart';
import 'package:instagram/models/comment.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../resources/firestore_methods.dart';

class PostProvider with ChangeNotifier {
  final FirestoreMethods _firestoreMethods = FirestoreMethods();

  Stream<List<Comment>>? _comments;
  Stream<List<Comment>>? get getComments => _comments;

  Stream<List<Post>>? _allPosts;
  Stream<List<Post>>? get getAllPosts => _allPosts!;

  // Future<List<Post>>? _posts;
  // Future<List<Post>>? get getPosts => _posts;

  // Stream<List<User>>? _searchUsers;
  // Stream<List<User>>? get getSearchUsers => _searchUsers;

  int commentsLenght = 0;

  Future<void> getPostComments(String postId) async {
    var comments = await _firestoreMethods.getPostComments(postId);
    // print("comments from post_provider ${comments}");
    _comments = comments;
    notifyListeners();
  }

  Future<String> getWholePosts() async {
    String res = "Some error occured";
    try {
      var posts = _firestoreMethods.getAllPosts();
      _allPosts = posts;
      res = "Sucess";
    } catch (e) {
      res = e.toString();
    }
    //notifyListeners();
    return res;
  }

  Future<int> getCommentLength(String postId) async {
    var snap = await _firestoreMethods.getCommentLength(postId);
    var value = snap.docs.length;
    return value;
  }

  Future<String> deletePost(String postId) async {
    String res = "Some error happened";
    try {
      await _firestoreMethods.deletePost(postId);
      throw res = "Success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<int> getPostsLength(String uid) async {
    var posts = await _firestoreMethods.getSpecificPosts(uid);
    return posts.length;
  }

  Future<List<Post>> getSpecificPosts(String uid) async {
    var posts = await _firestoreMethods.getSpecificPosts(uid);
    return posts;
  }

  // void getUserUsingSearch(String userName) {
  //   ///print("usernamea: $userName");
  //   _searchUsers = _firestoreMethods.getUserUsingSearch(userName);
  //   notifyListeners();
  // }
}
