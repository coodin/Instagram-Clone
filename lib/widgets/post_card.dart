import 'package:flutter/material.dart';
//import 'package:instagram/models/comment.dart';
import 'package:instagram/providers/user_provider.dart';
import 'package:instagram/resources/firestore_methods.dart';
import 'package:instagram/screens/comments_screen.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/utils/global_variables.dart';
import 'package:instagram/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/post_provider.dart';
import 'like_animation.dart';

class PostCard extends StatefulWidget {
  final Post post;
  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  @override
  void initState() {
    super.initState();
    //getCommentsLength();
  }

  // void getCommentsLength() async {
  //   var postProvider = context.read<PostProvider>();
  //   var res = await postProvider.getCommentLength(widget.post.postId);
  //   if (res == "Success") {
  //   } else {
  //     showSnacbar(context, res);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          // HEADER SECTION
          PostHeader(profImage: widget.post.profImage, userName: widget.post.userName, postId: widget.post.postId),
          // IMAGE SECTİON
          Selector<UserProvider, String>(
            selector: (context, provider) => provider.getUser.uid,
            builder: (_, uid, __) {
              return GestureDetector(
                onDoubleTap: () async {
                  await FirestoreMethods().likePost(
                    widget.post.postId,
                    uid,
                    widget.post.likes,
                  );
                  setState(() {
                    isLikeAnimating = true;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.350,
                      width: double.infinity,
                      child: Image.network(
                        widget.post.postUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isLikeAnimating ? 1 : 0,
                      child: LikeAnimation(
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 120,
                        ),
                        isAnimating: isLikeAnimating,
                        duration: const Duration(milliseconds: 400),
                        onEnd: () {
                          setState(
                            () {
                              isLikeAnimating = false;
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          ),
          // LIKE COMMENT SECTİON
          LikeAndComment(
            post: widget.post,
          ),
          // DESCRİPTION AND NUMBER OF COMMENTS
          FutureBuilder<int>(
            future: context.read<PostProvider>().getCommentLength(widget.post.postId),
            builder: (context, snapshot) {
              return PostFooter(
                  description: widget.post.description,
                  likes: widget.post.likes.length,
                  postDate: widget.post.datePublished,
                  userName: widget.post.userName,
                  commentLengthSnap: snapshot,
                  post: widget.post);
            },
          ),
        ],
      ),
    );
  }
}

class PostFooter extends StatelessWidget {
  final int likes;
  final String userName;
  final String description;
  final DateTime postDate;
  final Post post;
  final AsyncSnapshot<int> commentLengthSnap;
  const PostFooter(
      {Key? key,
      required this.likes,
      required this.userName,
      required this.description,
      required this.postDate,
      required this.post,
      required this.commentLengthSnap})
      : super(key: key);

  String getComment(AsyncSnapshot<int> snap) {
    String value = "";
    if (snap.hasData) {
      if (snap.data! > 0) {
        value = "View all ${commentLengthSnap.data!} comments";
      } else {
        value = "There is no comment";
      }
    } else {
      value = "There is no comment";
    }
    if (snap.hasError) {
      value = snap.error.toString();
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: Column(
        //mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextStyle(
            style: Theme.of(context).textTheme.subtitle2!.copyWith(fontWeight: FontWeight.w800),
            child: Text(
              "${likes} likes",
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          Container(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: primaryColor),
                children: [
                  TextSpan(
                    text: userName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: "  ${description}"),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CommentsScreen(
                    post: post,
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                getComment(commentLengthSnap),
                style: const TextStyle(fontSize: 16, color: secondaryColor),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              //This is the same thing except this one using explicit pattern
              //DateFormat("dd/MM/yyyy").format(postDate),
              DateFormat.yMMMd().format(postDate),
              style: const TextStyle(fontSize: 16, color: secondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class LikeAndComment extends StatelessWidget {
  final Post post;
  const LikeAndComment({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Consumer<UserProvider>(
          builder: (_, userPro, __) {
            return LikeAnimation(
              isAnimating: post.likes.contains(userPro.getUser.uid),
              smallLike: true,
              child: IconButton(
                onPressed: () async {
                  await FirestoreMethods().likePost(
                    post.postId,
                    userPro.getUser.uid,
                    post.likes,
                  );
                },
                icon: post.likes.contains(userPro.getUser.uid)
                    ? Icon(
                        Icons.favorite,
                        color: Colors.red,
                      )
                    : Icon(Icons.favorite_border),
                //color: Colors.red,
              ),
            );
          },
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CommentsScreen(
                  post: post,
                ),
              ),
            );
          },
          icon: Icon(Icons.comment_outlined),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.send),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.bookmark_border),
            ),
          ),
        ),
      ],
    );
  }
}

class PostHeader extends StatelessWidget {
  final String profImage;
  final String userName;
  final String postId;
  const PostHeader({Key? key, required this.profImage, required this.userName, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16).copyWith(right: 0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
              profImage,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shrinkWrap: true,
                    children: ["Delete"]
                        .map(
                          (value) => InkWell(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              child: Text(value),
                            ),
                            onTap: () async {
                              var res = await context.read<PostProvider>().deletePost(postId);
                              Navigator.of(context).pop();
                              if (res == "Success") {
                                showSnacbar(context, "Post have deleted");
                              } else {
                                showSnacbar(context, res);
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.more_vert),
          )
        ],
      ),
    );
  }
}
