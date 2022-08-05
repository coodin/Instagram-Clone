import 'package:flutter/material.dart';
import 'package:instagram/providers/user_provider.dart';
import 'package:instagram/screens/add_post_screen.dart';
import 'package:instagram/screens/search_screen.dart';
import 'package:provider/provider.dart';

import '../screens/feed_screen.dart';
import '../screens/profile_screen.dart';

const webScreenSize = 600;

var homeScreenItems = [
  FeedScreen(),
  SearchScreen(),
  AddPostScreen(),
  Center(child: Text("notif")),
  Selector<UserProvider, String>(
    selector: (context, provider) {
      return provider.getUser.uid;
    },
    builder: (context, uid, child) {
      return ProfileScreen(
        uid: uid,
      );
    },
  )
];
