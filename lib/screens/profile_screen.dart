import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/providers/post_provider.dart';
import 'package:instagram/providers/user_provider.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/utils/utils.dart';
import 'package:instagram/widgets/follow_button.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../models/user.dart' as myUser;
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var isLoding = false;
  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    setState(() {
      isLoding = true;
    });
    try {
      await context.read<UserProvider>().getUserEitherOfScreens(widget.uid);
    } catch (e) {
      showSnacbar(context, e.toString());
    }
    setState(() {
      isLoding = false;
    });
  }

  @override
  Widget build(BuildContext parentContext) {
    return isLoding
        ? Center(
            child: CircularProgressIndicator(),
          )
        : StreamProvider<myUser.User?>(
            create: (context) =>
                parentContext.read<UserProvider>().getEitherOfScreens,
            initialData: myUser.User(
              photoUrl: "",
              uid: "",
              userName: "lol",
              bio: "lol",
              email: "lol",
              followers: [],
              following: [],
            ),
            builder: (context, widget) {
              return ProfileWidget(context);
            },
          );
  }

  Widget ProfileWidget(BuildContext context) {
    // var user = context.watch<myUser.User?>();
    return Consumer<myUser.User?>(
      builder: (context, user, child) => user == null
          ? Center(
              child: Text("There is no user"),
            )
          : user.userName == "lol"
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Scaffold(
                  appBar: AppBar(
                    backgroundColor: mobileBackgroundColor,
                    title: Text(user.userName),
                  ),
                  body: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage: NetworkImage(
                                    user.photoUrl,
                                  ),
                                  radius: 40,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          FutureBuilder<int>(
                                            future: context
                                                .read<PostProvider>()
                                                .getPostsLength(widget.uid),
                                            builder: (context, snapshot) {
                                              var data = 0;
                                              if (snapshot.hasData) {
                                                data = snapshot.data!;
                                              } else if (snapshot.hasError) {
                                                data = 0;
                                              }
                                              return buildStatColumn(
                                                  data, "posts");
                                            },
                                          ),
                                          buildStatColumn(user.followers.length,
                                              "followers"),
                                          buildStatColumn(user.following.length,
                                              "following"),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          context.select<UserProvider, String>(
                                                    ((value) =>
                                                        value.getUserUid),
                                                  ) ==
                                                  widget.uid
                                              ? FollowButton(
                                                  backgroundColor:
                                                      mobileBackgroundColor,
                                                  text: "Sign Out",
                                                  textColor: primaryColor,
                                                  borderColor: Colors.grey,
                                                  onPressed: () async {
                                                    await context
                                                        .read<UserProvider>()
                                                        .logOut();
                                                    // Navigator.of(context)
                                                    //     .pushReplacement(
                                                    //   MaterialPageRoute(
                                                    //     builder: (context) =>
                                                    //         const LoginScreen(),
                                                    //   ),
                                                    // );
                                                  },
                                                )
                                              : user.followers.contains(
                                                  context.select<UserProvider,
                                                      String>(
                                                    ((provider) =>
                                                        provider.getUserUid),
                                                  ),
                                                )
                                                  ? FollowButton(
                                                      backgroundColor:
                                                          Colors.white,
                                                      text: "Unfollow",
                                                      textColor: Colors.black,
                                                      borderColor: Colors.grey,
                                                      onPressed: () async {
                                                        var userId = context
                                                            .read<
                                                                UserProvider>()
                                                            .getUserUid;
                                                        await context
                                                            .read<
                                                                UserProvider>()
                                                            .followUser(
                                                              userId,
                                                              user.uid,
                                                            );
                                                      },
                                                    )
                                                  : FollowButton(
                                                      backgroundColor:
                                                          Colors.blue,
                                                      text: "Follow",
                                                      textColor: Colors.white,
                                                      borderColor: Colors.blue,
                                                      onPressed: () async {
                                                        if (user.followers
                                                            .isNotEmpty) {
                                                          user.followers
                                                              .forEach(
                                                                  (element) {
                                                            print(
                                                                "follow $element");
                                                          });
                                                        } else {
                                                          print(
                                                              "list is empty ${user.email}");
                                                        }

                                                        var userId = context
                                                            .read<
                                                                UserProvider>()
                                                            .getUserUid;
                                                        await context
                                                            .read<
                                                                UserProvider>()
                                                            .followUser(
                                                              userId,
                                                              user.uid,
                                                            );
                                                      },
                                                    )
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(top: 15),
                              child: Text(
                                user.userName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(top: 1),
                              child: Text(
                                user.bio,
                              ),
                            )
                          ],
                        ),
                      ),
                      child!,
                    ],
                  ),
                ),
      child: Expanded(
        flex: 1,
        child: FutureBuilder<List<Post>>(
          future: context.read<PostProvider>().getSpecificPosts(widget.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return GridView.builder(
                itemCount: snapshot.data!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 1.5,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    child: Image(
                      image: NetworkImage(snapshot.data![index].postUrl),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              );
            } else {
              return Container(
                margin: EdgeInsets.only(top: 10),
                alignment: Alignment.topCenter,
                child: Text("There is no post"),
              );
            }
          },
        ),
      ),
    );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
