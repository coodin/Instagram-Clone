import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/screens/login_screen.dart';
import 'package:instagram/utils/utils.dart';

import '../resources/auth_methods.dart';
import '../utils/colors.dart';
import '../widgets/text_field_input.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _userNameController.dispose();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      userName: _userNameController.text,
      bio: _bioController.text,
      file: _image,
    );
    setState(() {
      _isLoading = false;
    });
    if (res == "Success") {
      Navigator.of(context).pop();
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(
      //     builder: (context) => ResponsiveLayout(
      //       webScreenLayout: WebScreenLayout(),
      //       mobileScreenLayout: MobileScreenLayout(),
      //     ),
      //   ),
      // );
    } else {
      showSnacbar(context, res);
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (context) => ResponsiveLayout(
      //       webScreenLayout: WebScreenLayout(),
      //       mobileScreenLayout: MobileScreenLayout(),
      //     ),
      //   ),
      // );
    }
  }

  void navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 64,
                      ),
                      SvgPicture.asset(
                        "assets/ic_instagram.svg",
                        color: primaryColor,
                        height: 64,
                        semanticsLabel: 'Instagram Logo',
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      UserAvatar(),
                      const SizedBox(
                        height: 16,
                      ),
                      // circular widget to except and show our selected file
                      TextFieldInput(
                        textEditingController: _userNameController,
                        hintText: "Enter your username",
                        textInputType: TextInputType.text,
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      TextFieldInput(
                        textEditingController: _emailController,
                        hintText: "Enter your email",
                        textInputType: TextInputType.emailAddress,
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      TextFieldInput(
                        textEditingController: _passwordController,
                        hintText: "Enter your password",
                        textInputType: TextInputType.text,
                        isPass: true,
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      TextFieldInput(
                        textEditingController: _bioController,
                        hintText: "Enter your bio",
                        textInputType: TextInputType.text,
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      InkWell(
                        onTap: signUpUser,
                        child: Container(
                          child: _isLoading
                              ? Center(
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    color: primaryColor,
                                  ),
                                )
                              : Text("Sign Up "),
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: ShapeDecoration(
                            color: blueColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Text("Don't have an account?"),
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          GestureDetector(
                            onTap: navigateToLogin,
                            child: Container(
                              child: Text(
                                "Log in ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stack UserAvatar() {
    return Stack(
      children: [
        _image != null
            ? CircleAvatar(
                radius: 64,
                backgroundImage: MemoryImage(_image!),
              )
            : CircleAvatar(
                radius: 64,
                backgroundImage: NetworkImage(
                    "https://media.istockphoto.com/vectors/default-profile-picture-avatar-photo-placeholder-vector-illustration-vector-id1223671392?k=20&m=1223671392&s=612x612&w=0&h=lGpj2vWAI3WUT1JeJWm1PRoHT3V15_1pdcTn2szdwQ0="),
              ),
        Positioned(
          bottom: -10,
          right: 0,
          child: IconButton(
            onPressed: selectImage,
            icon: Icon(Icons.add_a_photo),
          ),
        ),
      ],
    );
  }
}
