import "package:flutter/material.dart";
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/models/post.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/utils/global_variables.dart';
import 'package:instagram/widgets/post_card.dart';
import 'package:provider/provider.dart';

import '../providers/post_provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    getAllPosts();
  }

  void getAllPosts() async {
    var postProvider = context.read<PostProvider>();
    await postProvider.getWholePosts();
  }

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostProvider>();
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: width > webScreenSize
                  ? webBackgroundColor
                  : mobileBackgroundColor,
              centerTitle: false,
              title: SvgPicture.asset(
                "assets/ic_instagram.svg",
                color: primaryColor,
                height: 32,
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.messenger_outline),
                ),
              ],
            ),
      body: StreamBuilder(
        stream: posts.getAllPosts,
        builder: (context, AsyncSnapshot<List<Post>> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: width > webScreenSize ? width * 0.3 : 0,
                      vertical: width > webScreenSize ? 15 : 0,
                    ),
                    child: PostCard(
                      post: snapshot.data![index],
                    ),
                  );
                },
              );
            } else {
              return Container(
                child: Center(
                  child: Text("There is no data"),
                ),
              );
            }
          }
          if (snapshot.hasError) {
            return Container(
              child: Center(
                child: Text(snapshot.error.toString()),
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
