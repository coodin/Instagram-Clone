import 'package:flutter/material.dart';
import 'package:instagram/models/comment.dart';
import 'package:instagram/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

import '../providers/post_provider.dart';

class CommentCard extends StatefulWidget {
  final String postId;
  const CommentCard({Key? key, required this.postId}) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  void initState() {
    super.initState();
    getPostComments();
  }

  void getPostComments() async {
    final postProvider = context.read<PostProvider>();

    await postProvider.getPostComments(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();

    return StreamBuilder(
      stream: postProvider.getComments,
      builder: ((context, AsyncSnapshot<List<Comment>> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final comments = snapshot.data!;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return CommentLine(comments: comments, index: index);
                },
              ),
            );
          } else {
            return Container(
              child: Center(
                child: Text("There is no comment"),
              ),
            );
          }
        }
        if (snapshot.hasError) {
          return Container(
            child: Center(
              child: Text(
                snapshot.error.toString(),
              ),
            ),
          );
        }
        return Container(
          child: Center(
            child: CircularProgressIndicator(color: primaryColor),
          ),
        );
      }),
    );
  }
}

class CommentLine extends StatelessWidget {
  // bool isExpanded = false;
  const CommentLine({
    Key? key,
    required this.comments,
    required this.index,
  }) : super(key: key);

  final List<Comment> comments;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              comments[index].profImage,
            ),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Text(
                              comments[index].userName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        WidgetSpan(
                          child: ReadMoreText(
                            //"asddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd",
                            comments[index].description,
                            trimLines: 3,
                            trimMode: TrimMode.Line,
                            colorClickableText: Colors.red,
                            trimExpandedText: "",
                            trimCollapsedText: " ",
                            style: TextStyle(fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat.yMMMd().format(comments[index].datePublis),
                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: const Icon(
              Icons.favorite,
              size: 16,
            ),
          )
        ],
      ),
    );
  }
}
