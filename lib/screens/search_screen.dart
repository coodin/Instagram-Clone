import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram/models/post.dart';
import 'package:instagram/providers/post_provider.dart';
import 'package:instagram/providers/search_provider.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/utils/global_variables.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isShowUsers = false;

  void searchUsers() {
    context.read<SearchProvider>().getUserUsingSearch(_searchController.text);
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(searchUsers);
    context.read<PostProvider>().getWholePosts();
  }

  @override
  void dispose() {
    super.dispose();
    isShowUsers = false;
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isWeb = MediaQuery.of(context).size.width > webScreenSize;
    var isWebTiles = isWeb
        ? [
            QuiltedGridTile(1, 2),
            QuiltedGridTile(2, 2),

            QuiltedGridTile(1, 1),
            QuiltedGridTile(1, 1),
            QuiltedGridTile(1, 2),

            // QuiltedGridTile(2, 1),
            //QuiltedGridTile(1, 2),
          ]
        : [
            QuiltedGridTile(2, 2),
            QuiltedGridTile(1, 1),
            QuiltedGridTile(1, 1),
            QuiltedGridTile(1, 2),
          ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: _searchController,
          decoration: InputDecoration(labelText: "Search for a user"),
          onFieldSubmitted: (String value) {
            setState(() {
              isShowUsers = true;
            });
          },
        ),
      ),
      body: isShowUsers
          ? StreamBuilder(
              stream: context.select<SearchProvider, Stream<List<User>>?>((provider) => provider.getSearchUsers),
              builder: (context, AsyncSnapshot<List<User>> snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            ///print("uid: ${snapshot.data![index].uid}");
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(uid: snapshot.data![index].uid),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(snapshot.data![index].photoUrl),
                            ),
                            title: Text(snapshot.data![index].userName),
                          ),
                        );
                      },
                    );
                  } else {
                    return Text("There is no data");
                  }
                }
                if (snapshot.hasError) {
                  return Container(
                    child: Center(
                      child: Text(snapshot.error.toString()),
                    ),
                  );
                }
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            )
          : StreamBuilder(
              stream: context.read<PostProvider>().getAllPosts,
              builder: (context, AsyncSnapshot<List<Post>> snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    return GridView.builder(
                      itemCount: snapshot.data!.length,
                      gridDelegate: SliverQuiltedGridDelegate(
                        crossAxisCount: isWeb ? 4 : 4,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 30,
                        repeatPattern: QuiltedGridRepeatPattern.inverted,
                        pattern: isWebTiles,
                      ),
                      itemBuilder: (context, index) => Container(
                        child: Image.network(
                          snapshot.data![index].profImage,
                          fit: BoxFit.cover,
                        ),
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
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
    );
  }
}
