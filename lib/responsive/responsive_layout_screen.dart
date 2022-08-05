import 'package:flutter/material.dart';
import 'package:instagram/providers/user_provider.dart';
import 'package:instagram/utils/utils.dart';
import 'package:provider/provider.dart';

import '../utils/colors.dart';
import '../utils/global_variables.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;
  const ResponsiveLayout({
    Key? key,
    required this.webScreenLayout,
    required this.mobileScreenLayout,
  }) : super(key: key);

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  // @override
  // void didUpdateWidget(covariant ResponsiveLayout oldWidget) {
  //   addData();
  //   super.didUpdateWidget(oldWidget);
  // }

  @override
  void initState() {
    super.initState();
    addData();
  }

  addData() async {
    UserProvider _userProvider = Provider.of(context, listen: false);
    try {
      await _userProvider.refreshUser();
    } catch (e) {
      showSnacbar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var waiting = context
        .select<UserProvider, bool>((provider) => provider.waitingUserDetail);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          );
        } else {
          if (constraints.maxWidth > webScreenSize) {
            return widget.webScreenLayout;
          }
          return widget.mobileScreenLayout;
        }
      },
    );
  }
}
