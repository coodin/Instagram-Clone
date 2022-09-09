import 'package:flutter/material.dart';
import 'package:instagram/providers/user_provider.dart';
import 'package:instagram/resources/firestore_methods.dart';
import 'package:instagram/utils/colors.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../utils/utils.dart';
import '../widgets/comment_card.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({Key? key, required this.post}) : super(key: key);
  final Post post;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text("Comments"),
        centerTitle: false,
      ),
      body: CommentCard(postId: widget.post.postId),
      // body: StreamProvider<List<Comment>?>(
      //   create: (_) {
      //     return PostProvider().getComments;
      //   },
      //   child: CommentCard(postId: widget.snap["postId"]),
      //   initialData: null,
      // ), //CommentCard(),
      bottomNavigationBar: BottomInput(context),
    );
  }

  SafeArea BottomInput(BuildContext context) {
    return SafeArea(
      child: Container(
        height: kToolbarHeight,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        padding: EdgeInsets.only(left: 16, right: 8),
        child: Row(
          children: [
            Consumer<UserProvider>(
              builder: (_, user, __) {
                return CircleAvatar(
                  backgroundImage: NetworkImage(
                    user.getUser.photoUrl,
                  ),
                  radius: 18,
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 8),
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: "Comments as username",
                  ),
                ),
              ),
            ),
            Consumer<UserProvider>(builder: (_, user, __) {
              return InkWell(
                onTap: () async {
                  String res = await FirestoreMethods().addComment(
                    widget.post.postId,
                    user.getUser.uid,
                    user.getUser.userName,
                    commentController.text,
                    user.getUser.photoUrl,
                  );
                  setState(() {
                    commentController.clear();
                  });
                  if (res == "Success") {
                    //commentController.clear();
                    showSnacbar(context, "Comment Posted");
                  } else {
                    showSnacbar(context, res);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: const Text(
                    "Post",
                    style: TextStyle(color: blueColor),
                  ),
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
