import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram/providers/post_provider.dart';
import 'package:instagram/providers/search_provider.dart';
import 'package:instagram/providers/user_provider.dart';
import 'package:instagram/responsive/mobile_screen_layout.dart';
import 'package:instagram/responsive/responsive_layout_screen.dart';
import 'package:instagram/responsive/web_screen_layout.dart';
import 'package:instagram/screens/login_screen.dart';
import 'package:instagram/utils/colors.dart';
import 'package:provider/provider.dart';
//import 'dart:ffi';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDPXn6ehEI_hb-kgc_BnaTMQxaepYCC2JQ",
          appId: "1:879434258154:web:824afa6808649dced3a993",
          messagingSenderId: "879434258154",
          projectId: "instagram-clone-a6426",
          storageBucket: "instagram-clone-a6426.appspot.com"),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PostProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(),
        ),
        // Provider(create: (_) => StreamProviders()),
        //ChangeNotifierProvider(create: (_) => PostProvider()),
        // StreamProvider(
        //   create: (_) => StreamProviders().getComments,
        //   initialData: null,
        // ),
      ],
      //builder: ,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        // home: const ResponsiveLayout(
        //   webScreenLayout: WebScreenLayout(),
        //   mobileScreenLayout: MobileScreenLayout(),
        // ),
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, AsyncSnapshot<User?> snapshot) {
              // if (snapshot.data == null) return LoginScreen();
              // return ResponsiveLayout(
              //   webScreenLayout: WebScreenLayout(),
              //   mobileScreenLayout: MobileScreenLayout(),
              // );
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              if (snapshot.hasData) {
                print("user logged in");
                return const ResponsiveLayout(
                  webScreenLayout: WebScreenLayout(),
                  mobileScreenLayout: MobileScreenLayout(),
                );
              } else {
                print("user logged out");
                return LoginScreen();
              }
            }),
      ),
    );
  }
}
